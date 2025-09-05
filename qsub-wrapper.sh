#!/usr/bin/env bash
#$ -cwd
#$ -pe smp 1
#$ -l h_rt=1:0:0
#$ -l h_vmem=2G
#$ -t 1-208
#$ -tc 20
#$ -o $TASK_ID.o
#$ -e $TASK_ID.e

cmd=`sed "${SGE_TASK_ID}q;d" qsub-commands.txt`
eval $cmd
