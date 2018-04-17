/**
* Interface for predicate filters
*/
public interface Predicate<T> {
    public boolean evaluate(T type);
}
