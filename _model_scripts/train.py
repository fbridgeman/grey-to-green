# Yale HPC
# Trial 2 / Generalized Code
# Updated to take in user settings 12 NOV 2024


from ultralytics import YOLO
import os

# Update ultralytics settings
# PROMPT 1
dataset_input = input("What dataset version do you want to be called? ").strip().lower()
# PROMPT 2
project_input = input("What project version do you want to be called? ").strip().lower()

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

# PROMPT 3
# Prompt the user to choose a model
model_choice = input("Enter the number of the model you want to load: ").strip()

# Validate the choice and load the model
if model_choice in models:
    chosen_model = models[model_choice]
    model = YOLO(chosen_model)
    print(f"Loaded model: {chosen_model}")
else:
    model = YOLO("yolo11x.pt")
    print("Invalid choice. Defaulted to yolo11x.")

# PROMPT 4
gpu_input = input("How many GPUs have you allocated? ").strip().lower()

# PROMPT 5
run_input = input("What do you want this run do you want to be called? ").strip().lower()

# data_location = os.path.join("/gpfs/gibbs/project/miranda/fwb7/yolov8/", dataset_input, "data.yaml")
data_location = os.path.join("/vast/palmer/scratch/miranda/fwb7/yolov8", dataset_input, "data.yaml")
project_location = os.path.join("/gpfs/gibbs/project/miranda/fwb7/yolov8/", project_input)

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





