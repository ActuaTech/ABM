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
