#!/bin/bash

#SBATCH --partition=gpu
#SBATCH --job-name=tune_b4_A
#SBATCH --output=tune_b4_A.txt
#SBATCH --ntasks=1
#SBATCH --gpus=4
#SBATCH --cpus-per-gpu=4
#SBATCH --mem-per-cpu=5G
#SBATCH --time=12:00:00
#SBATCH --mail-user=felix.bridgeman@yale.edu
#SBATCH --mail-type=ALL

module load miniconda
# using your anaconda environment
cd /gpfs/gibbs/project/miranda/fwb7/yolov8
conda activate myenv3.10_01
python tune_v4.py