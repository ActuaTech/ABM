public class RoadFactory extends Factory {
    
    /**
    * Load roads from a file
    * @param file    File with roads definitions
    * @param roads   Roads where POIs will be places
    * @return a list fo new POIs
    */
    public ArrayList<Node> load(File file, Roads roads) {
        
        print("Loading roads network... ");
        JSONObject roadNetwork = loadJSONObject(file);
        JSONArray lanes = roadNetwork.getJSONArray("features");
        for(int i = 0; i < lanes.size(); i++) {
            JSONObject lane = lanes.getJSONObject(i);
            
            JSONObject props = lane.getJSONObject("properties");
            Accessible access = props.isNull("type") ? Accessible.ALL : Accessible.create( props.getString("type") );
            String name = props.isNull("name") ? "null" : props.getString("name");
            boolean oneWay = props.isNull("oneway") ? false : props.getInt("oneway") == 1 ? true : false;
            String direction = props.isNull("direction") ? null : props.getString("direction");
      
            JSONArray points = lane.getJSONObject("geometry").getJSONArray("coordinates");
            
            Node prevNode = null;
            ArrayList vertices = new ArrayList();
            for(int j = 0; j < points.size(); j++) {
            
                PVector point = roads.toXY(points.getJSONArray(j).getFloat(1), points.getJSONArray(j).getFloat(0));
                
                if( roads.contains(point) ) {
                    vertices.add(point);
                    
                    Node currNode = getNodeIfVertex(roads, point);
                    if(currNode != null) {
                        if(prevNode != null && j < points.size()-1) {
                            if(oneWay) prevNode.connect(currNode, vertices, name, access);
                            else prevNode.connectBoth(currNode, vertices, name, access);
                            vertices = new ArrayList();
                            vertices.add(point);
                            prevNode = currNode;
                        }
                    } else currNode = new Node(point);
                    
                    if(prevNode == null) {
                        prevNode = currNode;
                        currNode.place(roads);
                    } else if(j == points.size()-1) {
                        if(oneWay) prevNode.connect(currNode, vertices, name, access);
                        else prevNode.connectBoth(currNode, vertices, name, access);
                        currNode.place(roads);
                        if(direction != null) currNode.setDirection(direction);
                    }
                }
                
            }
        }
        println("LOADED");
        return new ArrayList();
    }
    
    
    /**
    * Get a node if a position matches with an already existing vertex in roadmap
    * @param position  Position to compare with all vertices
    * @return a new created (not placed) node if position matches with a vertex, an already existing node if position matches with it, or
    * null if position doesn't match with any vertex
    */
    private Node getNodeIfVertex(Roads roads, PVector position) {
        for(Node node : roads) {
            if( position.equals(node.getPosition()) ) return node;
            for(Lane lane : node.outboundLanes()) {
                if( position.equals(lane.getEnd().getPosition()) ) return lane.getEnd();
                else if( lane.contains(position) ) {
                    Lane laneBack = lane.findContrariwise();
                    Node newNode = new Node(position);
                    if(lane.divide(newNode)) {
                        if(laneBack != null) laneBack.divide(newNode);
                        newNode.place(roads);
                        return newNode;
                    }
                }
            }
        }
        return null;
    }

}
