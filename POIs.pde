/**
* POIs - Facade to simplify manipulation of Pois of Interest in simulation
* @author        Marc Vilella
* @version       1.0
* @see           Facade
*/
public class POIs extends Facade<POI> {

    /**
    * Initiate pois of interest facade and agents' Factory
    * @param parent  Sketch applet, just put this when calling constructor
    */
    public POIs(Factory factory) {
        super(factory);
    }
    
}
