# PSA Animation
Main file is PSA_Animation.pde

Dependencies:
Using version 3.5.4 of Processing (Java framework)
Using the Processing IDE
Need G4P library for Sliders, Buttons, Text Fields, etc.
Using G4P version 4.3.6
To Install it, go to Sketch -> Import Library ... -> Add Library ... -> (Search for G4P) -> Install G4P by Peter Lager
Using java util for data structures such as Lists, Sets, etc.

-------------------------------------------------------------------------------------------------------------------------
## Animated Interactive Data Visualization Tool for Pressure Swing Adsorption Simulations

Jack B. Tabb[1], Taehun Kim[2] (@taehunk333), Joseph K. Scott[2] [1] Process Control & Data Solutions, Ramboll, Charlotte, NC [2] Chemical and Biomolecular Engineering, Georgia Institute of Technology

This research poster presentation will showcase an interactive, animated visualization tool for pressure swing adsorption (PSA) process simulation data. The tool uses Processing, a Java-based development environment, and allows a side-by-side comparison of relative distribution of each species inside both gaseous and adsorbed phases over time. Furthermore, by running multiple instances of the tool, the user can simultaneously compare different simulation data. This new visualization paradigm enables practical applications such as adsorbent screening and the development of operation policies for PSA processes.

Due to the dynamic nature of fixed bed PSA processes, their spatiotemporal behavior cannot be fully characterized by static graphs. For example, several 2-D plots are necessary to display a moving concentration wave front along the axial direction at various timepoints. These crowded graphs are difficult to interpret and do not contextualize the results. Commercial PSA process simulators offer 2-D plotting functionalities, where local behavior of the system is visualized by ignoring the other dimension. Such 2-D plots cannot explain a global behavior of the dynamics in the system and are not practical for providing an overall analysis of PSA process simulation results. Modern technology has enabled new means of representing data: interactive, animated data visualizations. These allow 2-D plots to morph over time and change according to user input in real time. Drawing inspiration from animated plots and from population pyramids, we fashioned a tool to better understand the dynamics of an entire PSA cycle. 

Using the animation or watching a video of it is required to get a true sense of its capabilities. However, one frame of the animation is still useful. Figure 1 shows a low-pressure step (analogous to a Skarstrom Cycle’s desorption (purge) step), simulated in an adsorption column discretized into 1000 well-mixed volumes. The width of the 1000 rectangular bars on the left (gas phase) and on the right (adsorbed phase) are updated in each frame of the animation to represent relative amounts of a light key (gray) and a sum of all heavy keys (black) in each phase at the current timepoint.

This tool empowers users to quickly get a sense of and obtain insights from the entire PSA process simulation dataset. It aids the troubleshooting of simulation results, as well as the design of PSA operation policies. Furthermore, it contributes to the development of intuition, and helps newcomers grasp core PSA concepts, thereby lowering barriers to adopting PSA technology. It raises awareness in the separations community to explore our data visualization and analysis options, inspires others to experiment with this form of data visualization, and encourages interdisciplinary collaborations.

Keywords
Product Design
Separations (Adsorption & Ion Exchange)
New Research Areas
