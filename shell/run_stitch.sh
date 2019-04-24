#!/bin/bash

#SBATCH --partition=ultrasound
#SBATCH --mem=8000
#SBATCH --cpus-per-task=8
#SBATCH --array=1-500%100

date
hostname

module load Matlab/R2017b
matlab -nojvm -nodisplay -nosplash -r "cd('/datacommons/ultrasound/jc500/GIT/imagenet_ultrasound/simulation/');tic;stitch_img($SLURM_ARRAY_TASK_ID,20);toc;exit;"