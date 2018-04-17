/**
* Factory - Abstract Factory class to generate items from diferent sources 
* @author        Marc Vilella
* @version       1.0
*/
public abstract class Factory<T> {
    
    protected IntDict counter = new IntDict();
    
    /**
    * Get items counter (dictionary with different type and total amount for each one)
    * @return items counter
    */
    public IntDict getCounter() {
        return counter;
    }
    
    
    /**
    * Count the total amount of objects created
    * @return amount of objects
    */
    public int count() {
        int count = 0;
        for(String name : counter.keyArray()) count += counter.get(name);
        return count;
    }
    
    
    /**
    * Create objects from a file
    * @param file  File with object definitions
    * @param roads  Roadmap where objects will be added
    * @return list with new created objects 
    */
    public abstract ArrayList<T> load(File file, Roads roads);
    
}
