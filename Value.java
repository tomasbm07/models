public class Value {
    //@ spec_public
    private Long value;

    public Value(Long value) {
        this.value = value;
    }

    public Long getValue() {
        return this.value;
    }

    public void setValue(Long value) {
        this.value = value;
    }

    public boolean isStrictlyPositive() {
        return value > 0;
    }

    public boolean isNegative() {
        return value > 0;
    }

    //@ also ensures (o == null || !(o instanceof Value)) ==> (\result == false);
    //@ also ensures (o instanceof Value) ==> (\result == this.value.equals(((Value) o).value));
    /*@ pure @*/
    @Override
    public boolean equals(/*@ nullable @*/ Object o) {
        if (!(o instanceof Value)) {  // if (null) is implicit in instanceof
            return false;
        }
        Value other = (Value) o;
        if (!this.value.equals(other.value))
            return false;
        return true;
    }

}