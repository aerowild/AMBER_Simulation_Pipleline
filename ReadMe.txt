These Scripts are to be used with AMBER md simulation packages. However, with little modification, these can even be used with Gromacs md simulation package. 

1) SetUp_MD_Simulations: To automate the traditional all atom explicit MD simulation using AMBER simulation package. The pipeline goes as following:
=================================================================
Topology generation --> Two step system energy minimization --> Gradual heating of the system from 0K to 300K --> Equilibration --> Final production run at NPT
=================================================================

Usage:
'generate_topology.pl': Generate the AMBER topology file of 'Protein' or 'Protein-Ligand complex'. It requires PDB structure file of the protein/Complex, and .Mol2 file of ligand as input. User is given options to choose the force field, PBC box dimensions, ions and other important parameters.
‘setup_md.pl’: This script first checks if the topology has been generated. If not, used can directly generate the topology from the script. Once the topology files are generated, it will set up the above described pipeline. It creates few folders that contain input files and a ‘run.pl’ perl script that can finally be used to run the MD simulations.
Warning: User is always strictly advised to cross-check/update the parameters in the generated input files before executing the ‘run.pl’.

2) ProgressiveHeating_Simulations: To automate the unfolding of the protein at high temperature using all atom explicit MD simulation by AMBER simulation package. The pipeline goes as following:
=================================================================
Topology generation --> Two step system energy minimization --> Gradual heating of the system from 0K to 300K --> Equilibration --> Final production run at NPT --> Heating of the stable system from 300K to 500K 
=================================================================

Usage:
Same as described for ‘SetUp_MD_Simulations’.

