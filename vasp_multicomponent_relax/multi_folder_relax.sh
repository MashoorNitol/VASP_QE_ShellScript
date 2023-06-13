#!/bin/bash

directory=""
for folder in "$directory"*; do
    if [ -d "$folder" ]; then
        rm -r "$folder"
    fi
done


strings=("V" "Nb" "Ta" "Ti" "Zr" "Hf")
folder_names=()

n=${#strings[@]}

for ((i=0; i<n-2; i++)); do
    filename="${strings[i]}"
    potcar1="${strings[i]}_potcar"
    for ((j=i+1; j<n-1; j++)); do
        potcar2="${strings[j]}_potcar"
        for ((k=j+1; k<n; k++)); do
            potcar3="${strings[k]}_potcar"
            folder_name="${strings[i]}${strings[j]}${strings[k]}"
            folder_names+=("$folder_name")
            mkdir "${folder_name}"
            echo "${potcar1}" "${potcar2}" "${potcar3}" "${folder_name}"
            cat "${potcar1}" "${potcar2}" "${potcar3}" > "${folder_name}/POTCAR"
            output=$(grep 'ENMAX' ${folder_name}/POTCAR)
            enmax_values=$(echo "$output" | awk -F'=' '{print $2}' | awk -F';' '{print $1}')
            average_enmax=$(echo "$enmax_values" | awk '{sum+=$1} END {print sum/NR}')
            rounded_value=$(echo "2.0*$average_enmax" | bc -l | xargs printf "%.0f")
            cat >"${folder_name}/POSCAR" <<EOF
Fmm2 poscar
1.0
3.2484977233239203 0.0 0.0
0.0 4.6413440626900710 0.0
0.0 0.0 13.3591466111278230
${strings[i]} ${strings[j]} ${strings[k]}
4 4 4
Direct
0.0  0.0  0.6744343851865776
0.0  0.5  0.1744343851865704
0.5  0.0  0.1744343851865704
0.5  0.5  0.6744343851865776
0.0  0.0  0.9923726856466093
0.0  0.5  0.4923726856466092
0.5  0.0  0.4923726856466092
0.5  0.5  0.9923726856466093
0.5  0.0  0.8331939291668108
0.5  0.5  0.3331939291668107
0.0  0.0  0.3331939291668107
0.0  0.5  0.8331939291668108
EOF
            cat > "${folder_name}/INCAR" <<EOF
Global Parameters
ISTART =  0
ISPIN  =  1
LREAL  = .FALSE.
ENCUT  =  ${rounded_value}
PREC   =  Accurate
#
Lattice Relaxation
NSW    =  100
ISMEAR =  1
SIGMA  =  0.2
IBRION =  2
ISIF   =  3
EDIFF = 1E-8
EDIFFG = -1E-4
EOF
            struct=$(grep -o '.* poscar' ${folder_name}/POSCAR | grep -o '.* ')
            struct="${struct// /}"
            cat >"${folder_name}/submit.sh" <<EOF
#!/bin/bash
#SBATCH --time=16:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=mash@lanl.gov
#SBATCH --job-name=${struct}-${folder_name}
#SBATCH --error myjob_%j.err
#SBATCH -A xd
#
module swap PrgEnv-cray PrgEnv-aocc
module load intel-mkl
#
#
srun  ./vasp_std
rm CHG CHGCAR DOSCAR EIGENVAL IBZKPT *.err  PCDAT REPORT slurm-*.out SYMMETRY *.xml WAVECAR XDATCAR
EOF
            cd ${folder_name}
            cp ../*_std .
            vaspkit -task 102 -file POSCAR -kpr 0.02
            #sbatch submit.sh
            cd ..
        done
    done
done
