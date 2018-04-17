/**
* Cluster - Agrupation of POIs, that combines all their characteristics and has a bigger attraction effect. Its position in canvas
* is not defined in geographic files (GeoJSON) but by the user, and connect not the closest roadmap point but to a specific node that
* has a defined "direction" field that matchs with cluster id. Clusters can be chained with other Clusters.
* @author    Marc Vilella
* @version   1.0
* @see       POI
*/
public class Cluster extends POI {
    
    /**
    * Initiate Cluster with specific POI characteristics plus an id to connect to a specific node
    * @param roads     Roadmap to place the Cluster
    * @param id        ID of the Cluster
    * @param name      Name of the Cluster
    * @param position  Position of the Cluster
    * @param direction Next cluster to connect (if any)   
    * @param capacity  Customers capacity of the Cluster
    */
    public Cluster(Roads roads, String id, String name, PVector position, String direction, int capacity) {
        super(roads, id, name, "cluster", position, capacity);
        setDirection(direction);
    }
    
    
    /**
    * Place Cluster into roadmap, connected to specific node
    * @param roads    Roadmap to place the POI
    */
    @Override
    public void place(Roads roads) {
        for(Node node : roads) {
            if(node.getDirection() != null && ID.equals(node.getDirection())) {
                node.connectBoth(this, null, "Connection to " + NAME, Accessible.ALL);
                roads.add(this);
                break;
            }
        }
    }
    
    
    /**
    * Draw CLuster in screen
    * @param canvas  Canvas to draw node
    * @param stroke  Lane width in pixels
    * @param c  Lanes color
    */
    @Override
    public void draw(PGraphics canvas, int stroke, color c) {
        canvas.ellipseMode(CENTER); canvas.noFill(); canvas.stroke(c); canvas.strokeWeight(2);
        canvas.ellipse(POSITION.x, POSITION.y, 75, 75);
        canvas.textAlign(CENTER, TOP); canvas.textSize(9); canvas.fill(c);
        canvas.text(NAME, POSITION.x, POSITION.y);
        for(Lane lane : lanes) {
            lane.draw(canvas, stroke, c);
        }
    }
    
}
