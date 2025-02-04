
from ultralytics import YOLO
import ultralytics as ultra
# from IPython.display import display, Image
import os
import yaml
import json
import pandas as pd

# Update ultralytics settings
data_dir = "/vast/palmer/scratch/miranda/fwb7/yolov8/v3/data.yaml"
project_dir = "/gpfs/gibbs/project/miranda/fwb7/yolov8/beta3"
gpu_num = [0,1,2,3]
selected_model_name = "v3_data_yolo11x2"
args = "args.yaml"
model_dir = os.path.join(project_dir, selected_model_name)
model_args_dir = os.path.join(model_dir, args)
weights = 'weights/best.pt'
weights_dir = os.path.join(model_dir, weights)
print(data_dir)
print(project_dir)
print(selected_model_name)

# PROMPT 1
#gpu_input = input("How many GPUs have you allocated? ").strip().lower()

# Print ultralytics settings
# print(ultra.settings())

# Ask user if they want to continue:
# response = input("Do you want to continue? (yes/no): ").strip().lower()
# if response not in ['yes', 'y']:
#     print("Exiting the program.")
#     exit()
# else:
#     print("Continuing...")

# Provide a list of models that are directories within "/gpfs/gibbs/project/miranda/fwb7/yolov8/beta1"
# model_directory = "/gpfs/gibbs/project/miranda/fwb7/yolov8/beta1"
# models = [d for d in os.listdir(model_directory) if os.path.isdir(os.path.join(model_directory, d))]

# print("Available models:")
# for model in models:
#     print(model)

# Ask user which model they want to load
#selected_model_name = input(f"Which model do you want to load? ({'Choice: '.join(models)}): ").strip().lower()
# selected_model_location = os.path.join(model_directory, selected_model_name)
# selected_model_args = os.path.join(selected_model_location, 'args.yaml')

# print("Selected model location:", selected_model_location)

# Read original params from the args.yaml file
with open(model_args_dir, 'r') as file:
    args = yaml.load(file, Loader=yaml.FullLoader)
    # Original dataset location
    original_data_location = args['data']
    # Original batch size
    og_batch_size = args['batch']
    # Original image size
    og_image_size = args['imgsz']
    # Original epochs
    og_epochs = args['epochs']

# model = YOLO()  # load train2 model
model = YOLO(weights_dir)
print("Selected model name", model.model_name)
print("Validating dataset saved in:", original_data_location)

# validation name
validation_name = f"{selected_model_name}_VAL"
validation_dir = os.path.join(project_dir, validation_name)

# validate the model
print("VALIDATING THE MODEL NOW")
results = model.val(data = original_data_location,
                    name = validation_name,
                    project = project_dir,
                    device = gpu_num,
                    imgsz = og_image_size,
                    epochs = og_epochs,
                    batch = 16,
                    verbose = True,
                    plots = True,
                    save_json = True)

# save results so they can be accessed later
results.
# print the results
print(results)
print(f"mAP50: {results.box.map50}")  # map50 [1]
print(f"mAP50-95: {results.box.map}")  # map50-95 [1]
# print(f"mAP50 for each category: {results.box.map50s}")  # list of mAP50 for each category
# print(f"mAP50-95 for each category: {results.box.maps}")  # list of mAP50-95 for each category

# # convert saved results from JSON file to CSV
# # Assuming your JSON results are saved as 'results.json'
# results_json = f"{project_dir}/results/{validation_name}/results.json"

# # read the JSON file
# with open(results_json, 'r') as file:
#     data = json.load(file)

# # Convert JSON to DataFrame then save as CSV
# df = pd.DataFrame(data)

# # Print df
# print("Validation results:")
# print(df)

# # Ask if user wants to save as csv
# #response = input("Do you want to save the results as CSV? (yes/no): ").strip().lower()
# response = "yes"
# if response not in ['yes', 'y']:
#     print("Exiting the program.")
#     exit()
# else:
#     # Save as CSV
#     df.to_csv(os.path.join(save_dir, 'validation_results.csv'), index=False)
#     print(f"Validation results saved as 'validation_results.csv' in {validation_dir}")
