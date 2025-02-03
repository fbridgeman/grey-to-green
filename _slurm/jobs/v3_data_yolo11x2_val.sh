#!/bin/bash

#SBATCH --partition=gpu
#SBATCH --job-name=v3_data_yolo11x2_val
#SBATCH --output=v3_data_yolo11x2_val.txt
#SBATCH --ntasks=1
#SBATCH --gpus=3
#SBATCH --cpus-per-gpu=4
#SBATCH --mem-per-cpu=5G
#SBATCH --time=2:05:00
#SBATCH --mail-user=felix.bridgeman@yale.edu
#SBATCH --mail-type=ALL

module load miniconda
# using your anaconda environment
cd /gpfs/gibbs/project/miranda/fwb7/yolov8
conda activate myenv3.10_01
python validate.py