#!/bin/bash

#SBATCH --partition=ultrasound
#SBATCH --mem=32000
#SBATCH --cpus-per-task=4
#SBATCH --array=11,96%2

date
hostname

module load Matlab/R2017b
matlab -nojvm -nodisplay -nosplash -r "cd('/datacommons/ultrasound/jc500/GIT/imagenet_ultrasound/');tic;stitch_img($SLURM_ARRAY_TASK_ID,50);toc;exit;"