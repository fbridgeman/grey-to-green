#!/bin/bash

#SBATCH --partition=gpu
#SBATCH --job-name=validate_all4_models_ALL_confs
#SBATCH --output=val_ALL.txt
#SBATCH --ntasks=1
#SBATCH --gpus=4
#SBATCH --cpus-per-gpu=4
#SBATCH --mem-per-cpu=5G
#SBATCH --time=4:00:00
#SBATCH --mail-user=felix.bridgeman@yale.edu
#SBATCH --mail-type=ALL

module load miniconda
# using your anaconda environment
cd /gpfs/gibbs/project/miranda/fwb7/yolov8
conda activate myenv3.10_01
python validate_cell.py
