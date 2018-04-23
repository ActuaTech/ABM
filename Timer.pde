/**
* Timer -  Class that manage time during all the simulation 
* @author        Guillem Francisco
* @version       0.1
*/

class Timer{
  
    private int lastLoopTime;
    private float speedFactor;
    private float speed;
    private float limitSpeed;
  
    private DateTime initTime;
    private DateTime endTime;
    private DateTime currentTime;
    
    private boolean running = false;
  
  
    /**
    * Initiate timer, defining the start and end time and the speedFactor of the simulation
    * @param initTime  Simulation initialization time
    * @param endTime  Simulation end time
    * @param speedFactor  Factor to speed-up or slow-down the simulation speed
    */
    Timer (DateTime initTime, DateTime endTime, float speedFactor) {
      this.initTime = initTime;
      this.endTime = endTime;
      this.speedFactor = speedFactor;
      
    }
    
    
    /**
    * Get the elapsed time since the beginning of the simulation
    * @return time in millis
    */
    private int getElapsedTime() {
      return millis();
    }
   
   
    /**
    * Initialize the timer
    */
    public void initTimer() {
      lastLoopTime = getElapsedTime();
      running = true;
      
      currentTime = initTime;
    }
   
   
    /**
    *Run the timer
    */
    public void runTimer() {   
      if(running && currentTime.isBefore(endTime)) {
          speed = (60 * getDelta()) * speedFactor;           // Correct the fluctuation on the framerate
          currentTime = currentTime.plusMillis(int(speed));
      }else {
          stopTimer();
      }
    }
    
    
    /**
    *Stop the timer
    */
    public void stopTimer() {
      changeSpeedFactor(0);
      running = false;
    }
    
    
    /**
    *Get the difference of time from each loop 
    *@return delta in millis
    */
    public int getDelta() {
       int time = getElapsedTime();
       int delta = time - lastLoopTime;
       lastLoopTime = time;
      
       return delta;
    }
    
    
    /**
    *Get speed with which the simulation time advances
    *@return speed in seconds/loop
    */
    public float getSpeed() {
        return speed/1000;
    }
   
    
    /**
    *Increment or decrement timer speed
    *@param increment  Speed increment (positive) or decrement (negative)
    */
    public void changeSpeedFactor(float increment) {
        speedFactor = constrain(speedFactor + increment, 0, limitSpeed);
    }
    
    
    /**
    *Get current time of the timer
    *@return current DateTime
    */
    public DateTime getCurrentTime() {
      return currentTime;
    }
}
