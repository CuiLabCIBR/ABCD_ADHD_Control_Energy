#!/bin/bash
#SBATCH -p q_cn,q_fat,q_fat_c,q_fat_l
#SBATCH --ntasks=1 # Run a single serial task
#SBATCH --cpus-per-task=2
#SBATCH -e job.%j.log # Standard error
#SBATCH --job-name=NullNet

module load MATLAB/R2019a
cd /ibmgpfs/cuizaixu_lab/yanghang/projects/abcd_adhd_control_energy/scripts/Energy_Calculation/
subi=$1 
matlab -singleCompThread -nodisplay -nosplash -r "Make_NullNetworks($subi, 'schaefer400')"
matlab -singleCompThread -nodisplay -nosplash -r "EnergyCal_Sub_Null($subi, 'all0In_2Back0Back', 'schaefer400')"