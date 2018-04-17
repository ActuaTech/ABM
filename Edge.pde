/**
* Edge - Edge is the connection bewtween two nodes in roadmap graph, and implements all possibilities for agents to move in them
* @author        Marc Vilella
* @credits       Aaron Steed http://www.robotacid.com/PBeta/AILibrary/Pathfinder/index.html
* @version       2.0
* @see           Node
*/
private class Edge {
    
    private String name;
    private Accessible access;
    
    private Node initNode;
    private Node finalNode;
    private float distance;
    private ArrayList<PVector> vertices = new ArrayList();
    private boolean open = true;
    
    private int maxCrowd = 10;
    private ArrayList<Agent> crowd = new ArrayList();
    private float occupancy;
    
    
    /**
    * Initiate Edge with name, init and final nodes and inbetween vertices
    * @param name  Name of the street containing the edge
    * @param initNode  Node where the edge starts
    * @param finalNode  Node where the edge ends
    * @param vertices  List of vertices that give shape to edge
    */
    public Edge(String name, Accessible access, Node initNode, Node finalNode, ArrayList<PVector> vertices) {
        this.name = name;
        this.access = access;
        this.initNode = initNode;
        this.finalNode = finalNode;
        if(vertices != null && vertices.size() != 0) this.vertices = new ArrayList(vertices);
        else {
            this.vertices.add(initNode.getPosition());
            this.vertices.add(finalNode.getPosition());
        }
        distance = calcLength();
    }
    
    
    /**
    * Get the end node, where the edge is connected
    * @return end node
    */
    public Node getEnd() {
        return finalNode;
    }
    
    
    /**
    * Get a copy of all vertices that shape the edge
    * @return list of vertices in edge
    */
    public ArrayList<PVector> getVertices() {
        return new ArrayList(vertices);
    }
    
    
    /**
    * Get the i vertex in edge
    * @param i  Position of vertex in edge
    * @return vertex in position i, null if position does not exist
    */
    public PVector getVertex(int i) {
        if(i >= 0  && i < vertices.size()) return vertices.get(i).copy();
        return null;
    }
    
    
    /**
    * Calculate the length of edge
    * @return length of edge in pixels
    */
    public float calcLength() {
        float dist = 0;
        for(int i = 1; i < vertices.size(); i++) dist += vertices.get(i-1).dist( vertices.get(i) );
        return dist;
    }
    
    
    /**
    * Get the length of the edge
    * @return Length of edge in pixels 
    */
    public float getLength() {
        return distance;
    }
    
    
    /**
    * Check if edge is open
    * @return true if edge is open, false otherwise
    */
    public boolean isOpen() {
        return open;
    }


    public boolean allows(Agent agent) {
        return access.allows(agent);
    }
    
    
    /**
    * Check if edge contains a specific vertex
    * @param vertex  Position to compare with existent vertices
    * @return true if vertex is in edge, false otherwise
    */
    public boolean contains(PVector vertex) {
        return vertices.indexOf(vertex) >= 0;
    }

    
    /**
    * Get the following vertex in edge
    * @param vertex  Vertex in edge
    * @return  next vertex, or null if vertex is last vertex or doesn't exist in edge
    */
    public PVector nextVertex(PVector vertex) {
        int i = vertices.indexOf(vertex) + 1;
        if(i > 0 && i < vertices.size()) return vertices.get(i);
        return null;
    }

    
    /**
    * Check if vertex is last of edge
    * @param vertex  Vertex to check
    * @return true if vertex is the last one in edge, false otherwise
    */
    public boolean isLastVertex( PVector vertex ) {
        return vertex.equals( vertices.get( vertices.size() - 1 ) );
    }
    
    
    /**
    * Find contrariwise edge, if exists. Contrariwise is aedge that follows the same vertices in opposite direction.
    * @return contrariwise edge, or null if it doesn't exists
    */
    public Edge findContrariwise() {
        for(Edge otherEdge : finalNode.outboundEdges()) {
            if( otherEdge.isContrariwise(this) ) return otherEdge;
        }
        return null;
    }
    
    
    /**
    * Check if edge is contrariwise. Contrariwise is the edge that follows the same vertices in opposite direction.
    * @param edge  Edge to compare
    * @return true if both edges are contrariwise, false otherwise
    */
    public boolean isContrariwise(Edge edge) {
        ArrayList<PVector> reversedVertices = new ArrayList(edge.getVertices());
        Collections.reverse(reversedVertices);
        return vertices.equals(reversedVertices);
    }
    
    
    /**
    * Find point in edge closest to specified position
    * @param position  Position to find closest point
    * @return closest point position in edge 
    */
    public PVector findClosestPoint(PVector position) {
        Float minDistance = Float.NaN;
        PVector closestPoint = null;
        for(int i = 1; i < vertices.size(); i++) {
            PVector projectedPoint = Geometry.scalarProjection(position, vertices.get(i-1), vertices.get(i));
            float distance = PVector.dist(position, projectedPoint);
            if(minDistance.isNaN() || distance < minDistance) {
                minDistance = distance;
                closestPoint = projectedPoint;
            }
        }
        return closestPoint;
    }
    
    
    /**
    * Divide a edge by a new Node if it matches with any edge's vertex position. Connect to the node, and create
    * a new edge from new node to actual final node.
    * @param node  New node to divide edge by
    * @return true if edge was succesfully divided, false otherwise
    */
    protected boolean divide(Node node) {
        int i = vertices.indexOf(node.getPosition());
        if(i > 0 && i < vertices.size()-1) {
            ArrayList<PVector> dividedVertices = new ArrayList( vertices.subList(i, vertices.size()) );
            node.connect(finalNode, dividedVertices, name, access);
            vertices = new ArrayList( vertices.subList(0, i+1) );
            finalNode = node;
            distance = calcLength();
            return true;
        }
        return false;
    }
    
    
    /**
    * Split a edge by a new Node if its position is in edge. Connect to the node, and create
    * a new edge from new node to actual final node.
    * @param node New node to split edge by
    * @return true if edge was succesfully splited, false otherwise
    */
    protected Node split(Node node) {
        if( node.getPosition().equals(vertices.get(0)) ) return initNode;
        else if( node.getPosition().equals(finalNode.getPosition()) ) return finalNode;
        for(int i = 1; i < vertices.size(); i++) {
            if( Geometry.inLine(node.getPosition(), vertices.get(i-1), vertices.get(i)) ) {
                
                ArrayList<PVector> splittedVertices = new ArrayList();
                splittedVertices.add(node.getPosition());
                splittedVertices.addAll( vertices.subList(i, vertices.size()) );
                node.connect(finalNode, splittedVertices, name, access);
                
                vertices = new ArrayList( vertices.subList(0, i) );
                vertices.add(node.getPosition());
                finalNode = node;
                distance = calcLength();
                return node;
            }
        }
        return null;
    }
    
    
    /**
    * Draw edge, applying color settings depending on data to show
    * @param canvas  Canvas to draw edge
    * @param stroke  Edge width in pixels
    * @param c  Edge color
    */
    public void draw(PGraphics canvas, int stroke, color c) {
        color occupColor = lerpColor(c, #FF0000, occupancy);    // Edge occupancy color interpolation
        canvas.stroke(occupColor, 127); canvas.strokeWeight(stroke);
        for(int i = 1; i < vertices.size(); i++) {
            PVector prevVertex = vertices.get(i-1);
            PVector vertex = vertices.get(i);
            canvas.line(prevVertex.x, prevVertex.y, vertex.x, vertex.y); 
        }
    }
    
    
    /**
    * Add reference to an agent that is crossing in the edge. Recalculate occupancy
    * @param agent  The agent crossing the edge
    */
    public void addAgent(Agent agent) {
        crowd.add(agent);
        occupancy = (float) crowd.size() / maxCrowd;
    }
    
    
    /**
    * Remove reference to agent that was crossing in the edge, but it's not anymore. Recalculate occupancy
    * @param agent  The agent that was crossing the edge
    */
    public void removeAgent(Agent agent) {
        crowd.remove(agent);
        occupancy = (float) crowd.size() / maxCrowd;
    }
    
    
    /**
    * Return edge description (NAME and VERTICES count)
    * @return edge description
    */
    @Override
    public String toString() {
        return name + " with " + vertices.size() + "vertices [" + vertices + "]";
    }
    
}
