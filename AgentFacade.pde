/**
* Agents - Facade to simplify manipulation of agents in simulation
* @author        Marc Vilella
* @version       1.0
* @see           Facade
*/
public class AgentFacade extends Facade<Agent> {
    
    private float speed;
    private float maxSpeed = 5; 
    
    
    /**
    * Initiate agents facade with provided factory
    */
    public AgentFacade(Factory factory) {
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
