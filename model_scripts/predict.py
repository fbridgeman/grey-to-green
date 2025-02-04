

import os
import pandas as pd
import numpy as np
import torch
from ultralytics import YOLO
import matplotlib.pyplot as plt
import cv2

vast_images = "/vast/palmer/scratch/miranda/fwb7/images"
london_boroughs = ["BarkingandDagenham", "Barnet", "Bexley", "Brent", "Bromley", "camden", "Croydon", "Ealing", "Enfield", "Greenwich", "hackney", "HammersmithandFulham", "haringey", "harrow", "Havering", "Hillingdon", "hounslow", "islington", "KensingtonandChelsea", "KingstonuponThames", "Lambeth", "Lewisham", "Merton", "Newham", "redbridge", "RichmonduponThames", "Southwark", "Sutton", "towerhamlets", "WalthamForest", "wandsworth", "westminster"]
chosen_boroughs = ["camden", "hackney", "islington", "KensingtonandChelsea", "westminster"]
london_borough_dirs = {}
for borough in london_boroughs:
    london_borough_dirs[borough] = os.path.join(vast_images, borough)
chosen_borough_dirs = {}
for borough in chosen_boroughs:
    chosen_borough_dirs[borough] = os.path.join(vast_images, borough)

print(london_borough_dirs)

weights = "/home/fwb7/project/yolov8/beta4/v4_yolo11x/weights/best.pt"

print(chosen_borough_dirs)

sample_dir = "/vast/palmer/scratch/miranda/fwb7/images/sample"
print(sample_dir)

all_dir = "/vast/palmer/scratch/miranda/fwb7/images/all"
print(all_dir)

model = YOLO(weights)
batch_size = 16
device = torch.device("cuda:0")

confidence_threshold = 0.85
iou_nms_threshold = 0.7
sample_dir = "/vast/palmer/scratch/miranda/fwb7/images/sample"
dataset = sample_dir

output_path = "/vast/palmer/scratch/miranda/fwb7/prediction/"

weights = "/home/fwb7/project/yolov8/beta4/v4_yolo11x/weights/best.pt"

for borough in chosen_boroughs:

    dataset = chosen_borough_dirs[borough]

    output_path = f"/vast/palmer/scratch/miranda/fwb7/prediction/{borough}_conf_0.85"

    name = "{borough}_preds_v4_conf_0.85"

    # make dir
    if not os.path.exists(output_path):
        os.makedirs(output_path)

    predictions = model.predict(
        source=dataset,
        project=output_path,
        name=name,
        imgsz=400,
        save=False,
        save_txt=True,
        show=False,
        show_labels=False,
        conf=confidence_threshold,
        iou=iou_nms_threshold,
        device=device,  # Specify device
        batch=64,  # Explicitly set batch size
        )

    csv_path = f"/vast/palmer/scratch/miranda/fwb7/prediction/{borough}_class_counts_conf_0.85.csv"

    # Initialize a dictionary to store the counts for each class
    class_counts = {}

    # Iterate through the predictions
    for prediction in predictions:
        for det in prediction.summary():
            class_id = det['class']
            class_name = det['name']
            if class_name not in class_counts:
                class_counts[class_name]=0
            class_counts[class_name] += 1

    class_counts

    # Convert the counts dictionary to a DataFrame
    class_counts_df = pd.DataFrame(list(class_counts.items()), columns=['class', 'count'])

    # Save the DataFrame to a CSV file
    # csv_path = f"{output_path}__class_counts.csv"
    class_counts_df.to_csv(csv_path, index=False)

    print(f"Class counts saved to {csv_path}")
    print(class_counts_df)

    # delete predictions object to free up memory
    del predictions















