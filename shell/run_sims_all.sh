#!/bin/bash

#SBATCH --partition=ultrasound
#SBATCH --mem=1024
#SBATCH --cpus-per-task=1

date
hostname

jid1=$(sbatch run_sim.sh)
jid2=$(sbatch  --dependency=afterany:$jid1 run_stitch.sh)
