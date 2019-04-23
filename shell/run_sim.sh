#!/bin/bash

#SBATCH --partition=ultrasound
#SBATCH --mem=16000
#SBATCH --cpus-per-task=8
#SBATCH --array=1-5000%50

date
hostname

module load Matlab/R2017b
matlab -nojvm -nodisplay -nosplash -r "cd('/datacommons/ultrasound/jc500/GIT/imagenet_ultrasound/');tic;sim_img($SLURM_ARRAY_TASK_ID,50);toc;exit;"
