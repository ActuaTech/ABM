/**
* Filters - Static class containing multiple Predicate filters
* @author        Marc Vilella
* @version       1.0
*/
public static class Filters {

    /**
    * Check if item's position is closer than a specific distance to a point
    * @param point  Point to check distance to
    * @param distance  Maximum distance to the point
    * @return a predicate where true if item position is closer than distance, false otherwise
    */
    public static Predicate<Agent> closeToPoint(final PVector point, final int distance) {
        return new Predicate<Agent>() {
            public boolean evaluate(Agent agent) {
                return point.dist(agent.getPosition()) < distance;
            }
        };
    }
    
    
    /**
    * Check if item is moving or stopped
    * @param moving  True if want to check the agent being moving, false if want to check agent being stopped
    * @return a predicate where true if item matches with moving query
    */
    public static Predicate<Agent> isMoving(final boolean moving) {
        return new Predicate<Agent>() {
            public boolean evaluate(Agent agent) {
                return agent.isMoving() == moving;
            }
        };
    }
    
    
    public static <T extends Node> Predicate isAllowed(final Agent agent) {
        return new Predicate<T>() {
            public boolean evaluate(T item) {
                return item.allows(agent);
            }
        };
    }
    
    
}
