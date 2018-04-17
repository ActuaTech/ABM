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
