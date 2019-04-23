#!/bin/bash

#SBATCH --partition=ultrasound
#SBATCH --mem=32000
#SBATCH --cpus-per-task=4

date
hostname

module load Matlab/R2017b
matlab -nojvm -nodisplay -nosplash -r "cd('/datacommons/ultrasound/jc500/GIT/imagenet_ultrasound/');tic;prep_save();toc;exit;"