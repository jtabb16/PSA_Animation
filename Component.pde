/* Phase
 * Author: Jack Tabb
 * Date Created: 2021-08-15
 * Date Last Edited: 2021-08-19
 * Purpose: To support visualization of multiple (more than two) components (aka "keys")
*/

class Component {
  color componentColor;
  
  color lkColor = 0;
  color hkColor = 0;
  
  // Use this number to locate the first variable for this component in a given CSTR by adding it to the index of a CSTR's first variable in the state matrix.
  // // For example, if you're looking at the 1st CSTR in a 2-phase, 3-component system, the index would be 5 if this was the 3rd component (The indices of the dataset would be 0,1,2,3,4, and 5). 
  // For the 5th CSTR, we'd look at 5*2*3=30 as the first variable relating to CSTR 5. We'd add comp_var_pos=4 to get to 34 as the first variable relevant to the 3rd component
  // NOTE 10/10/2021: Redo this comment after reworking what this var_pos is.
  int comp_var_pos;
  
  ComponentType compType;
  
  
  Component () {
    lkColor = color(0, 0, 75);
    hkColor = color(0, 0, 0);
  }
  
  Component(ComponentType ct, int var_pos, color compColor) {
    this.compType = ct;
    this.componentColor = compColor;
    this.comp_var_pos = var_pos;
    
    lkColor = color(0, 0, 75);
    hkColor = color(0, 0, 0);
  }
  
/*   Generate a color pallete with numColors unique colors 
     Requires colorMode(HSB, 360, 100, 100) for these values to work.
     With help from: https://blog.federicopepe.com/en/2020/05/create-random-palettes-of-colors-that-will-go-well-together/
  */
  private color[] genColorPalette(int numColors) {
    colorMode(HSB, 360, 100, 100);
    color palette[] = new color[numColors];
    
    for (int i = 0; i < numColors; i++) {
      // palette[i] = color(noise(i/numColors)*360, noise(i/numColors)*100, noise(i/numColors)*100);
      float randNum = noise((float)i/numColors*10);
      // println(randNum);
      palette[i] = color( round(randNum*360), round(randNum*100+30), round(randNum*100+20) );
    }
    
    return palette;
  }
  
  private int getVarPos() {
    return comp_var_pos;
  }
  
  private color getColor() {
    return componentColor;
  }
  
  private ComponentType getCompType() {
    return compType;
  }
  
  private color getLKColor() {
    return lkColor;
  }
  
  private color getHKColor() {
    return hkColor;
  }
}
