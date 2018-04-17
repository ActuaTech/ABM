/**
* Path - Class defining the path an agent must follow to arrive to its destination. It's autocontained, and able to be updated and recalculated 
* @author        Marc Vilella
* @credits       aStar method inspired in Aaron Steed's Pathfinding class http://www.robotacid.com/PBeta/AILibrary/Pathfinder/index.html
* @version       2.0
* @see           Node, Edge
*/
public class Path {

    private final NodeFacade ROADMAP; 
    private final Agent AGENT;
    
    private ArrayList<Edge> edges = new ArrayList();
    private float distance = 0;
    
    // Path movement variables
    private Node inNode = null;
    private Edge currentEdge;
    private PVector toVertex;
    private boolean arrived = false;
    
    
    /**
    * Initiate Path
    * @param agent  Agent using the path
    * @param roads  Roadmap used to find possible paths between its nodes
    */
    public Path(Agent agent, NodeFacade roads) {
        ROADMAP = roads;
        AGENT = agent;
    }
    

    /**
    * Check if path is computed and available
    * @return true if path is computed, false otherwise
    */
    public boolean available() {
        return edges.size() > 0;
    }    


    /**
    * Calculate path length
    * @return path length in pixels
    */
    private float calcLength() {
        float distance = 0;
        for(Edge edge : edges) distance += edge.getLength();
        return distance;
    }
    
    
    /**
    * Get path length
    * @return path length
    */
    public float getLength() {
        return distance;
    }
    
    
    /**
    * Check if agent has arrived to the end of the path
    * @return true if agent has arrived, false otherwise
    */
    public boolean hasArrived() {
        return arrived;
    }
    
    
    /**
    * Return the node where the agent is placed
    * @return node where agent is placed
    */
    public Node inNode() {
        return inNode;
    }
    
    
    /**
    * Reset path paramters to initial state
    */
    public void reset() {
        edges = new ArrayList();
        currentEdge = null;
        arrived = false;
        distance = 0;
    }
    
    
    /**
    * Move agent across the path.
    * @param pos  Actual agent position
    * @param speed  Speed of agent
    * @return agent position after movement
    */
    public PVector move(PVector pos, float speed) {
        PVector dir = PVector.sub(toVertex, pos);
        PVector movement = dir.copy().normalize().mult(speed);
        if(movement.mag() < dir.mag()) return movement;
        else {
            if( currentEdge.isLastVertex( toVertex ) ) goNextEdge();
            else toVertex = currentEdge.nextVertex(toVertex);
            return dir;
        }
    }
    
    
    /**
    * Move agent to next edge in path. Update node binding and handles edge hosting of agent. If there isn't next edge, finishes path.
    */
    public void goNextEdge() {
        inNode = currentEdge.getEnd();
        currentEdge.removeAgent(AGENT);
        int i = edges.indexOf(currentEdge) + 1;
        if( i < edges.size() ) {
            currentEdge = edges.get(i);
            toVertex = currentEdge.getVertex(1);
            currentEdge.addAgent(AGENT);
        } else arrived = true;
    }
    
    
    /**
    * Draw path
    * @param canvas  Canvas to draw path
    * @param stroke  Path stroke
    * @param c    Path color
    */
    public void draw(PGraphics canvas, int stroke, color c) {
        for(Edge edge : edges) {
            edge.draw(canvas, stroke, c);
        }
    }
    
    
    /**
    * Find a path between two points
    * @param origin  Origin node of the path
    * @param destination  Destination node of the path
    * @return true if a path has been found, false otherwise   
    */
    public boolean findPath(Node origin, Node destination) {
        if(origin != null && destination != null) {
            edges = aStar(origin, destination);
            if(edges.size() > 0) {
                distance = calcLength();
                inNode = origin;
                currentEdge = edges.get(0);
                toVertex = currentEdge.getVertex(1);
                arrived = false;
                return true;
            }
        }
        return false;
    }
    
    
    /**
    * Perform a A* pathfinding algorithm
    * @param origin  Origin node
    * @param destination  Destination node
    * @return list of edges that define the found path from origin to destination
    */
    private ArrayList<Edge> aStar(Node origin, Node destination) {
        ArrayList<Edge> path = new ArrayList();
        if(!origin.equals(destination)) {
            for(Node node : ROADMAP) node.reset();
            ArrayList<Node> closed = new ArrayList();
            PriorityQueue<Node> open = new PriorityQueue();
            open.add(origin);
            while(open.size() > 0) {
                Node currNode = open.poll();
                closed.add(currNode);
                if( currNode.equals(destination) ) break;
                for(Edge edge : currNode.outboundEdges()) {
                    Node neighbor = edge.getEnd();
                    if( !edge.isOpen() || closed.contains(neighbor) || !edge.allows(AGENT)) continue;
                    boolean neighborOpen = open.contains(neighbor);
                    float costToNeighbor = currNode.getG() + edge.getLength();
                    if( costToNeighbor < neighbor.getG() || !neighborOpen ) {
                        neighbor.setParent(currNode); 
                        neighbor.setG(costToNeighbor);
                        neighbor.setF(destination);
                        if(!neighborOpen) open.add(neighbor);
                    }
                }
            }
            path = tracePath(destination);
        }
        return path;
    }
    
    
    /**
    * Look back all path to a node
    * @param destination  Destination node
    * @return list of edges that define a path to destination node
    */
    private ArrayList<Edge> tracePath(Node destination) {
        ArrayList<Edge> path = new ArrayList();
        Node pathNode = destination;
        while(pathNode.getParent() != null) {
            path.add( pathNode.getParent().shortestEdgeTo(pathNode) );
            pathNode = pathNode.getParent();
        }
        Collections.reverse(path);
        return path;
    }
    
    
    /**
    * Return the list of edges that form the path
    * @return path description
    */
    @Override
    public String toString() {
        String str = edges.size() + " LANES: ";
        for(Edge edge : edges) {
            str += edge.toString() + ", ";
        }
        return str;
    }
    
}
