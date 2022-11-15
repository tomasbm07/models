public class Value {
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

    @Override
    public boolean equals(Object o) {
        Value other = (Value) o;
        if (!this.value.equals(other.value))
            return false;
        return true;
    }

}