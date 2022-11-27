# Models - report for assigment 1

## Members

- Tomás Mendes
- Bar Harel

### Exercise 1

#### Part 1

By following the specification of the method `equals()` in the [java documentation](https://docs.oracle.com/en/java/javase/19/docs/api/java.base/java/lang/Object.html#equals(java.lang.Object)), we can get to following openJML contract:

```java
    //@ also ensures (o == null | !(o instanceof Value)) ==> (\result == false);
    //@ also ensures (o instanceof Value) ==> (\result == this.value.equals(((Value) o).value));
```

We must ensure:

- The object we are comparing, is not null.
- The object we are comparing, is of the same class `Value`.
- The method returns true if the objects match and false if they don't.

#### Part 2

By running openJML with the contract described above and the same code, we get the following erros:

```bash
openjml --esc Value.java
Value.java:33: verify: The prover cannot establish an assertion (PossiblyBadCast) in method equals: a java.lang.Object cannot be proved to be a Value
    Value other = (Value) o;
        ^
Value.java:33: verify: The prover cannot establish an assertion (PossiblyNullInitialization) in method equals: other
    Value other = (Value) o;
    ^
2 verification failures
```

To pass all the verification tests, we must ensure the object we are trying to match is not `null`.

### Exercise 2

#### Part 3

To make sure the array is sorted upon exiting, we used the following jml contract:

```java
/*@
    requires a != null && a.length > 0;
    ensures (\forall int i; 0 <= i < a.length - 1; a[i] <= a[i+1]);
    ensures \old(a.length) == a.length; 
    ensures (\forall int i; 0 <= i < \old(a.length); (\exists int j; 0 <= j < a.length; \old(a[i]) == a[j]));
@*/
```

##### Pre conditions

- `requires a != null && a.length > 0;` makes sure the given array is not null and it's length isn't 0, as it's not possible to sort an array of length 0

##### Post conditions

- `ensures (\forall int i; 0 <= i < a.length - 1; a[i] <= a[i+1]);` ensures the array is sorted
- `ensures \old(a.length) == a.length;` ensures the array has the same length after getting sorted
- `ensures (\forall int i; 0 <= i < \old(a.length); (\exists int j; 0 <= j < a.length; \old(a[i]) == a[j]));` ensures the array is a permutation of the original array and not a different one.

#### Part 4

```java
public class ICantBeliveItCanSort {
    /*@
        requires a != null && a.length > 0;
        ensures (\forall int i; 0 <= i < a.length - 1; a[i] <= a[i+1]);
        ensures \ol d(a.length) == a.length; 
        ensures (\forall int i; 0 <= i < \old(a.length); (\exists int j; 0 <= j < a.length; \old(a[i]) == a[j]));
    @*/
    public static void sort(/*@ non_null @*/ int[] a) {
        //@ final ghost int n = a.length;

        //@ loop_invariant 0 <= i <= n;
        //@ decreasing n - i;
        for (int i = 0; i < a.length; i++) {

            //@ loop_invariant 0 <= j <= n;
            //@ loop_invariant \forall int k; j > i && 0 <= k < i; a[k] <= a[k + 1];
            //@ decreasing n - j;
            for (int j = 0; j < a.length; j++) {
                if (a[i] < a[j]) {
                    //@ assert a[i] < a[j];
                    int tmp = a[i];
                    a[i] = a[j];
                    a[j] = tmp;
                }
            }
        }
    }
}
```
