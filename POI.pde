/**
* POI -  Abstract class describing a Point of Interest, that is a destination for agents in simulation
* @author        Marc Vilella
* @version       2.0
*/
public class POI extends Node {

    protected final String ID;
    protected final String NAME;
    protected final int CAPACITY;
    protected final Accessible access;
    
    protected ArrayList<Agent> crowd = new ArrayList();
    protected float occupancy;
    
    private float size = 2;
    
    
    /**
    * Initiate POI with specific name and capacity, and places it in the roadmap
    * @param roads      Roadmap to place the POI
    * @param id         ID of the POI
    * @param position   Position of the POI
    * @param name       Name of the POI
    * @param capacity   Customers capacity of the POI
    */
    public POI(NodeFacade roads, String id, String name, String type, PVector position, int capacity) {
        super(position);
        ID = id;
        NAME = name;
        CAPACITY = capacity;
        access = Accessible.create(type);
        
        place(roads);
    }
    
    
    /**
    * Place POI into roadmap, connected to closest point
    * @param roads    Roadmap to place the POI
    */
    @Override
    public void place(NodeFacade roads) {
        roads.connect(this);
    }
    
    
    /**
    * Get POI drawing size
    * @return POI size
    */
    public float getSize() {
        return size;
    }
    
    
    @Override
    public boolean allows(Agent agent) {
        return access.allows(agent);
    }
    
    
    /**
    * Add agent to the hosted list as long as POI's crowd is under its maximum capacity, meaning agent is staying in POI
    * @param agent  Agent to host
    * @return true if agent is hosted, false otherwise
    */
    public boolean host(Agent agent) {
        if(this.allows(agent) && crowd.size() < CAPACITY) {
            crowd.add(agent);
            update();
            return true;
        }
        return false;
    }
    
    
    /**
    * Remove agent from hosted list, meaning agent has left the POI
    * @param agent  Agent to host
    */
    public void unhost(Agent agent) {
        crowd.remove(agent);
        update();
    }
    
    
    /**
    * Update POIs variables: occupancy and drawing size
    */
    protected void update() {
        occupancy = (float)crowd.size() / CAPACITY;
        size = (5 + 10 * occupancy);
    }
    
    
    /**
    * Draw POI in screen, with different effects depending on its status
    * @param canvas  Canvas to draw node
    * @param stroke  Edge width in pixels
    * @param c  Edges color
    */
    @Override
    public void draw(PGraphics canvas, int stroke, color c) {
        
        color occColor = lerpColor(#77DD77, #FF6666, occupancy);
        
        canvas.rectMode(CENTER); canvas.noFill(); canvas.stroke(occColor); canvas.strokeWeight(2);
        canvas.rect(POSITION.x, POSITION.y, size, size);
        
        if( selected ) {
            canvas.fill(0); canvas.textAlign(CENTER, BOTTOM);
            canvas.text(this.toString(), POSITION.x, POSITION.y - size / 2);
        }

    }


    /**
    * Select POI if mouse is hover
    * @param mouseX  Horizontal mouse position in screen
    * @param mouseY  Vertical mouse position in screen
    * @return true if POI is selected, false otherwise
    */
    @Override
    public boolean select(int mouseX, int mouseY) {
        selected = dist(POSITION.x, POSITION.y, mouseX, mouseY) <= size;
        return selected;
    }
    
    
    /**
    * Return agent description (NAME, OCCUPANCY and CAPACITY)
    * @return POI description
    */
    @Override
    public String toString() {
        return NAME + " [" + crowd.size() + " / " + CAPACITY + "]";
    }
    
}
