/* ColumnFrame
 * Author: Jack Tabb
 * Date Created: 2019-07-14
 * Date Last Edited: 2021-02-21
 * Purpose: To handle the basic drawing functinalities for a Column
*/


class PhaseGroup {
  Table stateMatrix; // Store all the "amount" data from a CSV file into a table -- uses a lot of RAM
  Table volFlowMatrix; // Store all volumetric flowrate data from a CSV file into a table
  Table timeMatrix;
  
  //Phase fluidPhase; // The phase on display for the animation
  //Phase solidPhase;
  List<Phase> phaseList;
  
  Arrows arrows;
  
  float columnWidth;
  float columnHeight;
  
  //float timeFactor = 0f;
  
  List<Step> stepList; // List of all steps in the animation
  
  //Map <String, ArrayList<String>> stepTimePoints; // I think this is time, not timepoints
  //Map <Float, Float> stepLength; // timepoint of step, length of step
  
  
  /* Construct a Column Frame */
  PhaseGroup(float columnWidth, float columnHeight, Table stateMatrix, Table volFlowMatrix, Table timeMatrix, List<Phase> phaseList, Arrows arrows) {
    this.columnWidth = columnWidth;
    this.columnHeight = columnHeight;
    
    this.stateMatrix = stateMatrix;
    this.volFlowMatrix = volFlowMatrix;
    this.timeMatrix = timeMatrix;
    this.phaseList = phaseList;
    //this.fluidPhase = fluidPhase;
    //this.solidPhase = solidPhase;
    this.arrows = arrows;
    
    println("Finding times at which each step occurs...");
    stepList = generateStepList();
    
    //stepTimePoints = findStepTimePoints(timeMatrix);
    //stepLength = new HashMap<Float, Float>(); // Time [s] that step starts, Time [s] that step lasts
    
    // this.timeFactor = calcTimeFactor();
}
  
  // NOTE: The Column shape is expected to be drawn with a command such as 'shape(s, 25, 25);' to let the user specify where he wants the column
  /* Draw a basic flow-diagram-distillation-column-esque thing */
  PShape drawPhaseGroupFoundation() {
    PShape column; // The PShape object that will be drawn to represent the entire column
    PShape colHead, colBody, colFoot; // The different parts that represent the column
    
    // Create the shape group for the column
    column = createShape(GROUP);
    
    noStroke(); // No outline on the column
    
    // Make the different parts of the column shape
    // Make the main body of the column
    rectMode(CENTER);
    colBody = createShape(RECT, 0, 0, columnWidth, columnHeight);
    colBody.setFill(color(255));
    
    // NEW way of making top of column -- allows more dynamic control
    // When using arc, imagine drawing an ellipse. Specify the x- and y- coordinates of the ellipse. 
    //  Then, specify the width and height. Then, specify the degrees of that ellipse that you want to be visible.
    //  Processing is using an ellipse behind the scenes to draw the arc. So, we need to set the ellipseMode when we want our arc to behave in a certain way.
    //  Also, we are using createShape() instead of arc() because I don't want to draw the shape yet. I want to assign attributes here and then draw it later.
    
    ellipseMode(RADIUS);
    colHead = createShape(ARC, 0, -columnHeight/2, columnWidth/2, columnHeight/5, PI, 2*PI);
    colHead.setFill(color(255));
    
    //Make the bottom part of the column
    colFoot = createShape(ARC, 0, columnHeight/2, columnWidth/2, columnHeight/5, 0, PI);
    colFoot.setFill(color(255));

    // Package the parts of the shape into one group shape
    column.addChild(colBody);
    column.addChild(colHead);
    column.addChild(colFoot);
    
    return column; // Return the shape to be drawn on screen
  }
  
  ///* */
  //// TODO: Stop using global timepoint. Encapsulate it.
  //PShape drawPhase(PhaseType pt) {
  //  PShape phaseShape;
  //  switch (pt) {
  //    case FLUID:
  //      phaseShape = fluidPhase.drawColContents(timepoint);
  //      break;
  //    case SOLID:
  //      phaseShape = solidPhase.drawColContents(timepoint);
  //      break;
  //    default:
  //      phaseShape = fluidPhase.drawColContents(timepoint);
  //      break;
  //  }
  //  return phaseShape;
  //}
  
  /* */
  PShape drawPhaseGroupArrows() {
    // Assuming fluid phase is at position 0 in the phase list
    PShape arrowsAtThisTimept = arrows.drawArrows(timepoint, volFlowMatrix, phaseList.get(0).getFirstCSTRColor(), phaseList.get(0).getLastCSTRColor());
    return arrowsAtThisTimept;
  }
  
  /* Identify timepoints for beginning of each step. */
  public Map <String, ArrayList<String>> findSteps(Table timeMatrix) {
    // A step may occur more than once, so each step will have a list of timepoints at which it starts.
    Map <String, ArrayList<String>> sTmPts = new HashMap<String, ArrayList<String>>();
    
    // Each row in the timeMatrix represents one timepoint
    // The 0th column holds values of the time [s].
    // The 1st column holds values of the step.
    String prevStep = "";
    for (int i = 0; i < timeMatrix.getRowCount(); i++) {
      String currentStep = timeMatrix.getString(i, 1);
      
      // If the step has not been seen before
      if (!currentStep.equals(prevStep)) {
        // If the step has never been seen, make a new list. 
        // Otherwise, the steps are being cycled through multiple times, so we need to add another timepoint at which this step initiates.
        ArrayList<String> stepList = sTmPts.containsKey(currentStep) ? sTmPts.get(currentStep) : new ArrayList<String>();
        stepList.add(timeMatrix.getString(i, 0)); // Add the current time to the list of times at which this step starts
        sTmPts.put(currentStep, stepList);
      }
      
      prevStep = timeMatrix.getString(i, 1);
    }
    return sTmPts;
  }
  
  /* */
  void drawLabels(float xCoord, float yCoord) {
    // Draw the CSTR Width Labels
    // Draw center CSTR Width Line (0)
    strokeWeight(3); // Line 3 pixels wide
    color lineColor = color(165,42,42);
    stroke(lineColor); // Brown
    int text_height = height-100;
    // shapeMode(CENTER);
    line(width/2,0+(height-phaseGroupHeight)/2,width/2,text_height);
  
    // Label the lines at the bottom in the beige area. (100%, 0%, 100%). 
    // Put the fluid one on the left side of the fluid 100% line. Put the solid label on the right side of the solid 100% line. 
    // Align the 0% label in the center of the center 0% line.
    textAlign(CENTER, TOP);
    fill(lineColor);
    text("0\nmol", width/2, text_height);
    //float fluidPhaseMax = phaseList.get(0).getMaxAmtCompAnyCSTRInPhase(phaseList.get(0).getColCompType());
    //float solidPhaseMax = phaseList.get(1).getMaxAmtCompAnyCSTRInPhase(phaseList.get(1).getColCompType());
    float fluidPhaseMax = phaseList.get(0).getMaxAmtCompAnyCSTRInPhase(ComponentType.ALL_COMP);
    float solidPhaseMax = phaseList.get(1).getMaxAmtCompAnyCSTRInPhase(ComponentType.ALL_COMP);
    // float maxAmt = fluidPhaseMax > solidPhaseMax ? fluidPhaseMax : solidPhaseMax;
    float maxAmt = ( (fluidPhaseMax > solidPhaseMax) ? fluidPhaseMax : solidPhaseMax );
    // maxAmt = ( (fluidPhaseMax == solidPhaseMax) ? fluidPhaseMax : fluidPhaseMax );
    
    //println("Stored fluid max: " + phaseList.get(0).getMaxAmtCompAnyCSTRInPhase(ComponentType.ALL_COMP));
    //println("Stored solid max: " + phaseList.get(1).getMaxAmtCompAnyCSTRInPhase(ComponentType.ALL_COMP));
    
    // float fluid_label_x = -1*(phaseList.get(0).getMaxAmtCompAnyCSTRInPhase(phaseList.get(0).getColCompType()) / maxAmt)*((float)drawableColWidth) + (float)xCoord;
    float fluid_label_x = -1*(fluidPhaseMax / phaseList.get(0).getWidthNormalizationFactor(ComponentType.ALL_COMP))*((float)drawableColWidth) + (float)xCoord;
    line(fluid_label_x,0+(height-phaseGroupHeight)/2,fluid_label_x,text_height);
    textAlign(RIGHT, TOP);
    text(String.format("%05.2e ", fluidPhaseMax) + "\n" + "mol", fluid_label_x, text_height);
    
    // float solid_label_x = (phaseList.get(1).getMaxAmtCompAnyCSTRInPhase(phaseList.get(1).getColCompType()) / maxAmt)*(drawableColWidth) + xCoord;
    float solid_label_x = (solidPhaseMax / phaseList.get(1).getWidthNormalizationFactor(ComponentType.ALL_COMP))*(float)(drawableColWidth) + (float)xCoord;
    //float solid_label_x = (solidPhaseMax / phaseList.get(1).getWidthNormalizationFactor(ComponentType.ALL_COMP))*(float)(columnWidth) + (float)xCoord;
    line(solid_label_x,0+(height-phaseGroupHeight)/2,solid_label_x,text_height);
    textAlign(LEFT, TOP);
    text(String.format("%05.2e ", solidPhaseMax) + "\n" + "mol", solid_label_x, text_height);
    
    // Label the phases with lines specified by the user
    // TODO: For each marker requested, draw a green line. Label it with a label at the top.
    fill(0,255,0);
    stroke(0,255,0);
    int textH = 80;
    float markerTextHeight =  (height-phaseGroupHeight)/2 - textH;
    if (animation_controls.getMarkerRequestsFluid() != null) {
      textAlign(RIGHT, TOP);
      for (Float markerRequest : animation_controls.getMarkerRequestsFluid()) {
        float label_x = -1*(markerRequest / maxAmt)*((float)drawableColWidth) + (float)xCoord - 1;
        line(label_x,markerTextHeight,label_x,text_height);
        text(String.format("%05.2e ", markerRequest) + "\n" + "mol", label_x, markerTextHeight);
      }
    }
    if (animation_controls.getMarkerRequestsSolid() != null) {
      textAlign(LEFT, TOP);
      for (Float markerRequest : animation_controls.getMarkerRequestsSolid()) {
        float label_x = (markerRequest / maxAmt)*(drawableColWidth) + xCoord + 1;
        line(label_x,markerTextHeight,label_x,text_height);
        text(String.format("%05.2e ", markerRequest) + "\n" + "mol", label_x, markerTextHeight);
      }
    }
    
    // Label the phases
    textAlign(LEFT, TOP);
    fill(0);
    text("Visualized Component: " + component.toString(), 0, 70); // Label which components we are viewing in the phase (heavy key, light key, or overall composition)
    text("Step: " + timeMatrix.getString(timepoint, 1), 0, 35); // Label which mode of operation the group of phases is currently in
    fill(0);
    
    int fluidPhaseTextX = (int)(xCoord - widthScaleFactor*phaseGroupWidth);
    int fluidPhaseTextY = (int)yCoord;
   
    // text(fluidPhase.getColPhaseType().name(), fluidPhaseTextX, fluidPhaseTextY);
    text(phaseList.get(0).getPhaseType().name(), fluidPhaseTextX, fluidPhaseTextY);
    
    int solidPhaseTextX = (int)(xCoord + widthScaleFactor*phaseGroupWidth);
    int solidPhaseTextY = (int)yCoord;
    textAlign(RIGHT, TOP);
    // text(solidPhase.getColPhaseType().name(), solidPhaseTextX, solidPhaseTextY);
    text(phaseList.get(1).getPhaseType().name(), solidPhaseTextX, solidPhaseTextY);  
  }
  
  /* Update the component types */
  //void updatePhaseCompType(ComponentType component) {
  //  fluidPhase.setColComp(component);
  //  solidPhase.setColComp(component);
  //}
  
  /* Given a timepoint, get the actual time (i.e. in seconds) */
  public float calcTime(int tp) {
    if (tp > 0) {
      return timeMatrix.getFloat(tp, 0);
    } else {
      return -1;
    }
  }
  
  /* Given a time, find the nearest timepoint, defaulting to the smallest timepoint found */
  public int getNearestTimePoint(String time) {
    // We will use regex, so prepare the string for use in a regular expression.
    // In regex, the dot is a special character. Add slash to escape.
    String timeSplit[] = time.split(".");
    // If there was a decimal in the time given to this function, 
    //    then there are 2 strings in the array after splitting around a "."
    String compatibleTime;
    if (timeSplit.length > 1) {
      compatibleTime = timeSplit[0] + "/." + timeSplit[1];
    } else { // There was not a decimal in the time
      compatibleTime = time;
    }
    
    // Find all times that closely match the time the user entered.
    // Ex: User enters 202 seconds, so return 202.15, 202.18, 202.5, 202.7, ...
    //     Or User enters 202.1, so return 202.15 and 202.18
    //     Also, do not return 100.202 as a result because the 202 is in the wrong position.
    String regex = "^" + compatibleTime + ".*";
    List <String> matchingTimes = new ArrayList <String>();
    for (TableRow matchingTime : timeMatrix.matchRows( regex, 0)) {
      matchingTimes.add(matchingTime.getString(0));
    }
    
    // Out of all results, choose the first one. If the user doesn't like that, he needs to be more specific.
    String firstMatch = "";
    if (!matchingTimes.isEmpty()) {
      firstMatch = matchingTimes.get(0);
    }
    return timeMatrix.findRowIndex(firstMatch, 0);
  }
  
  ///* Calculate the maximum amount (at any timepoint) of each CSTR in the desired phase (FLUID or SOLID) for the desired component (HK, LK, ALL_COMP) */
  //public Float [] calcEachCSTRMaxAmt(Set<Integer> desiredPAndC, int numVarPerCSTR, int numCSTR) {
  //  //println("numCSTR: " + numCSTR);
  //  Float maxCSTRAmt [] = new Float [numCSTR];
  //  Arrays.fill(maxCSTRAmt, 0f);
  //  for (int timePt = 0; timePt < stateMatrix.getRowCount(); timePt++) { // Iterate through all rows (timepoints)
  //    TableRow amtData = stateMatrix.getRow(timePt);
  //    for (int cstrIter = 0; cstrIter < stateMatrix.getColumnCount(); cstrIter+=numVarPerCSTR) { // Iterate through all CSTRs
  //      float curTotalAmt = 0; // Reset this value for each CSTR
  //      for (int phaseAndComp : desiredPAndC) { // Iterate through desired components in the desired phases in this CSTR at this timepoint
  //        // Sum the desired combination of ThetaA, ThetaB, QA, QB at this timepoint for this CSTR
  //        // If the set was correctly set up, you could just calculate ThetaA for FLUID LK.
  //        curTotalAmt += amtData.getFloat(cstrIter+phaseAndComp);
  //      } // End iteration through phases and components
  //      if (curTotalAmt > maxCSTRAmt[cstrIter/numVarPerCSTR]) {
  //        maxCSTRAmt[cstrIter/numVarPerCSTR] = curTotalAmt;
  //      }
  //    } // End iteration through CSTRs
  //  } // End iteration through timepoints
  //  return maxCSTRAmt;
  //}
  
  
  /* For each CSTR at each timepoint, calculate the maximum sum of the amount of this(these) component(s) in this(these) desired phase(s)
     If you want the component in a phase to be counted, then add its index to the set. Otherwise, leave it out of the set.
        So, you could sum the amt of component A, B, and C in just the FLUID phase.
        Or, you could sum the amt of component A, B and C in both FLUID and SOLID phase.
        Or, you could sum the amt of component A in the FLUID phase (so you wouldn't really be summing).
     Return the maximum sum seen among the timepoints for each CSTR.
     So, each CSTR will have one value associated with it.
     This value is the maximum amount of your selected conglomerate material seen in the CSTR at any timepoint.
  */
  //TODO: Move the logic of iterating through all CSTRs in Phase drawColContents and this PhaseGroup calcMaxAmtEachCSTR to one place.
  public Float [] calcMaxAmtEachCSTR(Set<Integer> desiredPAndC, int numVarPerCSTR, int numCSTR) {
    // println("desiredPAndC: " + desiredPAndC);
    //println("numCSTR: " + numCSTR);
    Float maxCSTRAmt [] = new Float [numCSTR]; // Each CSTR will have one value
    Arrays.fill(maxCSTRAmt, 0f);
    for (int timePt = 0; timePt < stateMatrix.getRowCount(); timePt++) { // Iterate through all rows (timepoints)
      TableRow amtData = stateMatrix.getRow(timePt);
      //for (int cstrIter = 0; cstrIter < stateMatrix.getColumnCount(); cstrIter+=numVarPerCSTR) { // Iterate through all CSTRs
      for (int cstrIter = 0; cstrIter < numCSTR*numVarPerCSTR; cstrIter+=numVarPerCSTR) { // Iterate through all CSTR data
        float curTotalAmt = 0; // Reset this value for each CSTR
        for (int phaseAndComp : desiredPAndC) { // Iterate through desired components in the desired phases in this CSTR at this timepoint
          // Sum the desired combination of ThetaA, ThetaB, QA, QB at this timepoint for this CSTR
          curTotalAmt += amtData.getFloat(cstrIter+phaseAndComp);
        } // End iteration through phases and components
        if (curTotalAmt > maxCSTRAmt[cstrIter/numVarPerCSTR]) { // relies on integer truncation
          maxCSTRAmt[cstrIter/numVarPerCSTR] = curTotalAmt;
          // println("TimePoint " + timePt + ", index " + (cstrIter) + ": " + curTotalAmt);
          // Do I care about perCSTR? I think I'm just picking one max to compare all CSTRs to . SO why keep up with max for each CSTR? If one CSTR's max is bigger than the other CSTR's max, overwrite the max.
          // TODO: Think of how this affects visuals
        }
      } // End iteration through CSTRs
    } // End iteration through timepoints
    return maxCSTRAmt;
  }
  
  
  ///* For each component in each phase, find the maximum amount seen in each CSTR
  // * Example: if you have a fluid and solid phase, component A and B, and 10 CSTRs.
  // *   Go through all timepoints in the state matrix. Look at the amount of component A in the fluid phase in the 1st CSTR.
  // *   After going through all timepoints for that CSTR, do the same thing for the other CSTRs. Remember the max amount of material that each CSTR sees.
  // *   Once you're done doing that, do the same thing, but for component B in the fluid phase. Then for component A in the solid phase. Then for component B in the solid phase.
  // *   That's a total of 40 maximum values to keep track of.
  // *   
  // *   The data structures look crazy here, but they help keep track of the maximum values in an organized fashion
  // */
  // private Map<PhaseType, HashMap <ComponentType, Float[]>> calcMaxAmtEachCompEachPhaseEachCSTR() { 
  //   // Find the maximum amounts of each component to calculate normalization factors for the CSTR colors and widths
  //  // TODO: Refactor this into a function -- its logic is used elsewhere. So, put it in the Phase class? IDK how to abstract this yet. Since it currently uses the fluid and solid col, it belongs here. But, once I put the fluid and solid col into the PhaseGroup, it will make even more sense to put it there. I may need to break it into multiple functions.
  //  // TODO: Call this function in the following context, then move all the code from the following context to a function that's local to PSA_Animation
  //  Map<PhaseType, HashMap <ComponentType, Float[]>> compsPreMaxAmtInCSTR = new HashMap<PhaseType, HashMap<ComponentType, Float[]>>(); // Each CSTR will have its own max (normalization factor). Different modes of operation (focussing on different components) will yield different max amt.
  //  Set<Integer> desiredPhaseAndComp; // Use set math to determine which data we pull from the main data matrix to perform our calculations
    
    
  //  // For performance reasons, maybe do calculation of max amt by doing one row at a time. This would let me use Processing's getRow feature more effectively
    
  //  for (PhaseType pt: PhaseType.values()) { // For each phase (fluid and solid)
  //    HashMap tempMap = new HashMap<ComponentType, Float[]>(); // Temporarily holds values of all components in one phase
  //    for (ComponentType ct : ComponentType.values()) { // For each component (LK, HK, ALL_COMP)
  //      // We need to calculate the max for each component type at initialization and keep it in memory so we can change it while running the animation.
  //      // Use set math to determine which data we pull from the main data matrix to perform our calculations
  //      desiredPhaseAndComp = pt.setupDesiredPhase(pt); // First, use this phase
  //      desiredPhaseAndComp.retainAll(ct.setupDesiredComp(ct)); // Use this component. The intersection of these sets represents the indeces we will use to find the correct data in the matrix (i.e. FLUID and Component A = ThetaA = First column out of group of 4 columns (ThetaA, ThetaB, QA, QB))
  //      Float [] maxCSTRAmt = calcMaxAmtEachCSTR(desiredPhaseAndComp, numVarPerCSTR, phaseList.get(0).getNumCSTR()); // Array that holds each CSTR's maximum amount seen for this component in this phase
  //      // TODO: 
  //      //        Move the function to the PhaseGroup class.
  //      //        Refactor the PhaseGroup class so that it uses the statematrix, etc. It will assume that all Phases that are assigned to it are a part of the same dataset (state matrix)
  //      //        In the future, if you want to compare multiple datasets, then you make multiple PhaseGroups side-by-side. Then, each phasegroup represents multiple Phases within its boundaries.
  //      // TODO: Furthermore, ensure the data makes sense, too. numCSTR should be consistent between fluid and solid phase in the same dataset. So, fluidPhase and solidPhase shouldn't store that info.
  //      //        The new PhaseGroup class should store that info.
  //      //        Also, look at the top of PSA_Animation to see which other values the new PhaseGroup class needs
  //      tempMap.put(ct, maxCSTRAmt); // This map let's us remember which component these values are a maximum of
  //    } // End iteration through components
  //    // Store each component's maximum amount seen in this phase.
  //    compsPreMaxAmtInCSTR.put( pt, tempMap ); // This map builds off of the smaller map. Now, we'll remember which component in which phase generated the array of CSTR maximum values
  //  } // End iteration through phases
  //  return compsPreMaxAmtInCSTR;
  //}
  
  /* TODO: Move part of this function to the Phase class. 
      Most of the time, I'm looking at using the same normalization factor for both phases.
      First, I calculate the max seen in each phase (can be done in Phase class). I use this value for each phase for a few different things.
      Then, I select the max among those and assign that value to each Phase. (Both of these actions should be done from outside the Phase class).
      */
  public void setNormalizationFactors () {
    Set <Integer> desiredPhaseAndComp;
    Map <Phase, Float[]> maxAmtAllCompEachPhaseEachCSTR = new HashMap <Phase, Float[]> ();
    
    for (Phase phase : phaseList) {
      //println(phase.getCompList());
      desiredPhaseAndComp = new HashSet <Integer> ();
      for (Component comp : phase.getCompList()) { // Once this function is moved to the phase class, I won't have to "get" the component list.
        //desiredPhaseAndComp.add(comp.getVarPos() + phasePos);
        // println("phase " + phase.getPhaseType() + ", comp " + comp.getCompType());
        desiredPhaseAndComp.add(phase.getVarPos() * phase.getCompList().size() + comp.getVarPos());
        // println(desiredPhaseAndComp);
      }
      // Array that holds the maximum value of material seen in each CSTR for the selected component(s) in the selected phase
      Float [] maxAmtEachCSTR = calcMaxAmtEachCSTR(desiredPhaseAndComp, numVarPerCSTR, phaseList.get(0).getNumCSTR());
      maxAmtAllCompEachPhaseEachCSTR.put( phase, maxAmtEachCSTR );
    }
    
    Float maxFluidAmt = Collections.max(Arrays.asList(maxAmtAllCompEachPhaseEachCSTR.get(phaseList.get(0))));
    Float maxSolidAmt = Collections.max(Arrays.asList(maxAmtAllCompEachPhaseEachCSTR.get(phaseList.get(1))));
    
    println("Max fluid amt: " + maxFluidAmt);
    println("Max solid amt: " + maxSolidAmt);
    
    
    
    // Temporarily edited out as of 8/19/2021 -- The data Tae gave me has tiny amounts of fluid vs. solid. To actually see the fluid stuff, I had to normalize it independently of the solid stuff.
     phaseList.get(0).setMaxAmtAnyCSTRInPhase(ComponentType.ALL_COMP, maxFluidAmt);
     phaseList.get(1).setMaxAmtAnyCSTRInPhase(ComponentType.ALL_COMP, maxSolidAmt);
    if (maxFluidAmt >= maxSolidAmt) {
      phaseList.get(0).setWidthNormalizationFactor(ComponentType.ALL_COMP, maxFluidAmt);
      phaseList.get(1).setWidthNormalizationFactor(ComponentType.ALL_COMP, maxFluidAmt);
    } else { // maxSolidAmt > maxFluidAmt
      phaseList.get(0).setWidthNormalizationFactor(ComponentType.ALL_COMP, maxSolidAmt);
      phaseList.get(1).setWidthNormalizationFactor(ComponentType.ALL_COMP, maxSolidAmt);
    }
    // Temporarily doing this instead:
     //phaseList.get(0).setMaxAmtAnyCSTRInPhase(ComponentType.ALL_COMP, maxFluidAmt);
     //phaseList.get(1).setMaxAmtAnyCSTRInPhase(ComponentType.ALL_COMP, maxSolidAmt);
     //phaseList.get(0).setWidthNormalizationFactor(ComponentType.ALL_COMP, maxFluidAmt);
     //phaseList.get(1).setWidthNormalizationFactor(ComponentType.ALL_COMP, maxSolidAmt);
  }
  
  
  
  
  
  
  
  
  
  ///* Go through the data to setup the normalization scheme 
  // * Set the normalization factors for the provided phases
  // * Determine normalization factors for color and width:
  // *     Explanation of widthNormalization factors:
  // *        -- In a given phase, each CSTR has a normalization factor for each component. That way, if we can look at all components or one component at a time while the animation is running.
  // *        -- A Phase is only for one type of phase, so the data is extracted a little bit before being stored in the Phase instances
  // *        -- 
  // *     Explanation of colorNormalization factors: 
  // *         -- Each CSTR has its own color normalization factor (As of 2/21/2021, only the arrows are making use of this value to indicate the composition)
  // *         -- TODO: Change the arrows so that there is a different arrow for each component. Then, the need for blending colors goes away. Then, the need for calculating the color normalization factors goes away.
  // *         -- Each phase has a different normalization factor for each component in the phase
  // *         -- fluid gets max amount of each component found in any CSTR in the Fluid phase at any timepoint
  // *         -- solid gets max amount of each component found in any CSTR in the Solid phase at any timepoint
  //*/
  //void setNormalizationFactors () {
  //  Map<PhaseType, HashMap <ComponentType, Float[]>> maxAmtEachCompEachPhaseEachCSTR = calcMaxAmtEachCompEachPhaseEachCSTR();
    
  //  //Float [] [] maxAmtCompEachCSTR = 
    
  //  // Note the difference between looking at the max amount in each CSTR in a phase vs. looking at the max amount out of all CSTRs in a phase.
  //  for (ComponentType ct : ComponentType.values()) {
  //    // The maximum amount of this component seen in each CSTR in the Fluid phase at any timepoint
  //    Float[] maxCompAmtEachCSTRFluidPhase = maxAmtEachCompEachPhaseEachCSTR.get(PhaseType.FLUID).get(ct);
  //    // The maximum amount of this component seen in each CSTR in the Solid phase at any timepoint
  //    Float[] maxCompAmtEachCSTRSolidPhase = maxAmtEachCompEachPhaseEachCSTR.get(PhaseType.SOLID).get(ct);
      
  //    // Set the maximum amount of each component in each CSTR at any timepoint for both phases
  //    // We can change the normalization factors, but we always want to know what the max amount was in case we want to go back, so we need 2 different data structures for each data point.
  //    // The normalization factors that are paired with these max values are determined farther down after calculating the overall max for each phase and performing some comparison logic.
  //    fluidPhase.setMaxAmtEachCSTRInPhase(ct, maxCompAmtEachCSTRFluidPhase);
  //    solidPhase.setMaxAmtEachCSTRInPhase(ct, maxCompAmtEachCSTRSolidPhase);
      
  //    // Looking at the max amount of each component in each CSTR in the Fluid phase at any timepoint, find the max amount of each component in any CSTR in the Fluid phase at any timepoint.
  //    Float maxFluid = Collections.max(Arrays.asList(maxCompAmtEachCSTRFluidPhase));
  //    // For each component, set the Fluid phase's max and color normalization factor to the max CSTR amount we found for the fluid phase.
  //    // We can change the normalization factors, but we always want to know what the max amount was in case we want to go back, so we need 2 different data structures for each data point.
  //    fluidPhase.setMaxAmtAnyCSTRInPhase(ct, maxFluid); // Set the max amount for color normalization
  //    fluidPhase.setColorNormalizationFactor(ct, maxFluid); // Set the color normalization factor
      
  //    // Looking at the max amount of each component in each CSTR in the Solid phase at any timepoint, find the max amount of each component in any CSTR in the Solid phase at any timepoint.
  //    Float maxSolid = Collections.max(Arrays.asList(maxCompAmtEachCSTRSolidPhase));
  //    // For each component, set the Solid phase's max and color normalization factor to the max CSTR amount we found for the solid phase.
  //    // We can change the normalization factors, but we always want to know what the max amount was in case we want to go back, so we need 2 different data structures for each data point.
  //    solidPhase.setMaxAmtAnyCSTRInPhase(ct, maxSolid); // Set the max amount for color normalization
  //    solidPhase.setColorNormalizationFactor(ct, maxSolid); // Set the color normalization factor
       
  //    // Since we want the width normalization factor to allow comparison between the Fluid and Solid phase, both phases must be normalized by the same value.
  //    // Choose the larger value to avoid numbers over 100%
  //    if (fluidPhase.getMaxAmtCompAnyCSTRInPhase(ct) > solidPhase.getMaxAmtCompAnyCSTRInPhase(ct)) {
  //      fluidPhase.setWidthNormalizationFactor(ct, fluidPhase.getMaxAmtCompAnyCSTRInPhase(ct));
  //      solidPhase.setWidthNormalizationFactor(ct, fluidPhase.getMaxAmtCompAnyCSTRInPhase(ct));
  //      // Then use fluid phase's max values for normalizing the width of both the fluid phase and the solid phase CSTRs for this component.
  //      fluidPhase.setWidthNormalizationFactors(ct, maxCompAmtEachCSTRFluidPhase);
  //      solidPhase.setWidthNormalizationFactors(ct, maxCompAmtEachCSTRFluidPhase); // That's not a typo. I am using the fluid values for the solid phase on purpose!
  //    } else {
  //      // Use solid phase's max values for normalizing the width of both the fluid phase and the solid phase CSTRs for this component.
  //      fluidPhase.setWidthNormalizationFactors(ct, maxCompAmtEachCSTRSolidPhase); // That's not a typo. I am using the solid values for the fluid phase on purpose!
  //      solidPhase.setWidthNormalizationFactors(ct, maxCompAmtEachCSTRSolidPhase);
  //      fluidPhase.setWidthNormalizationFactor(ct, solidPhase.getMaxAmtCompAnyCSTRInPhase(ct));
  //      solidPhase.setWidthNormalizationFactor(ct, solidPhase.getMaxAmtCompAnyCSTRInPhase(ct));
  //    }
  //  }
  //}
  
  private ArrayList<Step> generateStepList() {
    ArrayList<Step> steps = new ArrayList<Step>();
    
    // Each row in the timeMatrix represents one timepoint
    // The 0th column holds values of the time [s].
    // The 1st column holds values of the step.
    
    
    
    
    
    // Add first step
    String prevStepName = timeMatrix.getString(0, 1);
    steps.add( new Step(0, 0, prevStepName) );
    for (int i = 1; i < timeMatrix.getRowCount(); i++) {
      String curStepName = timeMatrix.getString(i, 1);
      if (!curStepName.equals(prevStepName)) { // If the step changes
        // We know the transition point of the step, so use this timepoint as
        // the end of the last step and the beginning of a new step.
        if (!steps.isEmpty()) { // If there was a previous step, use this timepoint as its endpoint
          Step prevStep = steps.remove(steps.size()-1);
          prevStep.calcRate( (i-1), Float.parseFloat(timeMatrix.getString(i-1, 0)) );
          steps.add(prevStep);
        }
        steps.add( new Step(i, Float.parseFloat(timeMatrix.getString(i, 0)), curStepName) ); // Make a new step
        prevStepName = curStepName;
      }
    }
    // Calc rate for last Step
    Step prevStep = steps.remove(steps.size()-1);
    prevStep.calcRate( (timeMatrix.getRowCount()-1), Float.parseFloat(timeMatrix.getString(timeMatrix.getRowCount()-1, 0)) );
    steps.add(prevStep);
    return steps;
  }
  
  ///* Generate time standard */
  //private float calcTimeFactor() {
  //  stepLength = new HashMap<Float, Float>();
  //  float timeFactor = 0f;
  //  ArrayList<Float> stepOccurenceTimes = new ArrayList<Float>();
    
  //  // Assemble one list of timestamps from the data structure that breaks them down per step
  //  for (Map.Entry<String, ArrayList<String>> entry : stepTimePoints.entrySet()) {
  //    ArrayList<String> stepOccurences = entry.getValue();
  //    for (String stepOccurence : stepOccurences) {
  //      stepOccurenceTimes.add(Float.parseFloat(stepOccurence));
  //    }
  //  }
    
  //  // Put timestamps of steps in ascending order
  //  Collections.sort(stepOccurenceTimes);
    
  //  // Find the longest step
  //  float maxLengthOfStep = 0f;
  //  float prevTime = 0f;
  //  for (Float timeOfStep : stepOccurenceTimes) {
  //    float delta = timeOfStep - prevTime;
  //    stepLength.put(timeOfStep, delta);
  //    maxLengthOfStep = ( (delta > maxLengthOfStep) ? delta : maxLengthOfStep);
  //    prevTime = timeOfStep;
  //  }
    
  //  // Now that we have the max length of step, we can normalize all steps to have same frames per second (timepoints per second)
    
  //  // Rate of this step = (rate of longest step * time of longest step) / time of this step
    
  //  timeFactor = maxLengthOfStep;
    
    
  //  return timeFactor;
  //}
  
  //public float getTimeFactor() {
  //  return timeFactor;
  //}
  
  /* Given a time [s], find the nearest timepoint */
  public int getTimePoint(String time) {
    return timeMatrix.findRowIndex(time, 0);
  }
  
  /* Calculate number of time points */
  public int calcNumTimePts() {
    return timeMatrix.getRowCount();
  }
  
  /* Allow access to this instance variable from outside this class */
  public float getWidth() {
    return columnWidth;
  }
  
  /* Allow access to this instance variable from outside this class */
  public float getHeight() {
    return columnHeight;
  }
  
  public List<Step> getStepList () {
    return stepList;
  }
  
  //public void sortStepListByTimePt() {
  //  int tp = 0;
  //  for (Step step : stepList) {
  //    tp = step.getStartTimePt();
  //    if 
  //  }
  //}
  
  /* Return Step object that is occuring during this timepoint */
  public Step getStep(int tp) {
    // Assume stepList is sorted in order of timepoint because that's the order we constructed it in
    Step curStep = stepList.get(0);
    // Step prevStep = stepList.get(0);
    int i = 0;
    for (Step step : stepList) {
      if ( step.getStartTimePt() <= tp ) {
        //curStep = prevStep;
        //prevStep = step;
        // prevStep = curStep;
        curStep = step;
        // println("i: " + i);
      } else {
        break;
      }
      i++;
    }
    // println("Step name: " + curStep.getName());
    return curStep;
  }
  
  //public Map <String, ArrayList<String>> getStepTimePoints() {
  //  return stepTimePoints;
  //}
  
  //public float getStepLength(float current_time) {
  //  float step_length = 0f;
  //  for (float t : stepLength.keySet()) { // Iterate through start times of steps
  //    // We assembled stepLength in chronological order, so we can assume that order here
  //    if (current_time >= t) { // Continue to change the step_length until we go past the correct step (where current_time < t @ i and current_time >= t @ i-1)
  //      step_length = stepLength.get(t);
  //    } else {
  //      break;
  //    }
  //  }
  //  return step_length;
  //}
}
