# DFT Structural Relaxation for Multi-Component Systems

This script allows you to create a multi-component folder and perform DFT structural relaxation of the Fmm2 structure for all possible combinations of the components. The structure can be visualized [here](https://materialsproject.org/materials/mp-1217905?formula=TaNbV).

## Prerequisites

Before running the script, make sure you have the following:

1. All single element POTCAR files in the directory.
2. The single POTCAR files should be named as follows: Ta_potcar, Nb_potcar, and so on.
3. Install vaspkit in your system to calculate KPOINTS. You can find more information about vaspkit [here](https://vaspkit.com/).

## Instructions

1. Modify the job script and executable according to your system. The current job script is specific to the system using vasp_std as the executable.
2. Uncomment the line "#sbatch submit.sh" to run the jobs when you are ready.

Please note that this script assumes a specific directory structure and file naming convention. Make sure to adjust the script accordingly if your setup differs.

For any additional information or support, please contact [mash@lanl.gov].
