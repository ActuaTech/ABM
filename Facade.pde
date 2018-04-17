/**
* Agents - Abstract Facade to simplify manipulation of items in simulation
* @author        Marc Vilella
* @version       1.0
* @see           Factory
*/
public abstract class Facade<T extends Placeable> implements Iterable<T> {
    
    protected Factory<T> factory;
    protected ArrayList<T> items = new ArrayList<T>();

    
    public Facade(Factory factory) {
        this.factory = factory;
    }
    
    
    /**
    * Count the total amount of items
    * @return amount of items in facade
    */
    public int count() {
        return items.size();
    }
    
    
    /**
    * Count the amount of items that match with a specific condition
    * @param predicate  Predicate condition
    * @return amount of items matching with condition
    */
    public int count(Predicate<T> predicate) {
        return filter(predicate).size();
    }
    
    
    /**
    * Filter items by a specific condition
    * @param predicate  Predicate condition
    * @return all items matching with condition
    */
    public ArrayList<T> filter(Predicate<T> predicate) {
        ArrayList<T> result = new ArrayList();
        for(T item : items) {
            if(predicate.evaluate(item)) result.add(item);
        }
        return result;
    }
    
    
    /**
    * Get a random item
    * @return random item
    */
    public T getRandom() {
        int i = round(random(0, items.size()-1));
        return items.get(i);
    }
    
    
    /** 
    * Draw all items
    * @param canvas  Canvas to draw items
    */
    public void draw(PGraphics canvas) {
        for(T item : items) item.draw(canvas);
    }
    
    
    /**
    * Select items that are under mouse pointer
    * @param mouseX  Horizontal mouse position in screen
    * @param mouseY  Vertical mouse position in screen
    */
    public void select(int mouseX, int mouseY) {
        for(T item : items) item.select(mouseX, mouseY);
    }

    
    /**
    * Create new items from a file, if it exists
    * @param filePath  Path to file with items definitions
    * @param roads     Roadmap where objects will be added
    */
    public void load(String filePath, NodeFacade roadmap) {
        File file = new File( dataPath(filePath) );
        if( !file.exists() ) println("ERROR! File does not exist");
        else items.addAll( factory.load(file, roadmap) );
    }

    
    /**
    * Add new item to items list
    * @param item  Item to add
    */
    public void add(T item) {
        items.add(item);
    }
    
    
    /**
    * Print item's legend in a specific position
    * @param canvas  Canvas to draw legend
    * @param x  Horizontal position in screen
    * @param y  Vertical position in screen
    */
    public void printLegend(PGraphics canvas, int x, int y) {
        String txt = "";
        IntDict counter = factory.getCounter();
        textAlign(LEFT, TOP);
        for(String name : counter.keyArray()) txt += name + ": " + counter.get(name) + "\n";
        text(txt, x, y);
    }
    
    
    /**
    * Return iterator to loop over items
    */
    @Override
    public Iterator<T> iterator() {
        return items.iterator();
    }
    
}
