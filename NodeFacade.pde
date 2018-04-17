import java.util.Collections;
import java.util.*;

/**
* NodeFacade - Class to manage the roadmap of simulation
* @author        Marc Vilella
* @version       2.0
*/
public class NodeFacade extends Facade<Node> {

    private PVector window;
    private PVector[] bounds;
   
    
    /**
    * Initiate roadmap from a GeoJSON file
    * @param file  GeoJSON file containing roads description. Use OpenStreetMap (OSM) format
    */
    public NodeFacade(Factory factory, String file, int x, int y, PVector[] bounds) {
        super(factory);
        
        window = new PVector(x, y);
        this.bounds = bounds;
        
        this.load(file, this);
    }


    
    private void connect(POI poi) {
        
        Edge closestEdge = findClosestEdge(poi.getPosition());
        Edge closestEdgeBack = closestEdge.findContrariwise();
        PVector closestPoint = closestEdge.findClosestPoint(poi.getPosition());
        
        Node connectionNode = new Node(closestPoint);
        connectionNode = closestEdge.split(connectionNode);
        if(closestEdgeBack != null) connectionNode = closestEdgeBack.split(connectionNode);
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
        Edge closestEdge = findClosestEdge(position);
        return closestEdge.findClosestPoint(position);
    }

    
    public Edge findClosestEdge(PVector position) {
        Float minDistance = Float.NaN;
        Edge closestEdge = null;
        for(Node node : items) {
            for(Edge edge : node.outboundEdges()) {
                PVector linePoint = edge.findClosestPoint(position);
                float distance = position.dist(linePoint);
                if(minDistance.isNaN() || distance < minDistance) {
                    minDistance = distance;
                    closestEdge = edge;
                }
            }
        }
        return closestEdge;
    }

    
    public void select(int mouseX, int mouseY) {
        for(Node node : items) node.select(mouseX, mouseY);
    }
    
}
