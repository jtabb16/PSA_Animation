/* PSA_Animation
 * Author: Jack Tabb
 * Date Created: 2018-10-16
 * Date Last Edited: 2022-02-01
 * Purpose: Provide an animation for a Pressure-Swing Adsorption (PSA) process by visually representing the amounts of species over time.
 * Note: setup() and draw() automatically run.
 *       -- setup() - runs once. 
 *       -- draw() - runs after setup(). Runs indefinitely at the specified frameRate
*/

/* Dependencies:
*  Using version 3.5.4 of Processing (Java)
*  Using the Processing IDE
*  
*  Need G4P library for Sliders, Buttons, Text Fields, etc.
*  Using G4P version 4.3.6
*  To Install it, go to Sketch -> Import Library ... -> Add Library ... -> (Search for G4P) -> Install G4P by Peter Lager
*  
*  Need java util for data structures such as Lists, Sets, etc.
*/
import g4p_controls.*;
// For Lists, Sets, ...
import java.util.*;


// Variables used only in PSA_Animation.pde
int numTimePts; // The number of time points is the number of rows in the data file

int numVarPerCSTR = 4; // Can change this value in Config file. Default is 4 variables per CSTR: ThetaA, ThetaB, QA, QB
int numLK = 0; // Number of light keys
int numComp = 0; // Number of components
int numPhase = 0; // Number of phases

boolean fRateTooFast = false;

// Variables used inside and outside of PSA_Animation.pde
PhaseGroup phaseGroup; // Used in Control_GUI
Control_GUI animation_controls; // Used in Control_GUI -- In a really stupid way. This needs to be fixed ASAP

// NOTE: timepoint is controlled by the GUI. Each PhaseGroup will need to have its own set of GUI controls. The time slider, etc. will be specific to the PhaseGroup.
int timepoint; // Current timepoint the animation is working with -- value set in GUI
float animation_framerate_multiplier; // Used in Control_GUI (Value set in GUI)
float maxRate;
// float maxTime;
// float stepTime;
// float maxStepTime;
Boolean play_animation; // Used in Control_GUI (Value set in GUI)



ComponentType component; // A universal value in the program for knowing which state to run the animation in. TODO: Instead of doing lots of if statements based on these, see if I can do polymorphism to dynamically and flexibly change the program's state.
float phaseGroupWidth, drawableColWidth, phaseGroupHeight;
float widthScaleFactor;

ArrayList<Phase> phaseList;

List componentList;


XML config; // Configuration file

/* Initialize some things before performing setup */
void settings() {
  // Load the local file that lets users configure the animation without editing code.
  config = loadXML("config.xml");
  
  // Get the width and height for the resolution of the window
  XML res = config.getChild("resolution");
  final int w = res.getInt("width");
  final int h = res.getInt("height");
  size (w, h); // Set the resolution of the window
  
  // Get the number of variables
  XML stateMatrixInfo = config.getChild("stateMatrixInfo");
  numLK = stateMatrixInfo.getInt("numLightKeys");
  numComp = stateMatrixInfo.getInt("numComp");
  numPhase = stateMatrixInfo.getInt("numPhases");
  numVarPerCSTR = numComp * numPhase;
  
  
  // Look at the config file to determine where the data is for stateMatrix, timeMatrix, volFlowMatrix, etc.
  // Then, load it from there in the setup() function
  
}

/* Set up the animation */
void setup() {
  println("Welcome to the Animation!");
  printInstructions ();
  
  // Set the speed to play the animation to make it easier to see what is happening
  // Note: You won't see a difference past a certain point because your processor 
  //        isn't fast enough to output frames above a certain rate.
  frameRate(5); // 1 frame per second, 60fps, 1000fps, etc. Let the user choose. Currently set to 5 fps.
  
  XML dataFileNames = config.getChild("datafiles");
  String stateMatrixName = dataFileNames.getString("stateMatrix");
  String timeMatrixName = dataFileNames.getString("timeMatrix");
  String volFlowMatrixName = dataFileNames.getString("volFlowMatrix");
  
  // Initialize the global variables
  // TODO: Add check for size of file. If it's too big and will consume more RAM than what is available to the computer, output a warning message
  //          and suggest the user runs the simulation with less CSTRs and / or less timepoints to generate less data for the animation to load.
  Table stateMatrix = loadTable("data/" + stateMatrixName + ".csv", "csv");
  Table timeMatrix = loadTable("data/" + timeMatrixName + ".csv", "csv");
  Table volFlowMatrix = loadTable("data/" + volFlowMatrixName + ".csv", "csv");
  // TODO: Implement Processing's optional 'dictionary=filename.tsv' so the users can specify which data type is in each column of the table file.
  
  stateMatrix.setTableType("float");
  // timeMatrix.setTableType("");
  volFlowMatrix.setTableType("float");
  println("Finished Loading Data.");
  numTimePts = stateMatrix.getRowCount();
  timepoint = 0;
  
  // Construct the phase with a set of data. Specify the width and height of the phase, too.
  // phaseGroupWidth = 5*(width/6);
  phaseGroupWidth = 2*(width/3);
  phaseGroupHeight = 3*(height/5);
  
  Arrows arrows = new Arrows(volFlowMatrix, phaseGroupHeight);
  widthScaleFactor = 1.0/2.0;
  //drawableColWidth = widthScaleFactor*phaseGroupWidth;
  drawableColWidth = phaseGroupWidth/numPhase;
  
  
  phaseList = new ArrayList<Phase> ();
  //for (int i = 0; i < numPhase; i++) {
    // phaseList.add(....);
  //}
  
  // Make the function only give one color, but feed it something so that I get a pallete here.
  Component comp = new Component();
  color[] colorPalette = comp.genColorPalette(numComp);
  
  // Form list of all components
  componentList = new ArrayList<Component> ();
  // Add light keys
  Component c = new Component();
  
  //for (int j = 0; j < numLK; j++) {
  //  // componentList.add(new Component(ComponentType.LK, j, colorPalette[j]));
  //  componentList.add(new Component(ComponentType.LK, j, c.getLKColor()));
  //  //println("j: " + j);
  //}
  //// Add heavy keys
  //for (int j = numLK; j < numComp; j++) {
  //  // componentList.add(new Component(ComponentType.HK, (j+numLK), colorPalette[j+numLK]));
  //  componentList.add(new Component(ComponentType.HK, j, c.getHKColor()));
  //  //println("j: " + j);
  //}
  
  componentList.add(new Component(ComponentType.HK, numLK, c.getHKColor()));
  componentList.add(new Component(ComponentType.LK, 0, c.getLKColor()));
  
  //println("Component List: " + componentList.toString());
  
  // NOTE: DO NOT add / remove components from this componentList. If I want to see a different group of components, then change the lists that are in the phase.
  phaseList.add(new Phase( stateMatrix, volFlowMatrix, drawableColWidth, phaseGroupHeight, PhaseType.FLUID, 0, componentList, numVarPerCSTR));
  phaseList.add(new Phase( stateMatrix, volFlowMatrix, drawableColWidth, phaseGroupHeight, PhaseType.SOLID, 1, componentList, numVarPerCSTR));
  
  phaseGroup = new PhaseGroup( phaseGroupWidth, phaseGroupHeight, stateMatrix, volFlowMatrix, timeMatrix, phaseList, arrows );
  phaseGroup.setNormalizationFactors();
  
  
  // maxStepTime = phaseGroup.getTimeFactor();
  
  // Construct the GUIs
  // animation_config = new Config_GUI(this);  // In this case, "this" is the PApplet for this animation
  animation_controls = new Control_GUI(this);
  
  // Display the start times of each step in the simulation
  // TODO: Put this stuff into its own function in PSA_Animation
  //String steps = "";
  //Map <String, ArrayList<String>> stepTimePoints = phaseGroup.getStepTimePoints();
  List <Step> stepList = new ArrayList(phaseGroup.getStepList());
  // println(stepList);
  Collections.sort(stepList);
  // println(stepList);
  String stepTimesString = "";
  String prevName = "";
  for (Step step : stepList) {
    if ( (step.getName()).equals(prevName) ) { // If we're already listing this type of phase
      stepTimesString += step.getStartTime() + ", ";
    } else { // Listing new type of phase
      stepTimesString += "\n" + step.getName() + ": ";
      stepTimesString += step.getStartTime() + ", ";
      prevName = step.getName();
    }
  }
  
  // Calculate max rate
  //maxRate = 0f;
  //maxTime = 0f;
  //for (Step step : stepList) {
  //  if (step.getRate() > maxRate) {
  //    maxRate = step.getRate();
  //    maxTime = step.getDuration();
  //  }
  //}
  
  animation_controls.printStepTimes(stepTimesString);
  
  // Set initial values that can be changed by GUI
  play_animation = true;
  animation_framerate_multiplier = 1;
  // stepTime = phaseGroup.getStepLength(0);
  // stepTime = 90
  component = ComponentType.ALL_COMP;
  updateFrameRate(phaseGroup.getStepList().get(0).getRate());
  // updateFrameRate(phaseGroup.getStepList().get(0).getDuration(), maxRate, maxTime);
  // frameRate(20);
  handleGUI();
  
  println("Initialization Completed. Enjoy using the Animation!");
}

/* Run the animation */
void draw() {
  colorMode(RGB, 255, 255, 255);
  background(#f1d592); // tan background
  // text(int(frameRate),100,200); // Display current FPS
  // Display the timepoint (We don't know the actual time. Just the timepoint)
  textSize(32);
  textAlign(LEFT, TOP);
  // fill(255);
  fill(0); // Font color
  
  float currentTime = phaseGroup.calcTime(timepoint);
  // Display the current time point out of how many time points there are
  text("Timepoint: " + String.format("%04d", timepoint) + "(" + String.format("%05.1f", currentTime) + "s)" +
        " / " + phaseGroup.calcNumTimePts() + "(" + String.format("%05.1f", phaseGroup.calcTime(phaseGroup.calcNumTimePts()-1)) + "s)", 0, 0);
  
  // Normalize the dynamics of the system. Make the animation of each step use the same time base and real-world framerate. (Look at time instead of timepoint)
  // stepTime = phaseGroup.getStepLength(currentTime);
  // frameRate(animation_framerate_multiplier*(1*maxStepTime/stepTime));
  
  updateFrameRate(phaseGroup.getStep(timepoint).getRate());
  // updateFrameRate(phaseGroup.getStep(timepoint).getDuration(), maxRate, maxTime);
  // println("timepoint: " + timepoint + ", rate: " + phaseGroup.getStep(timepoint).getRate());
  
  handleGUI();
  float xCoord = width/2;
  // float xCoord = 2*width/3;
  float yCoord = phaseGroupHeight/2+height/2;
  
  // Draw the PSA column's basic shape
  shapeMode(CENTER);
  fill(255);
  shape(phaseGroup.drawPhaseGroupFoundation(), width/2, height/2);
  
  // Draw the current state of the PSA column's compositions (Different components and phases) at this timepoint
  shapeMode(CORNER);
  // Draw the fluid phase at this timepoint
  pushMatrix();
    translate(xCoord,0);
    scale(-1.0, 1.0); // Mirror across the y-axis
    // shape(fluidPhase.drawColContents(timepoint), 0, yCoord);
    // PShape phaseShape;
    shape(phaseList.get(0).drawColContents(timepoint), 0, yCoord);
  popMatrix();
  
  // Draw the solid phase at this timepoint
  // shape(solidPhase.drawColContents(timepoint), xCoord, yCoord);
  // shape(phaseGroup.drawPhase(PhaseType.SOLID), xCoord, yCoord);
  shape(phaseList.get(1).drawColContents(timepoint), xCoord, yCoord);
  
  // Draw the arrows for indicating volumetric flowrate
  //PShape arrowsAtThisTimept = arrows.drawArrows(timepoint, volFlowMatrix, fluidPhase.getFirstCSTRColor(), fluidPhase.getLastCSTRColor());
  //shape(arrowsAtThisTimept, width/2, height/2);
  shape(phaseGroup.drawPhaseGroupArrows(), width/2, height/2);
  
  phaseGroup.drawLabels(xCoord, yCoord);
  
  // phaseGroup.drawCustomLabels();
  
  // Establish the current timepoint.
  timepoint++;
  timepoint = (timepoint % numTimePts); // Cycle back to the beginning timepoint when necessary
  // TODO: Move timepoint and numTimePts to PhaseGroup. If we have multiple phase groups, then they'll each have their own timepoints.
  
  drawLegend(componentList);
}

/* Draw Legend for Colors */
void drawLegend(List <Component> compList) {
  for (Component comp : compList) {
    // println(comp.getColor());
  }
}

/* Draw positioning grid */
void drawGrid(int numRows, int numCols) {
  for (int x = 1; x < numRows; x++) {
    line(0, x*(height/numRows), width, x*(height/numRows));
  }
  for (int x = 1; x < numCols; x++) {
    line(x*(width/numCols), 0, x*(width/numCols), height);
  }
}

// Handle things changed in GUI
void handleGUI() {
  if (play_animation) { 
    loop();
  } else { 
    noLoop();
  }
  // Update the component types when user changes the options from the control panel
  // Temporarily edited out as of 8/19/2021 -- Need to implement more before re-enabling this feature
  // phaseGroup.updatePhaseCompType(component);
}

// void updateFrameRate(float step_duration, float max_rate, float max_time) {
void updateFrameRate(float step_rate) {
  // float fRate = animation_framerate_multiplier*(cur_rate/max_rate);
  // float fRate = animation_framerate_multiplier*(max_rate / cur_rate);
  float fRate = animation_framerate_multiplier*1/step_rate;
  if (fRateTooFast == false && fRate > 1000.0) {
    println("Err: fRate too fast for consistent dynamics. Turn down speed slider.");
    fRateTooFast = true;
  } else {
    fRateTooFast = false;
  }
  // println("New fRate: " + fRate);
  // float fRate = animation_framerate_multiplier*(max_rate*max_time)/step_duration;
  // float fRate = animation_framerate_multiplier*step_duration/(max_rate*max_time);
  // println("frameRate: " + fRate + ", maxRate: " + max_rate);
  frameRate(fRate);
}

/* Print Basic Instructions */
void printInstructions () {
  println("Loading Data...");
  println("Note: If your computer runs out of memory, try running the Matlab simulation with \n\t less CSTRs and / or timepoints to reduce the amount of data this animation loads into memory.");
  println("Note: The more CSTR's you use (up to the number of vertical pixels in the animation window), the smoother each frame of the animation will look.");
  println("Note: The more timepoints you use, the smoother the transition between frames in the animation will be.");
  println("\tThis also means the animation will progress more slowly even if run at high speed.");
  println("\tFor slow computers, maxing out the playback speed slider won't do much.");
  println("\tUsing fewer timepoints may be necessary to achieve a quickly progressing animation.");
  println("Note: When using text fields in the GUI: \n" +
  "1. Select the text field with your mouse. \n" +
  "2. Use your arrow keys to navigate within the text area. Using your mouse and scrollbars is buggy. \n" +
  "3. Instead of right-clicking to copy and paste, use the and 'ctrl+c' and 'ctrl+v' (or 'cmd+c' and 'cmd+v' on Mac)\n" +
  "4. You can use scientific notation such as '5.32e-5'.");
}
