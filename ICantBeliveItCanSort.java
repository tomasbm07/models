public class ICantBeliveItCanSort {
    //@ requires a != null;
    //@ ensures (\forall int i; 0 <= i && i < a.length-1; a[i] <= a[i+1]);
    public static void sort(int[] a) {
        for (int i = 0; i < a.length; i++) {
            for (int j = 0; j < a.length; j++) {
                if (a[i] < a[j]) {
                    int tmp = a[i];
                    a[i] = a[j];
                    a[j] = tmp;
                }
            }
        }
    }
}

