/**
* Road - Node is the main element for roadmap, defining road intersections
* @author        Marc Vilella
* @credits       Aaron Steed http://www.robotacid.com/PBeta/AILibrary/Pathfinder/index.html
* @version       2.0
* @see           Edge
*/
private class Node implements Placeable, Comparable<Node> {

    protected int id;
    protected final PVector POSITION;
    protected ArrayList<Edge> edges = new ArrayList();
    protected boolean selected;
    private String direction = null;
    
    // Pathfinding variables
    private Node parent;
    private float f;
    private float g;
    
    
    /**
    * Initiate node with its position. ID is defined to -1 until it is finally placed into roadmap
    * @param position  Node's position
    */
    public Node(PVector position) {
        id = -1;
        this.POSITION = position;
    }
    
    
    /**
    * Set node ID
    * @param id    ID of the node
    */
    public void setID(int id) {
        this.id = id;
    }
    
    
    /**
    * Get node ID
    * @return node ID
    */
    public int getID() {
        return id;
    }
    
    
    /**
    * Save node into roadmap.
    * @param roads  Roadmap to add node
    */
    public void place(NodeFacade roads) {
        roads.add(this);
    }
    
    
    /**
    * Get node position
    * @return node position
    */
    public PVector getPosition() {
        return POSITION.copy();
    }
    
    
    /**
    * Get all outbound edges from the node
    * @return outbound edges
    */
    public ArrayList<Edge> outboundEdges() {
        return edges;
    }
    
    
    /**
    * Get shortest edge that goes to a specified node, if exists
    * @param node  Destination node
    * @return shortest edge to destination node, null if no edge goes to node
    */
    public Edge shortestEdgeTo(Node node) {
        Float shortestEdgeLength = Float.NaN;
        Edge shortestEdge = null;
        for(Edge edge : edges) {
            if(node.equals(edge.getEnd())) {
                if(shortestEdgeLength.isNaN() || edge.getLength() < shortestEdgeLength) {
                    shortestEdgeLength = edge.getLength();
                    shortestEdge = edge;
                }
            }
        }
        return shortestEdge;
    }
    
    
    /**
    * Create a edge that connects node with another node
    * @param node  Node to connect
    * @param vertices  List of vertices that shape the edge
    * @param name  Name of the edge
    */
    protected void connect(Node node, ArrayList<PVector> vertices, String name, Accessible access) {
        edges.add( new Edge(name, access, this, node, vertices) );
    }
    
    
    /**
    * Create a bidirectional connection (two edges) between node and another node
    * @param node  Node to connect
    * @param vertices  List of vertices that shape the edges
    * @param name  Name of the edges
    */
    protected void connectBoth(Node node, ArrayList<PVector> vertices, String name, Accessible access) {
        connect(node, vertices, name, access);
        if(vertices != null) Collections.reverse(vertices);
        node.connect(this, vertices, name, access);
    }

    
    /**
    * Set the direction of the street (to connect a Cluster to this node) 
    * @param direction  Cluster direction ID
    */
    protected void setDirection(String direction) {
        this.direction = direction;
    }

    
    /**
    * Get the direction of the street (to connect a Cluster to this node) 
    * @return the direction ID of the next Cluster
    */
    protected String getDirection() {
        return direction;
    }
    
    
    public boolean allows(Agent agent) {
        for(Edge edge : edges) {
            if(edge.allows(agent)) return true;
        }
        return false;
    }


    /**
    * Draw the node and outbound edges with default colors
    * @param canvas  Canvas to draw node
    */
    public void draw(PGraphics canvas) {
        canvas.fill(#000000); 
        canvas.ellipse(POSITION.x, POSITION.y, 3, 3);
        draw(canvas, 1, #F0F3F5);
    }
    
    
    /**
    * Draw outbound edges with specified colors
    * @param canvas  Canvas to draw node
    * @param stroke  Edge width in pixels
    * @param c  Edges color
    */
    public void draw(PGraphics canvas, int stroke, color c) {
        for(Edge edge : edges) {
            edge.draw(canvas, stroke, c);
        }
    }
    
    
    /**
    * Select node if mouse is hover
    * @param mouseX  Horizontal mouse position in screen
    * @param mouseY  Vertical mouse position in screen
    * @return true if node is selected, false otherwise
    */
    public boolean select(int mouseX, int mouseY) {
        selected = dist(POSITION.x, POSITION.y, mouseX, mouseY) < 2;
        return selected;
    }
    
    
    /**
    * PATHFINDING METHODS.
    * Update and get pathfinding variables (parent node, f and g)
    */
    public void setParent(Node parent) {
        this.parent = parent;
    }
    
    public Node getParent() {
        return parent;
    }
    
    public void setG(float g) {
        this.g = g;
    }
    
    public float getG() {
        return g;
    }
    
    public void setF(Node nextNode) {
        float h =  POSITION.dist(nextNode.getPosition());
        f = g + h;
    }
    
    public float getF() {
        return f;
    }
    
    public void reset() {
        parent = null;
        f = g = 0.0;
    }
    
    
    /**
    * Return agent description (ID, POSITION and LANEs)
    * @return node description
    */
    @Override
    public String toString() {
        return id + ": " + POSITION + " [" + edges.size() + "]"; 
    }
    
    
    /**
    * Compare node to other node, where comparing means checking which one has the lowest f (accumulated cost in pathfinding). It is used in
    * PriorityQueue structure in the A* pathfinding algorithm.
    * @param node  Node to compare f (accumulated cost)
    * @return -1 if cost is lower, 0 if costs are equal or 1 if cost is higher
    */
    @Override
    public int compareTo(Node node) {
        return f < node.getF() ? -1 : f == node.getF() ? 0 : 1;
    }
    
}
