#!/bin/bash

# Allocate a node using salloc
salloc -N 1 -n 1 --time=01:00:00 --job-name=interactive_job

# Get the allocated node name
NODE=$(squeue -u $USER -o "%.6i %.9P %.8j %.8u %.2t %.10M %.6D %R" | grep interactive_job | awk '{print $8}')

# Connect to the allocated node
ssh $NODE