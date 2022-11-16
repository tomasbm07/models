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

CENAS

#### Part 4

CENAS
