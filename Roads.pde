import java.util.Collections;
import java.util.*;

/**
* Roads - Class to manage the roadmap of simulation
* @author        Marc Vilella
* @version       2.0
*/
public class Roads extends Facade<Node> {

    private PVector window;
    private PVector[] bounds;
   
    
    /**
    * Initiate roadmap from a GeoJSON file
    * @param file  GeoJSON file containing roads description. Use OpenStreetMap (OSM) format
    */
    public Roads(Factory factory, String file, int x, int y, PVector[] bounds) {
        super(factory);
        
        window = new PVector(x, y);
        this.bounds = bounds;
        
        this.load(file, this);
    }


    
    private void connect(POI poi) {
        
        Lane closestLane = findClosestLane(poi.getPosition());
        Lane closestLaneBack = closestLane.findContrariwise();
        PVector closestPoint = closestLane.findClosestPoint(poi.getPosition());
        
        Node connectionNode = new Node(closestPoint);
        connectionNode = closestLane.split(connectionNode);
        if(closestLaneBack != null) connectionNode = closestLaneBack.split(connectionNode);
        this.add(connectionNode);
        
        poi.connectBoth(connectionNode, null, "Access", poi.access);
        add(poi);
        
    }

    
    @Override
    public void add(Node node) {
        if(node.getID() == -1) {
            node.setID(items.size());
            items.add(node);
        }
    }


    public PVector toXY(float lat, float lon) {
        return new PVector(
            map(lon, bounds[0].y, bounds[1].y, 0, window.x),
            map(lat, bounds[0].x, bounds[1].x, window.y, 0)
        );
    }
    
    
    public boolean contains(PVector point) {
        return point.x > 0 && point.x < window.x && point.y > 0 && point.y < window.y;
    }
    
    
    public float toMeters(float px) {
        return px * (bounds[1].x - bounds[0].x) / width;
    }
    
    
    public void draw(PGraphics canvas, int stroke, color c) {
        for(Node node : items) node.draw(canvas, stroke, c);
    }
    
    
    public PVector findClosestPoint(PVector position) {
        Lane closestLane = findClosestLane(position);
        return closestLane.findClosestPoint(position);
    }

    
    public Lane findClosestLane(PVector position) {
        Float minDistance = Float.NaN;
        Lane closestLane = null;
        for(Node node : items) {
            for(Lane lane : node.outboundLanes()) {
                PVector linePoint = lane.findClosestPoint(position);
                float distance = position.dist(linePoint);
                if(minDistance.isNaN() || distance < minDistance) {
                    minDistance = distance;
                    closestLane = lane;
                }
            }
        }
        return closestLane;
    }

    
    public void select(int mouseX, int mouseY) {
        for(Node node : items) node.select(mouseX, mouseY);
    }
    
}
