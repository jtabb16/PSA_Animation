/* Control_GUI
 * Author: Jack Tabb
 * Date Created: 2018-10-15
 * Date Last Edited: 2021-02-21
 * Purpose: To handle the drawing and event-listening for the Graphical User Interface (GUI) Elements of the Control Window
 * To edit the GUI:
 *   Uncomment the "gui" tab's code before using G4P GUI Builder. (Use 'ctrl'+'a' to select all text. Then use 'ctrl'+'/' to uncomment everything.)
 *   Go to Tools > "G4P GUI builder"
 *   Do not edit the "gui" tab directly, but take code from it and put it in here. 
 *   Comment out the "gui" tab's code after using the GUI Builder. (Use 'ctrl'+'a' to select all text. Then use 'ctrl'+'/' to comment everything.)
 *   Use the "gui" tab's code as a guide to modify this file's implementation of a gui
*/

class Control_GUI {
  // Declare the GUI Elements:
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////
  //Custom popout window for animation controls (To put this entire class's components on)
  GWindow control_gui;
    // Sliders for dragging to select values
    GCustomSlider myTimeSlider,
                  mySpeedSlider;// Note: Too low of a speed value makes it hard to use the GUI because this speed also effects how fast the GUI responds to input.
    // Button to pause or play the animation.
    GButton playPauseBtn;
    // Labels for the sliders
    GLabel myTimeLabel,
           mySpeedLabel;
    
    // GUI Elements to select component mode:
    //GLabel selectComp_label; 
    //GToggleGroup togGroup1;
    //GOption lightKey; 
    //GOption allComp; 
    //GOption heavyKey; 
    
    // GUI Element for displaying the starting timepoint (and time) of each step
    GLabel stepTimesLabel;
    GTextArea stepTimes;
    
    // GUI Element for specifying a time to jump to
    GLabel jumpTimeLabel;
    GTextField jumpTime;
    
    // GUI Element for specifying where to put custom markers
    GLabel customMarkersSolidLabel;
    GTextArea customMarkersSolidText;
    GLabel customMarkersFluidLabel;
    GTextArea customMarkersFluidText;
    
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  // Data Elements
  List <Float> markerRequestsSolid;
  List <Float> markerRequestsFluid;
  
  
  
  // Construct the Control_GUI window in the Parent PApplet (PSA_Animation)
  Control_GUI(PApplet parent) {
    setupGUI(parent);
  }

  public void setupGUI(PApplet parent) {
    // Setup GUI -- Constructed with aid of gui editor tool
    //=============================================================
    
    // Put the Graphical User Interface (GUI) in a separate window
    control_gui = GWindow.getWindow(parent, "Animation Controls", 10, 10, 600, 600, JAVA2D);
    control_gui.noLoop();
    control_gui.setActionOnClose(G4P.KEEP_OPEN);
    control_gui.addDrawHandler(parent, "win_control_gui");
    
    // Slider for changing how fast the animation runs
    mySpeedSlider = new GCustomSlider(control_gui, 111, 51, 300, 100, "grey_blue");
    mySpeedSlider.setRotation(PI/2, GControlMode.CORNER);
    // mySpeedSlider.setLimits(10000.0, 1000.0, 50000.0);
    mySpeedSlider.setLimits(1, 0.1, 10.0);
    mySpeedSlider.setShowTicks(true);
    mySpeedSlider.setNbrTicks(10);
    mySpeedSlider.setNumberFormat(G4P.DECIMAL, 0);
    mySpeedSlider.setLocalColorScheme(GCScheme.SCHEME_15);
    mySpeedSlider.setOpaque(false);
    mySpeedSlider.setShowDecor(false, true, true, true);
    mySpeedSlider.addEventHandler(parent, "speedSliderEvent");
    
    mySpeedLabel = new GLabel(control_gui, 10, 10, 100, 40);
    mySpeedLabel.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    mySpeedLabel.setText("Playback Speed [FPS]");
    mySpeedLabel.setTextBold();
    mySpeedLabel.setLocalColorScheme(GCScheme.SCHEME_15);
    mySpeedLabel.setOpaque(false);
    
    // Slider for which point in the animation you want to see
    myTimeSlider = new GCustomSlider(control_gui, 210, 50, 300, 100, "grey_blue");
    myTimeSlider.setShowValue(true);
    myTimeSlider.setRotation(PI/2, GControlMode.CORNER);
    myTimeSlider.setLimits(0, 0, numTimePts-1);
    myTimeSlider.setShowTicks(true);
    myTimeSlider.setNbrTicks(5);
    myTimeSlider.setNumberFormat(G4P.INTEGER, 0);
    myTimeSlider.setLocalColorScheme(GCScheme.SCHEME_15);
    myTimeSlider.setOpaque(false);
    myTimeSlider.setShowDecor(false, true, true, true);
    myTimeSlider.addEventHandler(parent, "timeSliderEvent");
    
    myTimeLabel = new GLabel(control_gui, 110, 10, 100, 40);
    myTimeLabel.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    myTimeLabel.setText("Timepoint");
    myTimeLabel.setTextBold();
    myTimeLabel.setLocalColorScheme(GCScheme.SCHEME_15);
    myTimeLabel.setOpaque(false);
    
    // Button to pause or play the animation
    playPauseBtn = new GButton(control_gui, 70, 380, 80, 30, "Pause");
    playPauseBtn.setLocalColorScheme(15); // White theme
    playPauseBtn.setLocalColor(2, color(0)); //Black Text
    playPauseBtn.addEventHandler(parent, "playPauseBtn_click");
    
    // GUI label for selecting component mode
    //selectComp_label = new GLabel(control_gui, 70, 420, 80, 20);
    //selectComp_label.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    //selectComp_label.setLocalColorScheme(15); // White theme
    //selectComp_label.setText("Select Comp");
    //selectComp_label.setTextBold();
    //selectComp_label.setOpaque(false);
    
    // GUI elements for selecting component mode
    //togGroup1 = new GToggleGroup();
    //  lightKey = new GOption(control_gui, 70, 440, 120, 20);
    //  lightKey.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    //  lightKey.setLocalColorScheme(15); // White theme
    //  lightKey.setText("Light Key (LK)");
    //  lightKey.setOpaque(false);
    //  lightKey.addEventHandler(parent, "lightKey_clicked1");
    //  heavyKey = new GOption(control_gui, 70, 460, 120, 20);
    //  heavyKey.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    //  heavyKey.setLocalColorScheme(15); // White theme
    //  heavyKey.setText("Heavy Key (HK)");
    //  heavyKey.setOpaque(false);
    //  heavyKey.addEventHandler(parent, "heavyKey_clicked1");
    //  allComp = new GOption(control_gui, 70, 480, 120, 20);
    //  allComp.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    //  allComp.setLocalColorScheme(15); // White theme
    //  allComp.setText("All Components");
    //  allComp.setOpaque(false);
    //  allComp.addEventHandler(parent, "allComp_clicked1");
    //togGroup1.addControl(lightKey);
    //togGroup1.addControl(heavyKey);
    //togGroup1.addControl(allComp);
    
    // GUI Element for displaying the starting timepoint (and time) of each step
    stepTimesLabel = new GLabel(control_gui, 400, 20, 100, 40);
    stepTimesLabel.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    stepTimesLabel.setLocalColorScheme(15); // White theme
    stepTimesLabel.setText("Start Times of Each Step:");
    stepTimesLabel.setTextBold();
    stepTimesLabel.setOpaque(false);
    stepTimes = new GTextArea(control_gui, 400, 70, 200, 100, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE, 10000); // Last number is wrap width
    //stepTimes.addEventHandler(parent, "stepTimes_change1");
    
    // GUI Element for specifying a time to jump to
    jumpTimeLabel = new GLabel(control_gui, 400, 200, 200, 70);
    jumpTimeLabel.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    jumpTimeLabel.setLocalColorScheme(15); // White theme
    jumpTimeLabel.setText("Specify Dimensional Time (not timepoint) to Jump to:");
    jumpTimeLabel.setTextBold();
    jumpTimeLabel.setOpaque(false);
    jumpTime = new GTextField(control_gui, 400, 250, 200, 50);
    jumpTime.addEventHandler(parent, "jumpTimeTextFieldChange");
    
    // GUI Element for specifying where to put custom markers
    customMarkersFluidLabel = new GLabel(control_gui, 400, 300, 200, 70);
    customMarkersFluidLabel.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    customMarkersFluidLabel.setLocalColorScheme(15); // White theme
    customMarkersFluidLabel.setText("Request Markers Fluid [mol]:");
    customMarkersFluidLabel.setTextBold();
    customMarkersFluidLabel.setOpaque(false);
    customMarkersFluidText = new GTextArea(control_gui, 400, 350, 200, 100, G4P.SCROLLBARS_VERTICAL_ONLY);
    customMarkersFluidText.addEventHandler(parent, "customMarkersFluid_change");
    
    customMarkersSolidLabel = new GLabel(control_gui, 400, 450, 200, 70);
    customMarkersSolidLabel.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    customMarkersSolidLabel.setLocalColorScheme(15); // White theme
    customMarkersSolidLabel.setText("Request Markers Solid [mol]:");
    customMarkersSolidLabel.setTextBold();
    customMarkersSolidLabel.setOpaque(false);
    customMarkersSolidText = new GTextArea(control_gui, 400, 500, 200, 100, G4P.SCROLLBARS_VERTICAL_ONLY);
    customMarkersSolidText.addEventHandler(parent, "customMarkersSolid_change");
    
    
    control_gui.loop();
    //=============================================================
  }
  
  
  public void setMarkerRequestsSolid(List <Float> mrs) {
    markerRequestsSolid = mrs;
  }
  
  public void setMarkerRequestsFluid(List <Float>mrf) {
    markerRequestsFluid = mrf;
  }
  
  public List <Float> getMarkerRequestsSolid() {
    return markerRequestsSolid;
  }
  
  public List <Float> getMarkerRequestsFluid() {
    return markerRequestsFluid;
  }
  
  public void printStepTimes(String stepTimesString) {
    stepTimes.setText(stepTimesString);
  }
  
}

////////////////////////////////////////////////////////////////////////////////////////
// These functions are used by the G4P library, so they must be outside of the class
// See "VSA_Animation_Prototype" tab for variable definitions and more functions that 
//   exist outside of a class.

// Event handler for the popout window
synchronized public void win_control_gui(PApplet appc, GWinData data) {
  appc.background(120);
}

public void playPauseBtn_click(GButton ppBtn, GEvent event) {
  if (event == GEvent.CLICKED) {
      // If the user clicked on the play button, meaning the animation was paused\
    if (ppBtn.getText().equals("Play")) {
      ppBtn.setText("Pause");
      play_animation = true;
    } else { // If the user clicked on the pause button, meaning the animation was playing
      ppBtn.setText("Play");
      play_animation = false;
    }
    handleGUI();
    redraw();
  }
}

public void timeSliderEvent(GCustomSlider timeSlider, GEvent event) {
  timepoint = timeSlider.getValueI();
  // handleGUI();
  redraw();
}

public void speedSliderEvent(GCustomSlider speedSlider, GEvent event) {
  animation_framerate_multiplier = speedSlider.getValueF();
  handleGUI();
  redraw();
}

public void lightKey_clicked1(GOption option, GEvent event) {
  if (option.isSelected()) {
    component = ComponentType.LK;
    handleGUI();
  }
  //println("lightKey - GOption >> GEvent." + event + " @ " + millis());
}

public void allComp_clicked1(GOption option, GEvent event) {
  if (option.isSelected()) {
    component = ComponentType.ALL_COMP;
    handleGUI();
  }
  //println("allComp - GOption >> GEvent." + event + " @ " + millis());
}

public void heavyKey_clicked1(GOption option, GEvent event) {
  if (option.isSelected()) {
    component = ComponentType.HK;
    handleGUI();
  }
  //println("heavyKey - GOption >> GEvent." + event + " @ " + millis());
}

//public void stepTimes_change1(GTextArea source, GEvent event) {
//  println("textarea1 - GTextArea >> GEvent." + event + " @ " + millis());
//}

// User has to press enter key in the text field for this to be triggered
// TODO: Change code so each PhaseGroup has its own timepoint. 
// That way, I could put two animations for two different simulations side-by-side 
//    and choose to run them at the same time (by using my custom time-interpretation function), instead of at the same timepoint.
// TODO: Change dependency injection so this isn't directly reliant on phaseGroup, which is located in another file.
//      This will also be necessary when using multiple phases in the future
public void jumpTimeTextFieldChange(GTextField source, GEvent event) {
  if (event == GEvent.ENTERED){
    // Set the global timepoint to the one closest to what the user enters
    int timepointToJumpTo = phaseGroup.getNearestTimePoint(source.getText());
    if (timepointToJumpTo >= 0) {
      timepoint = phaseGroup.getNearestTimePoint(source.getText());
    }
    // println(timepointToJumpTo);
  }
}

// TODO: Change code so each PhaseGroup draws its own markers.
//        I already have this code for the 0, max fluid, and max solid in PSA_Animation.
//          Move this code to PhaseGroup for drawInitialMarkers
//          Then, make another function called drawCustomMarkers()
//            Make this function draw green lines and use green text labels above the lines.
//            The triggered function below will call phaseGroup.drawCustomMarkers(float list of mol values).
// TODO: Make one text area for the fluid phase. Make another text area for the solid phase.
// TODO: To add support for multiple phase groups, automatically generate more text areas for those phase groups?
//       For now, don't worry about supporting multiple phase groups. Just tell them to copy and paste the animation and rename it so they can run two at once.

// Expects input in scientific notation or just a float
public void customMarkersSolid_change(GTextArea source, GEvent event) {
  if (event == GEvent.ENTERED){
    String [] markers;
    if (source.getText().split("\n").length >= 1) {
      markers = source.getText().split("\n");
    } else {
      markers = new String[1];
    }
    
    List <Float> requestsSolid = new ArrayList <Float> ();
    
    for (String sMarker : markers) {
      sMarker = sMarker.trim();
      if (!sMarker.isEmpty()) {
        try {
          Float amt = Float.parseFloat(sMarker.trim());
          requestsSolid.add(amt);
        } catch (Exception e) {
          println(e);
        }
      }
    }
    
    
    // println("Requests for Solid: " + requestsSolid);
    
    // TODO: This is bad practice b/c it relies on info from PSA_Animation.
    // Fix this later
    animation_controls.setMarkerRequestsSolid(requestsSolid);
  }
  //println("textarea1 - GTextArea >> GEvent." + event + " @ " + millis());
}

public void customMarkersFluid_change(GTextArea source, GEvent event) {
  if (event == GEvent.ENTERED){
    String [] markers;
    if (source.getText().split("\n").length >= 1) {
      markers = source.getText().split("\n");
    } else {
      markers = new String[1];
    }
    
    List <Float> requestsFluid = new ArrayList <Float> ();
    
    for (String sMarker : markers) {
      sMarker = sMarker.trim();
      if (!sMarker.isEmpty()) {
        // println("sMarker: " + "'" + sMarker + "'");
        try {
          Float amt = Float.parseFloat(sMarker);
          requestsFluid.add(amt);
        } catch (Exception e) {
          println(e);
        }
      }
    }
  
    // println("Requests for Fluid: " + requestsFluid);
      
    // TODO: This is bad practice b/c it relies on info from PSA_Animation.
    // Fix this later
    animation_controls.setMarkerRequestsFluid(requestsFluid);
  }
  //println("textarea1 - GTextArea >> GEvent." + event + " @ " + millis());
}


// Provide default functions to get rid of annoying warning messages:
public void handleTextEvents(GEditableTextControl textcontrol, GEvent event) { /* code */ }
public void handleToggleControlEvents(GToggleControl option, GEvent event) { /* code */ }
public void handleSliderEvents(GValueControl slider, GEvent event) { /* code */ }
public void handleButtonEvents(GButton button, GEvent event) { /* code */ }
////////////////////////////////////////////////////////////////////////////////////////
