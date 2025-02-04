#!/bin/bash

#SBATCH --partition=gpu
#SBATCH --job-name=yolo11m_test1
#SBATCH --output=yolo11m_test1_job.txt
#SBATCH --ntasks=1
#SBATCH --gpus=4
#SBATCH --cpus-per-gpu=4
#SBATCH --mem-per-cpu=5G
#SBATCH --time=2:00:00
#SBATCH --mail-user=felix.bridgeman@yale.edu
#SBATCH --mail-type=ALL

module load miniconda
# using your anaconda environment
cd /gpfs/gibbs/project/miranda/fwb7/yolov8
conda activate myenv3.10_01
python train2.py