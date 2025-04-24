
"""
train.py
This script trains a YOLOv8 model using the ultralytics library.
It allows the user to specify various parameters such as dataset version,
project version, model type, and GPU allocation.

I recently modified the script to work off set variables instead of command
line arguments
Inputs: 
- 

Author: Felix Bridgeman
Last updated: 2025-04-17 (made it work of set variables)
"""

## SET VARIABLES
DATASET = 'v4'
CHOSEN_MODEL = "yolo11x.pt"
NUMBER_OF_GPUS = '4'
MODEL_BUILD_SUBDIR = "beta4"
RUN_NAME = "v4_yolo11x"

from ultralytics import YOLO
import os

# Update ultralytics settings
# PROMPT 1
#dataset_input = input("What dataset version do you want to be called? ").strip().lower()
dataset_input = DATASET

# List of available models
models = {
    "1": "yolov8n.pt",
    "2": "yolov8m.pt",
    "3": "yolov8l.pt",
    "4": "yolov8x.pt",
    "5": "yolo11n.pt",
    "6": "yolo11m.pt",
    "7": "yolo11l.pt",
    "8": "yolo11x.pt",
}

# Display the available models
print("Available models:")
for key, value in models.items():
    print(f"{key}: {value}")

# PROMPT 2
# Prompt the user to choose a model
model_choice = input("Enter the number of the model you want to load: ").strip()

model = YOLO(CHOSEN_MODEL)
## Validate the choice and load the model, defaulting to yolo11x if invalid
# if model_choice in models:
#     chosen_model = models[model_choice]
#     model = YOLO(chosen_model)
#     print(f"Loaded model: {chosen_model}")
# else:
#     model = YOLO("yolo11x.pt")
#     print("Invalid choice. Defaulted to yolo11x.")

# PROMPT 3
# gpu_input = input("How many GPUs have you allocated? ").strip().lower()
gpu_input = NUMBER_OF_GPUS

# PROMPT 4
# project_input = input("What do you want this project to be called? ").strip().lower()
project_input = MODEL_BUILD_SUBDIR

# PROMPT 5
#run_input = input("What do you want this run do you want to be called? ").strip().lower()
run_input = RUN_NAME

# data_location = os.path.join("/gpfs/gibbs/project/miranda/fwb7/yolov8/", dataset_input, "data.yaml")
data_location = os.path.join("/vast/palmer/scratch/miranda/fwb7/yolov8", dataset_input, "data.yaml")
project_location = os.path.join("/gpfs/gibbs/project/miranda/fwb7/yolov8/model_builds/", project_input)

if gpu_input == "1":
    gpu_num = 0
elif gpu_input == "2":
    gpu_num = [0,1]
elif gpu_input == "3":
    gpu_num = [0,1,2]
elif gpu_input == "4":
    gpu_num = [0,1,2,3]
else:
    gpu_num = None

# Ensure the project directory exists
if not os.path.exists(project_location):
    os.makedirs(project_location)
    print(f"Created project directory at: {project_location}")
else:
    print(f"Project directory already exists at: {project_location}")

print(data_location)
print(project_location)

# Ask user if they want to continue:
# response = input("Do you want to continue? (yes/no): ").strip().lower()
# if response not in ['yes', 'y']:
#     print("Exiting the program.")
#     exit()
# else:
#     print("Continuing...")

# project.version(DATASET_VERSION).deploy(model_type=”yolov8”, model_path=f”{HOME}/runs/detect/train/”)
# Train the model with MPS
model.train(name = run_input,
              data = data_location,
              project = project_location,
              epochs = 50,
              batch = 16,
              imgsz = 416,
              device = gpu_num,
              verbose = True,
              time = 2,
              plots = True)





