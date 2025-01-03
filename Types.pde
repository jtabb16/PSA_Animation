/* Column
 * Author: Jack Tabb
 * Date Created: 2019-07-14
 * Date Last Edited: 2021-02-21
 * Purpose: To handle the drawing and calculations dealing with a Column
*/

enum PhaseType {
  // ALL_PHASE, FLUID, SOLID;
  FLUID, SOLID;
  
  /* Helper function for accessing the correct columns in the data matrix for the desired phase */
  private Set<Integer> setupDesiredPhase(PhaseType phaseType) {
    // Notes:
    // Options are ThetaA ThetaB QA QB
    // The Theta's are for fluid phase
    // The Q's are for solid phase
    Set<Integer> desiredPhase = new TreeSet<Integer>();
    switch(phaseType) {
      //case ALL_PHASE: // Theta's and Q's
      //  desiredPhase.addAll(Arrays.asList(0,1,2,3));
      //  break;
      case FLUID: // Just the Theta's
        desiredPhase.addAll(Arrays.asList(0,1));
        break;
      case SOLID: // Just the Q's
        desiredPhase.addAll(Arrays.asList(2,3));
        break;
      default: // Default to All Phases
        desiredPhase.addAll(Arrays.asList(0,1,2,3));
        break;
    }
    return desiredPhase;
  }
  
}

enum ComponentType {
  LK, ALL_COMP, HK;
  
  /* Helper function for accessing the correct columns in the data matrix for the desired components */
  private Set<Integer> setupDesiredComp(ComponentType compType) {
    // Notes:
    // Options are ThetaA ThetaB QA QB
    // The A's are for Nitrogen (HK)
    // The B's are for Methane (Natural Gas -- LK)
    Set<Integer> desiredComp = new TreeSet<Integer>();
    switch(compType) {
      case ALL_COMP: // Both A and B
        desiredComp.addAll(Arrays.asList(0,1,2,3));
        break;
      case HK: // Just A
        desiredComp.addAll(Arrays.asList(0,2));
        break;
      case LK: // Just B
        desiredComp.addAll(Arrays.asList(1,3));
        break;
      default: // Default to all components
        desiredComp.addAll(Arrays.asList(0,1,2,3));
        break;
    }
    return desiredComp;
  }
  
}
