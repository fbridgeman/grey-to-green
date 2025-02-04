
import os
from roboflow import Roboflow
import yaml


rf = Roboflow(api_key='CBfyNcr7kbpR77E7GwFx')

project = rf.workspace('fbridgeman').project('grey-to-green-reduced')

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

user_input2 = input("What do you want the data directory to be called? ").strip().lower()
version_name = input("What version number do you want to deploy? ").strip().lower()


data_location = os.path.join(current_dir, user_input2)
# data_location = os.path.join(current_dir, 'data')
# print(f"Data location: {data_location}")

# Ensure the data directory exists
if not os.path.exists(data_location):
    os.makedirs(data_location)
    print(f"Created data directory at: {data_location}")
else:
    print(f"Data directory already exists at: {data_location}")

# Download the dataset
dataset = project.version(version_name).download(model_format='yolov8', location = data_location)# , location=data_location

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


