public class ICantBeliveItCanSort {
    // Ensure that the array is sorted
    // Ensure that the array has the same elements as the original array (ignoring duplicates)
    //@ requires a != null;
    //? requires a.length > 0;
    //@ ensures (\forall int i; 0 <= i < a.length-1; a[i] <= a[i+1]);
    //@ ensures \old(a.length) == a.length;
    //@ ensures (\forall int i; 0 <= i < \old(a.length); (\exists int j; 0 <= j && j < a.length; \old(a[i]) == a[j]));
    public static void sort(/*@ non_null @*/ int[] a) {
        //@ loop_invariant 0 <= i <= a.length;
        //@ loop_invariant (\forall int k; i <= k && k < a.length; a[k] >= a[i]);
        //@ loop_invariant (\forall int p; 0 <= p < i; (\forall int r; p < r < i; a[p] <= a[r]));
        //@ decreases a.length - i;
        for (int i = 0; i < a.length; i++) {
            //@ loop_invariant 0 <= j <= a.length;
            //@ loop_invariant (\forall int k; 0 <= k && k < j; a[k] >= a[i]);
            //@ loop_invariant \forall int p; 0 <= p < i; (\forall int r; p < r < i; a[p] <= a[r]);
            //@ decreases a.length - j;
            for (int j = 0; j < a.length; j++) {
                if (a[i] < a[j]) {
                    int tmp = a[i];
                    a[i] = a[j];
                    a[j] = tmp;
                }
                //@ assert a[j] <= a[i];
            }
        }
    }
}

