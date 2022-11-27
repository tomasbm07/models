public class ICantBeliveItCanSort {
    /*@
        requires a != null && a.length > 0;
        ensures (\forall int i; 0 <= i < a.length - 1; a[i] <= a[i+1]);
        ensures \old(a.length) == a.length; 
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

