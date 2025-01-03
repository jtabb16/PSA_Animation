/* Column
 * Author: Jack Tabb
 * Date Created: 2021-02-20
 * Date Last Edited: 2021-02-20
 * Purpose: Draw arrows based on volumetric flowrate
 */

class Arrows {
  float columnHeight;
  private float maxFlowrate = 0; // This is the highest flowrate that either the 0th or Nth CSTR see
  
  /* Construct an Arrow */
  Arrows (Table volFlowrateMatrix, float columnHeight) {
    this.columnHeight = columnHeight;
    
    println("Calculating max flowrate...");
    maxFlowrate = calcMaxFlowrate(volFlowrateMatrix);
  }
  
  /* Draw arrows to indicate volumetric flowrate.
     Negative flow points downward. Positive flow points upward. 0 flow has no arrow. 
     Know what the arrows should look like for HP, LP, DP, or RP.
     Provide a label for the column after determining which mode it is operating in 
  */
  PShape drawArrows(int timepoint, Table volFlowrateMatrix, color cstrColorFirst, color cstrColorLast) {
    PShape arrows = new PShape();
    PShape bottomArrow = createShape(RECT, 0, 0, 0, 0);
    PShape topArrow = createShape(RECT, 0, 0, 0, 0);
    arrows = createShape(GROUP);
    final int numCSTR = volFlowrateMatrix.getColumnCount();
    TableRow volFlowAtTime = volFlowrateMatrix.getRow(timepoint);
    float bottomFlow = volFlowAtTime.getFloat(0); //Find flowrate of 0th CSTR at this timepoint // Units of cc/sec?
    float topFlow = volFlowAtTime.getFloat(numCSTR-1); // Find flowrate of Nth CSTR at this timepoint
    
    // NOTE: Using 0,0 and columnWidth,columnHeight for our coordinates. The function that calls this custom shape can position or scale this differently.
    // Will have to do some math for arrow whose rectangular base I want to remain stationary 
    //  and whose head I want to move b/c the fxn I'm going to call only changes the shaft length, not the head position.
    
    int arrowWidth = 50;
    int bottomArrowLength = 100;
    int topArrowLength = 100;
    int maxArrowLength = 100;
    
    // Scale the length of the arrows to show how much flow is occuring relative to the maximum flow seen at this location at any timepoint.
    // The bottom arrow's length is based on the volumetric flowrate out of or into the 0th CSTR (which isn't really a CSTR, but like a pipe before the 1st CSTR)
    // The top arrow's length is based on the volumetric flowrate out of or into the Nth CSTR
    bottomArrowLength = (int) (maxArrowLength*(Math.abs(bottomFlow) / maxFlowrate));
    topArrowLength = (int) (maxArrowLength*(Math.abs(topFlow) / maxFlowrate));
    
    // Point the arrows up or down
    if (bottomFlow < 0) {
      bottomArrow = drawArrow(0, int(0+columnHeight/2), arrowWidth, bottomArrowLength, true, false, cstrColorFirst);
    } else if (bottomFlow > 0) {
      bottomArrow = drawArrow(0, int(0+columnHeight/2), arrowWidth, bottomArrowLength, false, false, cstrColorFirst);
    }
    if (topFlow < 0) {
      topArrow = drawArrow(0, int(0-columnHeight/2), arrowWidth, topArrowLength, true, true, cstrColorLast);
    } else if (topFlow > 0) {
      topArrow = drawArrow(0, int(0-columnHeight/2), arrowWidth, topArrowLength, false, true, cstrColorLast);
    }
    
    arrows.addChild(bottomArrow);
    arrows.addChild(topArrow);
    return arrows;
  }
  
  /* Draw an arrow with rectangular base starting at specified position. The arrow will be centered at the specified x.
     The height only changes the base of the arrow (the rectangular part), not the height of the head of the arrow.
     The width of both the arrow's head and rectangular base will change based on the specified value. 
  */
  PShape drawArrow(int x, int y, int w, int h, boolean down, boolean top, color cstr_color) {
    int triHeadHeight = 20;
    int triHeadWidthMargin = 5;
    
    // Fix the triangular head at the specified point and extend the rectangle in the correct direction
    if (down) {
      if (top) {
        y -= triHeadHeight;
      } else {
        y += h;
      }
      // Flip the direction of the arrow
      triHeadHeight *= -1;
      h *= -1; 
    } else {
      if (top) {
        y -= h;
      } else {
        y += triHeadHeight;
      }
    }
    
    // An arrow is comprised of a rectangular base and a triangular head
    fill(cstr_color);
    // ERROR: The top arrow should be a different color than the bottom arrow!!!
    
    PShape arrow = new PShape();
    arrow = createShape(GROUP); // Group the rectangle and triangle into this one shape.
    rectMode(CORNER);
    PShape rectBase = createShape(RECT, x-(w/2), y, w, h); // An arrow has a rectangular base
    PShape triHead = createShape(TRIANGLE, x-(w/2)-triHeadWidthMargin, y, x+(w/2)+triHeadWidthMargin, y, x, y-triHeadHeight);// An arrow has a triangular head
    arrow.addChild(rectBase);
    arrow.addChild(triHead);
    
    return arrow;
  }
  
  /* Find the maximum magnitude of flowrate in either the 0th or Nth CSTR
     NOTE: The 0th CSTR is like a pipe in this case. The first real CSTR is at position 1 in the volumetric flowrate data; 
     it is at position 0 in the state matrix data 
  */
  private float calcMaxFlowrate (Table flowMatrix) {
    float maxFlow = 0;
    int numTimePts = flowMatrix.getRowCount();
    int numCSTR = flowMatrix.getColumnCount();
    for (int timePt = 0; timePt < numTimePts; timePt++) { // Iterate through all rows (timepoints)
      // Look at the 0th and Nth CSTR
      float bottomFlow = Math.abs(flowMatrix.getRow(timePt).getFloat(0));
      float topFlow = Math.abs(flowMatrix.getRow(timePt).getFloat(numCSTR-1));
    
      // If the magnitude (regardless of direction) of the 0th or Nth CSTR at this timepoint is 
      //   larger than the current max, then update the maximum value.
      maxFlow = (bottomFlow > maxFlow) ? bottomFlow : maxFlow;
      maxFlow = (topFlow > maxFlow) ? topFlow : maxFlow;
    } // End iteration through timepoints
    return maxFlow;
  }
}
