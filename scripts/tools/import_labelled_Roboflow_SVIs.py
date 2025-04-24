"""
import_labelled_Roboflow_SVIs.py
Dataset Download Script for Roboflow

This script automates the process of downloading labelled SVI dataset from Roboflow
and saves it to the data/processed/labelled_SVI_datasets dir.
The dataset is downloaded in the YOLOv8 format and stored in the following directory structure:
    data/processed/labelled_SVI_datasets/[version_name]/

Depending on which project I was downloading, the PROJECT_NAME variable may need to be changed.
As of 2025-04-17, we have the following projects:
- grey-to-green: 19 classes: (car, heavy-truck, light-truck, bus, bicycle, motorcycle) x (moving, stationary-onstreet, stationary-offstreet) + x_other
- grey-to-green-reduced: 9 classes: (car, heavy-truck, light-truck) x (moving, stationary-onstreet, stationary-offstreet)
- grey-to-green-reduced-2: 3 classes: moving-vehicle, stationary-vehicle-offstreet, stationary-vehicle-onstreet

Usage:
- Ensure you have a valid Roboflow API key.
- Check which project you want to download.
- Run the script and follow the prompts to confirm the download.

Author: Felix Bridgeman
Last updated: 2025-04-17
"""

# Modify script to download the dataset from Roboflow and save it in a specified directory
# Directory should be data/processed/labelled_SVI_datasets/[version_name]/
# e.g. data/processed/labelled_SVI_datasets/v1/

import os
from roboflow import Roboflow
import yaml

# THIS IS MY API KEY! CHANGE IT TO YOUR OWN!
WORKSPACE_ID = 'fbridgeman'
# This is the project name in Roboflow
# The project name has changed depending on how many classes I'm labelling
PROJECT_NAME = 'grey-to-green-reduced'
# THIS IS MY API KEY! CHANGE IT TO YOUR OWN!
API_KEY = 'CBfyNcr7kbpR77E7GwFx'

rf = Roboflow(api_key=API_KEY)

project = rf.workspace(WORKSPACE_ID).project(PROJECT_NAME)

# Get working directory
current_dir = os.getcwd()
print(f"Current working directory: {current_dir}")

# ask if the user wants to deploy the model with yes or y
user_input = input("Do you want to download the dataset inside this current working directory? (yes/y): ").strip().lower()
if user_input not in ['yes', 'y']:
    print("Deployment aborted.")
    exit()
else:
    print("Proceeding with download...")

#data_dir = input("What do you want the data directory to be called? ").strip().lower()
all_data_dir = "data/processed/labelled_SVI_datasets/"

# version_name = input("What version number do you want to deploy? ").strip().lower()
version_name = "v3"

dataset_location = os.path.join(current_dir, all_data_dir, version_name)
# data_location = os.path.join(current_dir, 'data')
# print(f"Data location: {data_location}")

# Ensure the data directory exists
if not os.path.exists(dataset_location):
    os.makedirs(dataset_location)
    print(f"Created data directory at: {dataset_location}")
else:
    print(f"Data directory already exists at: {dataset_location}")

# Download the dataset
dataset = project.version(version_name).download(model_format='yolov8', location = dataset_location)

# with open(f"{dataset.location}/data.yaml", 'r') as f:
#     dataset_yaml = yaml.safe_load(f)
# dataset_yaml["train"] = "../train/images"
# dataset_yaml["val"] = "../valid/images"
# dataset_yaml["test"] = "../test/images"
# with open(f"{dataset.location}/data.yaml", 'w') as f:
#     yaml.dump(dataset_yaml, f)


# Check the location of the data directory
print(f"Dataset downloaded to: {dataset.location}")

# Check the contents of the data directory
data_contents = os.listdir(dataset.location)
print(f"Data directory contents: {data_contents}")


