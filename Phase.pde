/* Phase
 * Author: Jack Tabb
 * Date Created: 2018-10-16
 * Date Last Edited: 2021-08-19
 * Purpose: To handle the drawing and calculations dealing with a Phase
*/

// The colors used to construct the gradient.
//final color minColor = color(255); // White -- Provides a faded color appearance to construct a gradient out of
//final color maxColorA = color(0,0,255); // Blue for Nitrogen -- Heavy Key
//final color maxColorB = color(0); // Black for Methane (AKA Natural Gas) -- Light Key

class Phase {
  final Table stateMatrix;
  final Table volFlowrateMatrix;
  // Set<Integer> desiredPhaseAndComp;
  final int numCSTR;
  int numVarPerCSTR;
  final float phaseWidth;
  final float phaseHeight;
  float colorBarHeight; // How tall to make a color bar
  PhaseType phaseType;
  // ComponentType compMode;
  int colorNormalizationMargin = 10;
  int widthNormalizationMargin = 0;
  color firstCSTRColor = 0;
  color lastCSTRColor = 0;
  
  List<Component> compList; // List of components to display. Changing the display mode of the animation (HK, LK, ALL_COMP, etc.) should change this list
  
  // We can change the normalization factors, but we always want to know what the max amount was in case we want to go back, so we need 2 different data structures.
  // The normalization factor doesn't have to be the max amount, but it will be by default.
  Map<ComponentType, Float> maxAmtCompAnyCSTRInPhase; // The maximum amount seen for each component in any CSTR in this phase at any timepoint
  Map<ComponentType, Float> colorNormalizationFactor;
  Map<ComponentType, Float[]> maxAmtCompEachCSTRInPhase; // The maximum amount seen for each component in each CSTR in this phase at any timepoint
  Map<ComponentType, Float[]> widthNormalizationFactorList;
  Map<ComponentType, Float> widthNormalizationFactor;
  
  // Each CSTR will have a max amount in either the fluid or solid phase, depending on the widthNormalizationType.
  // This value will be stored for the 0th CSTR in the 0th position of an array and for the Nth CSTR in the Nth position of the array.
  // float [] cstrMaxAmt;
  
  // This number helps find the position of data in the state matrix. A component can be seen in multiple phases.
  int phase_var_pos;
  
  /* Default Constructor */
  Phase() {
    stateMatrix = new Table();
    volFlowrateMatrix = new Table();
    numCSTR = 1;
    phaseWidth = 1;
    phaseHeight = 1;
    colorBarHeight = 1;
  }
  
  /* Construct a Phase (Custom Constructor)*/
  Phase(Table stateMatrix, Table volFlowrateMatrix, float phaseWidth, float phaseHeight, PhaseType phaseType, int var_pos, List<Component> componentList, int numVarPerCSTR) {
    println("Initializing " + phaseType + " Phase...");
    this.stateMatrix = stateMatrix;
    TableRow amtData = stateMatrix.getRow(0); // Get current timepoint's amount data from all CSTRs
    this.numVarPerCSTR = numVarPerCSTR;
    numCSTR = amtData.getColumnCount() / numVarPerCSTR; // Number of CSTRs to draw
    
    this.volFlowrateMatrix = volFlowrateMatrix;
    
    this.phaseWidth = phaseWidth;
    this.phaseHeight = phaseHeight;
    
    this.colorBarHeight = this.phaseHeight/numCSTR; // Make each colorbar take up a fraction of the height of a phase
    
    this.phase_var_pos = var_pos;
    this.phaseType = phaseType;
    // this.compType = compType;
    this.compList = componentList;
    
    println("Calculating max amount for " + phaseType + " Phase...");
    
    // Initialize the data structures
    maxAmtCompAnyCSTRInPhase = new HashMap<ComponentType, Float>();
    colorNormalizationFactor = new HashMap<ComponentType, Float>();
    maxAmtCompEachCSTRInPhase = new HashMap<ComponentType, Float[]>();
    widthNormalizationFactorList = new HashMap<ComponentType, Float[]>();
    widthNormalizationFactor = new HashMap<ComponentType, Float>();
    
    //desiredPhaseAndComp = phaseType.setupDesiredPhase(phaseType);
    //desiredPhaseAndComp.retainAll(compType.setupDesiredComp(compType));
  }
  
  /* Fill the phase according to the data at the specified timepoint */
  PShape drawColContents(int timepoint) {
    // Note: At this timepoint, we are looking at one row of the stateMatrix
    //       We are also assuming that there are 4 data phases for each CSTR
    
    TableRow timeptAmtData = stateMatrix.getRow(timepoint); // Get current timepoint's amount data from all CSTRs
    
    // The PShape object that, when drawn, represents the amounts of the species in each CSTR
    PShape coloredCSTRs = new PShape(); // Array of CSTRs to draw
    coloredCSTRs = createShape(GROUP); // Each CSTR is a shape. Group them into this one shape.
    
    // float lastColorBar_X = 0;
    float lastColorBar_Y = 0;
    
    // Determine fixed height of each color bar:
    colorBarHeight = (float) (phaseHeight / numCSTR);
    int drawnColorBarHeight = ceil(colorBarHeight); // Need to properly round instead of relying on truncation -- there are no fractional pixels.
    
    firstCSTRColor = 0;
    lastCSTRColor = 0;
    
     for (int cstrIter = 0; cstrIter < numCSTR*numVarPerCSTR; cstrIter+=numVarPerCSTR) { // Iterate through all CSTR data
     // for (int cstrIter = 0; cstrIter < numCSTR; cstrIter++) { // Iterate through all CSTR data
      // NOTE: The exact CSTR we are in is represented by cstrIter / numVarPerCSTR. This relies on integer math (truncation)
      
      // Determine X coordinate for this colorbar
      int colorBar_X = 3;
      // Determine Y coordinate for this colorbar
      float colorBar_Y = lastColorBar_Y - colorBarHeight;
      // Note: Casting colorBar_Y and colorBarHeight from double or float to int truncates instead of rounds. So, occasionally, 
      //     the error is visible as a gap between two color bars.
      //     Need to properly round to avoid this issue. But, even using the traditional rounding method will cause occasional gaps. 
      //      I must use the ceiling function so the rounding is performed consistently throughout the stack of CSTRs.
      int drawnColorBarY = ceil(colorBar_Y); // Need to properly round instead of relying on truncation -- there are no fractional pixels.
      
      // float [] colorBarWidths = new float [compList.size()];
      // int compIndex = 0;
      
      float lkAmt = 0; // Amount of light key in this CSTR in this Phase
      float hkAmt = 0; // Amount of heavy key in this CSTR in this Phase
      
      for (Component comp : compList) { // Iterate through list of components that are in this phase
        // Determine the width to draw the colorBar for this component
        //float compAmtInPhase = timeptAmtData.getFloat(cstrIter + comp.getVarPos() + phase_var_pos);
        // Adding 1 to phase_var_pos and comp_var_pos b/c they have 0 index. Subtracting one at the end b/c our data has 0 index.
        float compAmtInPhase = timeptAmtData.getFloat(cstrIter + (phase_var_pos * compList.size()) + comp.getVarPos());
        // float colorBarWidth = (compAmtInPhase / widthNormalizationFactor.get(comp.getCompType()))*phaseWidth;
        float colorBarWidth = (compAmtInPhase / widthNormalizationFactor.get(ComponentType.ALL_COMP))*phaseWidth;
        //if (cstrIter < 20) {
        //  println("Phase " + phaseType + ", Component " + comp.getCompType() + ": " + compAmtInPhase / widthNormalizationFactor.get(ComponentType.ALL_COMP));
        //}
          
        // float colorBarWidth = (maxAmtCompAnyCSTRInPhase.get(ComponentType.ALL_COMP) / widthNormalizationFactor.get(ComponentType.ALL_COMP))*phaseWidth;
        //float colorBarWidth = phaseWidth;
       
        //if (comp.getVarPos() <= 1) {
        //  println("Fluid phase fraction = " + colorBarWidth/phaseWidth);
        //}
        
        //if (comp.getVarPos() > 1) {
        //  println("Solid phase fraction = " + colorBarWidth/phaseWidth);
        //}
        
        if (comp.getCompType() == ComponentType.LK) {
          lkAmt += compAmtInPhase;
        }
        
        if (comp.getCompType() == ComponentType.HK) {
          hkAmt += compAmtInPhase;
        }
        
        rectMode(CORNER);
        noStroke();
        PShape colorBar = createShape(RECT, colorBar_X, drawnColorBarY, colorBarWidth, drawnColorBarHeight);
        colorBar.setFill(comp.getColor());
        coloredCSTRs.addChild(colorBar);
        
        colorBar_X += colorBarWidth;
        // compIndex++;
      }
      lastColorBar_Y -= colorBarHeight;
      
      
      
      //// Save the color of the first CSTR
      if (cstrIter == 0) {
        // firstCSTRColor = (int)((lkAmt/(lkAmt+hkAmt))*compList.get(0).getLKColor() + (hkAmt/(lkAmt+hkAmt))*compList.get(0).getHKColor()); // Weighted average
        //color fromColor = (int) (lkAmt/(lkAmt+hkAmt))*compList.get(0).getLKColor();
        //color toColor = (int) (hkAmt/(lkAmt+hkAmt))*compList.get(0).getHKColor();
        //firstCSTRColor = lerpColor(fromColor, toColor, 0.5);
        
        firstCSTRColor = lerpColor(compList.get(0).getHKColor(), compList.get(0).getLKColor(), (lkAmt/(lkAmt+hkAmt)) );
      }
      
      // Save the color of the last CSTR
      if (cstrIter == numCSTR*numVarPerCSTR - numVarPerCSTR) {
        // lastCSTRColor = (int)((lkAmt/(lkAmt+hkAmt))*compList.get(0).getLKColor() + (hkAmt/(lkAmt+hkAmt))*compList.get(0).getHKColor()); // Weighted average
        //color fromColor = (int) (lkAmt/(lkAmt+hkAmt))*compList.get(0).getLKColor();
        //color toColor = (int) (hkAmt/(lkAmt+hkAmt))*compList.get(0).getHKColor();
        //lastCSTRColor = lerpColor(fromColor, toColor, 0.5);
        
        lastCSTRColor = lerpColor(compList.get(0).getHKColor(), compList.get(0).getLKColor(), (lkAmt/(lkAmt+hkAmt)) );
      }
    } // End iteration through all CSTR data

    
    return coloredCSTRs; // Return the shape to be drawn on screen
  }
  
  ///* Calculate the amount of each component in the desired phase(s). */
  //public float [] calcCompAmt(TableRow col_amt_data, int cstr_index) {
  //  float [] comp_amt = new float [2];
    
  //  // Get ThetaA ThetaB QA QB, if desired. Otherwise, store a 0.0 as the amt for the Theta or Q.
  //  // By setting the value to 0, we are treating it as if it's not there. So, the code will be in place to handle all values, or focus on specific values.
  //  float[] cstrAmtData = new float[numVarPerCSTR];
  //  for (int i=0; i < numVarPerCSTR; i++) {
  //    if (desiredPhaseAndComp.contains(i)) {
  //      cstrAmtData[i] = col_amt_data.getFloat(cstr_index+i);
  //    } else {
  //      cstrAmtData[i] = 0.0;
  //    }
  //  }
    
  //  // Naively compute the amount of each component, relying on the above logic to filter the data to what the user desires.
  //  // (Using cstrAmtData instead of colAmtData to enable the above logic.)
  //  // So, the user can focus on both components in solid phase, both components in fluid phase, both components in both phases, 
  //  //    one component in solid phase, one component in fluid phase, or one component in both phases.
  //  comp_amt[0] = cstrAmtData[0] + cstrAmtData[2]; // HK -- Nitrogen ("Component 'A' Amount")
  //  comp_amt[1] = cstrAmtData[1] + cstrAmtData[3]; // LK -- Methane (Natural Gas) ("Component 'B' Amount")
    
  //  return comp_amt;
  //}
  
  /* Calculate the color from a gradient for a CSTR */
  //public color calcCSTRColor(float compAAmt, float compBAmt, float maxAmt) {
  //  // Factor to determine WHICH COLOR.
  //  // The more A there is, the closer the color should be to that side of the gradient.
  //  // If only A is desired, then this calculation will still work.
  //  float colorScaleFactorPigment = compAAmt / (compAAmt + compBAmt);
    
  //  // Factor to determine HOW MUCH COLOR.
  //  // The color is scaled to a gradient determined by how close this amount variable
  //  // is to the max amount of any species at any timepoint in this system.
  //  // Find the ratio of (total sum amount in this CSTR at this timepoint) to the (max total sum 
  //  //     amount seen in the phase at any timepoint).
  //  // The larger the ratio, the stronger the color (less faded (less white))
  //  float colorScaleFactorStrength = (compAAmt + compBAmt) / maxAmt;
         
  //  // Determine the color to use for this CSTR to represent its components
  //  // Looking at our scaling factor, No A means it's going to be the B color. No B means it's going to be the A color
  //  // Any values in between will be on a gradient that goes from blue to black.
  //  //                lerpColor(from,    , to       , factor between 0 and 1);
  //  color barColorPigmentScaled = lerpColor(maxColorB, maxColorA, (float)colorScaleFactorPigment);
  //  // Looking at our scaling factor, we adjust how strong the color is. It's based on how much material is in this CSTR
  //  // compared to the most amount of material seen in any CSTR ever.
  //  // The paler the color (the less amount), the whiter it is on the gradient.
  //  color barColorStrengthScaled = lerpColor(minColor, barColorPigmentScaled, (float)colorScaleFactorStrength);
    
  //  return barColorStrengthScaled;
  //}
  
  public color getFirstCSTRColor() {
    return firstCSTRColor;
  }
  
  public color getLastCSTRColor() {
    return lastCSTRColor;
  }
  
  /* Allow access to this instance variable from outside this class */
  public float getColorBarHeight() {
    return colorBarHeight;
  }
  
  /* Allow access to this instance variable from outside this class */
  public int getNumVarPerCSTR() {
    return numVarPerCSTR;
  }
  
  public PhaseType getPhaseType() {
    return phaseType;
  }
  
  //public void setColComp(ComponentType ct) {
  //  compType = ct;
  //  desiredPhaseAndComp = phaseType.setupDesiredPhase(phaseType);
  //  desiredPhaseAndComp.retainAll(compType.setupDesiredComp(compType));
  //}
  
  /* Set this phase's component list to be the provided list */
  public void setPhaseCompList(List clist) {
    compList = clist;
    //desiredPhaseAndComp = phaseType.setupDesiredPhase(phaseType);
    //desiredPhaseAndComp.retainAll(compType.setupDesiredComp(compType));
  }
  
  //public ComponentType getColCompType() {
  //  return compType;
  //}
  
  public Boolean hasComp(Component comp) {
    return compList.contains(comp);
  }
  
  // public List getColCompList() {
  //  return compType;
  //}
  
  public int getNumCSTR() {
    return numCSTR;
  }
  
  /* Get the maximum amount of the specified component out of all CSTRs in this phase (used for CSTR color normalization) */
  public float getMaxAmtCompAnyCSTRInPhase(ComponentType ct) {
    return maxAmtCompAnyCSTRInPhase.get(ct);
  }
  
  public float getColorNormalizationFactor(ComponentType ct) {
    return colorNormalizationFactor.get(ct);
  }
  
  public Float[] getwidthNormalizationFactorList(ComponentType ct) {
    return widthNormalizationFactorList.get(ct);
  }
  public Float getWidthNormalizationFactor(ComponentType ct) {
    return widthNormalizationFactor.get(ct);
  }
  
  private int getVarPos() {
    return phase_var_pos;
  }
  
  public int getColorNormalizationMargin() {
    return colorNormalizationMargin;
  }
  
  public List<Component> getCompList() {
    return compList;
  }
  
  /* Each phase has a normalization factor (for color of each CSTR) that is, by default, the max amount seen in any CSTR (in that phase) at any timepoint. */
  public void setMaxAmtAnyCSTRInPhase(ComponentType comp_type, float max_amt) {
    maxAmtCompAnyCSTRInPhase.put(comp_type,max_amt);
  }
  public void setColorNormalizationFactor(ComponentType comp_type, float norm_factor) {
    colorNormalizationFactor.put(comp_type,norm_factor);
  }
  
  /* Each CSTR has a normalization factor (for width of each CSTR) that is, by default, the max amount seen in that CSTR at any timepoint. */
  public void setMaxAmtEachCSTRInPhase(ComponentType ct, Float[] mc) {
    maxAmtCompEachCSTRInPhase.put(ct,mc);
  }
  public void setwidthNormalizationFactorList(ComponentType ct, Float[] nf) {
    widthNormalizationFactorList.put(ct, nf);
  }
  public void setWidthNormalizationFactor(ComponentType ct, Float nf) {
    widthNormalizationFactor.put(ct, nf);
  }
  
  /* Reset this component's normalization factor to be the max amount seen */
  public void resetColorNormalizationFactor(ComponentType ct) {
    colorNormalizationFactor.put(ct, maxAmtCompAnyCSTRInPhase.get(ct));
  }
  
  public void setColorNormalizationMargin(int margin) {
    colorNormalizationMargin = margin;
  }
}// End Phase
