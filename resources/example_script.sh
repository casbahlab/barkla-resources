#!/bin/sh
#SBATCH -D ./
#SBATCH --export=ALL
#SBATCH -J tester
#SBATCH -o tester.%N.%j.out
#SBATCH -e tester.%N.%j.err
#SBATCH -p nodes
#SBATCH -N 1
#SBATCH -n 10
#SBATCH -t 00:05:00

# Set your maximum stack size to unlimited
ulimit -s unlimited
# Set OpenMP thread number
export OMP_NUM_THREADS=$SLURM_NTASKS

# Load conda and relevant modules
module purge
module add libs/nvidia-cuda/12.4.0/bin
module add libs/cudnn/8.9.2.26+cuda12
module add apps/anaconda3/2023.03-poetry
#use source activate gpu to get the gpu virtual environment
conda activate <your_env>

# List all modules
module list

echo =========================================================
echo SLURM job: submitted  date = `date`
date_start=`date +%s`

hostname
echo Current directory: `pwd`

echo "CUDA_VISIBLE_DEVICES : $CUDA_VISIBLE_DEVICES"
echo "GPU_DEVICE_ORDINAL   : $GPU_DEVICE_ORDINAL"

echo "Running jobs:"

/users/<your_username>/.conda/envs/<your_env>/bin/python \
  -u <path_to_script_directory>/example.py

#deactivate the gpu virtual environment
conda deactivate <your_env>

date_end=`date +%s`
seconds=$((date_end-date_start))
minutes=$((seconds/60))
seconds=$((seconds-60*minutes))
hours=$((minutes/60))
minutes=$((minutes-60*hours))
echo =========================================================
echo SLURM job: finished   date = `date`
echo Total run time : $hours Hours $minutes Minutes $seconds Seconds
echo =========================================================
