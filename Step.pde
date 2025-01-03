// Jack Tabb
// 10/28/2021

class Step implements Comparable<Step>{
  float rate; // The normalized rate to use for displaying this step on the same time basis as other steps
  int start_tp; // The timepoint in which this step starts
  float start_time; // The time at which this step starts
  String name; // The name of the step. i.e. "High Pressure" or "HP", etc.
  float duration;
  
  Step () {
    this.rate = 0f;
    this.start_tp = 0;
    this.start_time = 0;
    this.name = "";
    this.duration = 0f;
  }
  
  Step (int start_tp, float start_time, String name) {
    this.rate = 0f;
    this.start_tp = start_tp;
    this.start_time = start_time;
    this.name = name;
    this.duration = 0f;
  }
  
  // Custom function to let ArrayList sort function work.
  // Make the steps go in order of step name. If same name, then order by starting timepoint.
  @Override
  public int compareTo(Step compareStep) {
    int difference = 0;
    int strDif = (this.name).compareTo(compareStep.getName()); // Difference in the step names
    
    if (strDif == 0) { // If they're equal
      difference = compareStep.getStartTimePt() - this.start_tp;
      // difference =  this.start_tp - compareStep.getStartTimePt();
    } else {
      difference = strDif;
    }
    
    return difference;
  }

  @Override
  public String toString() {
      return "[" + name + ": startTP=" + start_tp + ", rate=" + rate + "]";
  }
    
  public void calcRate(int stop_tp, float stop_time) {
    // float rate = 0f;
    this.duration = stop_time - start_time;
    // rate = (float)(stop_tp - this.start_tp) / (stop_time - this.start_time);
    rate = (stop_time - this.start_time) / (float)(stop_tp - this.start_tp);
    // println("stop_time: " + stop_time + ", start_time: " + this.start_time + ", stop_tp: " + stop_tp + ", start_tp: " + this.start_tp);
    // return rate;
  }
  
  public float getDuration() {
    return duration;
  }
  
  public float getRate() {
    return rate;
  }
  
  public String getName() {
    return name;
  }
  
  public int getStartTimePt() {
    return start_tp;
  }
  
  public float getStartTime() {
    return start_time;
  }
}
