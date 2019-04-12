#!/bin/bash

#SBATCH --partition=ultrasound
#SBATCH --mem=32000
#SBATCH --cpus-per-task=16
#SBATCH --array=1-100%100

date
hostname

module load Matlab/R2017b
matlab -nojvm -nodisplay -nosplash -r "cd('/datacommons/ultrasound/jc500/GIT/imagenet_ultrasound/');tic;stitch_img($SLURM_ARRAY_TASK_ID,20);toc;exit;"