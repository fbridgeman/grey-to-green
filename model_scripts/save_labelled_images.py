
from ultralytics import YOLO
import ultralytics as ultra
# from IPython.display import display, Image
import os
import yaml
import json
import pandas as pd

wd = os.getcwd
beta = "beta2"
model = "v2_data_yolo11x2"
model_path = os.path.join(wd, beta, model)
weights_path = os.path.join(model_path, "weights/best.pt")
args_path = os.path.join(model_path, "args.yaml"

# Read original params from the args.yaml file
with open(selected_model_args, 'r') as file:
    args = yaml.load(file, Loader=yaml.FullLoader)
    # Original dataset location
    original_data_location = args['data']
    # Original batch size
    og_batch_size = args['batch']
    # Original image size
    og_image_size = args['imgsz']
    # Original epochs
    og_epochs = args['epochs']

# print