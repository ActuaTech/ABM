/**
* Agents - Facade to simplify manipulation of agents in simulation
* @author        Marc Vilella
* @version       1.0
* @see           Facade
*/
public class Agents extends Facade<Agent> {
    
    private float speed;
    private float maxSpeed = 5; 
    
    
    /**
    * Initiate agents facade with provided factory
    */
    public Agents(Factory factory) {
        super(factory);
    }

    
    /**
    * Set agents movement speed
    * @param speed  Speed of agents in pixels/frame
    * @param maxSpeed  Maximum agents' speed
    */
    public void setSpeed(float speed, float maxSpeed) {
        this.maxSpeed = maxSpeed;
        this.speed = constrain(speed, 0, maxSpeed);
    }
    
    
    /**
    * Increment or decrement agents' speed
    * @param inc  Speed increment (positive) or decrement (negative)
    */
    public void changeSpeed(float inc) {
        speed = constrain(speed + inc, 0, maxSpeed);
    }
    
    
    /**
    * Gets the agents' speed
    * @return speed in pixels/frame
    */
    public float getSpeed() {
        return speed;
    }


    /**
    * Move agents
    * @see Agent
    */
    public void move() {
        for(Agent agent : items) {
            agent.move(speed);
        }
    }

}




/**
* AgentFactory - Factory to generate diferent agents from diferent sources 
* @author        Marc Vilella
* @version       1.0
* @see           Factory
*/
private class AgentFactory extends Factory {
    
    /**
    * Load Agents from a file
    * @param file    File with agents' definitions
    * @param roads   Roads where agents will be places
    * @return a list fo new agents
    */
    public ArrayList<Agent> load(File file, Roads roads) {

        print("Loading agents... ");
        ArrayList<Agent> agents = new ArrayList();
        int count = count();
        
        JSONArray JSONagents = loadJSONObject(file).getJSONArray("agents");
        for(int i = 0; i < JSONagents.size(); i++) {
            JSONObject agentGroup = JSONagents.getJSONObject(i);
            
            int id            = agentGroup.getInt("id");
            String name       = agentGroup.getString("name");
            String type       = agentGroup.getString("type");
            int amount        = agentGroup.getInt("amount");
            
            JSONObject style  = agentGroup.getJSONObject("style");
            String tint       = style.getString("color");
            int size          = style.getInt("size");
            
            for(int j = 0; j < amount; j++) {
                Agent agent = null;
                
                if(type.equals("PERSON")) agent = new Person(count, roads, size, tint);
                if(type.equals("CAR")) agent = new Vehicle(count, roads, size, tint);
                
                if(agent != null) {
                    agents.add(agent);
                    counter.increment(name);
                    count++;
                }
            }
        }
        println("LOADED");
        return agents;
    }
    
}




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




/**
* Person -  Person is the main pedestrian agent in ABM, it walks and goes to POIs
* @author        Marc Vilella
* @version       1.0
* @see           Agent
*/
private class Person extends Agent {

    /**
    * Initiate agent with default parameters
    * @see Agent
    */
    public Person(int id, Roads map, int size, String hexColor) {
        super(id, map, size, hexColor);
    }
    
    
    /**
    * Draw Person in screen, with different effects depending on its status
    * @param canvas  Canvas to draw person
    */
    public void draw(PGraphics canvas) {
        
        // Draw aurea, path and some info if agent is selected
        if(selected) {
            path.draw(canvas, 1, COLOR);
            canvas.fill(COLOR, 130); canvas.noStroke();
            canvas.ellipse(pos.x, pos.y, 4 * SIZE, 4 * SIZE);
            //fill(0);
            //text(round(distTraveled) + "/" + round(path.getLength()), pos.x, pos.y);
        }
        
        // Draw exploding effect and line to destination if in panicMode
        if(panicMode) {
            drawPanic(canvas);
            PVector destPos = destination.getPosition();
            canvas.stroke(#FF0000, 100); canvas.strokeWeight(1);
            canvas.line(pos.x, pos.y, destPos.x, destPos.y);
            canvas.text(destination.NAME, pos.x, pos.y);
        }
        
        canvas.fill(COLOR); canvas.noStroke();
        canvas.ellipse(pos.x, pos.y, SIZE, SIZE);
    }


    /**
    * Init [waiting]timer when agent arrives to destination
    */
    protected void whenArrived() {
        timer = millis();
    }
    

    /**
    * Agent stays wandering in destination for a determined time, and then
    * looks for another destination
    */
    protected void whenHosted() {
        wander(5);
        if(millis() - timer > 2000) {
            panicMode = false;
            destination.unhost(this);    // IMPORTANT! Unhost agent from destination
            destination = findDestination();
        }
    }

}



/**
* Vehicle -  Vehicle is the main vehicle agent in ABM, it drives and cannot go to people's POIs, but (p.e) parkings
* @author        Marc Vilella
* @version       1.0
* @see           Agent
*/
private class Vehicle extends Agent {
    
    /**
    * Initiate agent with default parameters
    * @see Agent
    */
    public Vehicle(int id, Roads map, int size, String hexColor) {
        super(id, map, size, hexColor);
        speedFactor = 3;
    }
    
    
    /**
    * Draw Vehicle in screen, with different effects depending on its status
    * @param canvas  Canvas to draw agent
    */
    public void draw(PGraphics canvas) {
        
        // Draw aurea, path and some info if agent is selected
        if(selected) {
            path.draw(canvas, 1, COLOR);
            canvas.fill(COLOR, 130); canvas.noStroke();
            canvas.ellipse(pos.x, pos.y, 4 * SIZE, 4 * SIZE);
            canvas.text(destination.NAME, pos.x, pos.y);
        }
        
        canvas.noFill(); canvas.stroke(COLOR); canvas.strokeWeight(1);
        canvas.ellipse(pos.x, pos.y, SIZE, SIZE);
    }
    
    
    /** Do nothing */
    protected void whenArrived() {}
    
    
    /** Do nothing */
    protected void whenHosted() {}

}
