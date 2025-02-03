#!/bin/bash

#SBATCH --partition=gpu
#SBATCH --job-name=predict_remaining_075
#SBATCH --output=predict_remaining_075.txt
#SBATCH --ntasks=1
#SBATCH --gpus=1
#SBATCH --cpus-per-gpu=1
#SBATCH --mem-per-cpu=40G
#SBATCH --time=12:00:00
#SBATCH --mail-user=felix.bridgeman@yale.edu
#SBATCH --mail-type=ALL

module load GCC/13.3.0
module load miniconda
# using your anaconda environment
cd /gpfs/gibbs/project/miranda/fwb7/yolov8
conda activate myenv3.10_01
python predict2.py