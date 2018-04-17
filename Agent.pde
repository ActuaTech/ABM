/**
* Agent -  Abstract class describing the minimum ABM unit in simulation. Agent can move thorugh lanes and perform some actions
* @author        Marc Vilella
* @version       2.0
*/
public abstract class Agent implements Placeable {

    public final int ID;
    protected final int SIZE;
    protected final color COLOR;
    
    protected int speedFactor = 1;
    protected int explodeSize = 0;
    protected int timer = 0;
    
    protected boolean selected = false;
    protected boolean arrived = false;
    protected boolean panicMode = false;
    
    protected POI destination;
    protected PVector pos;
    protected Path path;
    protected Node inNode;
    protected float distTraveled;
    
    
    /**
    * Initiate agent with specific size and color to draw it, and places it in defined roadmap
    * @param id  ID of the agent
    * @param roads  Roadmap to place the agent
    * @param size  Size of the agent
    * @param hexColor  Hexadecimal color of the agent
    */
    public Agent(int id, Roads roads, int size, String hexColor) {
        ID = id;
        SIZE = size;
        COLOR = unhex( "FF" + hexColor.substring(1) );

        path = new Path(this, roads);
        place(roads);
        destination = findDestination();
    }

    
    /**
    * Place agent in roadmap. Random node by default
    * @param roads  Roadmap to place the agent
    */
    public void place(Roads roads) {
        //inNode = roads.getRandom();
        ArrayList<Node> possible = roads.filter(Filters.isAllowed(this));
        inNode = possible.get( round(random(0, possible.size()-1)) );
        pos = inNode.getPosition();
    }
    
    
    /**
    * Get agent position in screen
    * @return agent position
    */
    public PVector getPosition() {
        return pos.copy();
    }
    
    
    /** 
    * Check if agent is moving
    * @return true if agent is moving, false if has arrived to destination
    */
    public boolean isMoving() {
        return !arrived;
    }
    
    
    /**
    * Find best POI destination based in agent's preferences
    * @return POI destination
    */
    public POI findDestination() {
        path.reset();
        arrived = false;
        POI newDestination = null;
        ArrayList<POI> possible = pois.filter(Filters.isAllowed(this));
        while(newDestination == null || inNode.equals(newDestination)) {
            newDestination = possible.get( round(random(0, possible.size()-1)) );    // Random POI for the moment
        }
        return newDestination;
    }
    
    
    /*
    * Move agent across the path at defined speed
    * @param speed  Speed in pixels/frame
    */
    public void move(float speed) {
        if(!arrived) {
            if(!path.available()) panicMode = !path.findPath(inNode, destination);
            else {
                PVector movement = path.move(pos, speed * speedFactor);
                pos.add( movement );
                distTraveled += movement.mag();
                inNode = path.inNode();
                if(path.hasArrived()) {
                    if(destination.host(this)) {
                        arrived = true;
                        whenArrived();
                    } else whenUnhosted();
                }
            }
        } else whenHosted();
    }
    
    
    /**
    * Move agent in random chaotic movement around its position
    * @param maxR  Maximum radius of movement
    */
    protected void wander(int maxRadius) {
        float radius = arrived ? destination.getSize() / 2 : maxRadius;
        pos = inNode.getPosition().add( PVector.random2D().mult( random(0, radius)) );
    }
    
    
    /**
    * Select agent if mouse is hover
    * @param mouseX  Horizontal mouse position in screen
    * @param mouseY  Vertical mouse position in screen
    * @return true if agent is selected, false otherwise
    */
    public boolean select(int mouseX, int mouseY) {
        selected = dist(mouseX, mouseY, pos.x, pos.y) < SIZE;
        return selected;
    }
    
    
    /**
    * Draw agent in panic mode (exploding effect)
    * @param canvas  Canvas to draw agent
    */
    protected void drawPanic(PGraphics canvas) {
        canvas.fill(#FF0000, 50); canvas.noStroke();
        explodeSize = (explodeSize + 1)  % 30;
        canvas.ellipse(pos.x, pos.y, explodeSize, explodeSize);
    }
    
    
    /**
    * Return agent description (ID, DESTINATION, PATH)
    * @return agent description
    */
    public String toString() {
        String goingTo = destination != null ? "GOING TO " + destination + " THROUGH " + path.toString() : "ARRIVED";
        return "AGENT " + ID + " " + goingTo;
    }
    
    
    /**
    * Actions to perform when agent cannot be hosted by destination.
    * By default, to look for another destination
    */
    protected void whenUnhosted() {
        destination = findDestination();
    }
    
    
    /** Actions to perform WHEN agent arrives to destination */
    protected abstract void whenArrived();
    
    /** Actions to perform WHILE agent is in destination */
    protected abstract void whenHosted();
    
    /** Draw agent in screen */
    public abstract void draw(PGraphics canvas);
    
    
}
