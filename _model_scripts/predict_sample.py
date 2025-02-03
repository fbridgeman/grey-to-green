

import os
import pandas as pd
import numpy as np
import torch
from ultralytics import YOLO
import matplotlib.pyplot as plt
import cv2

confidence_threshold = 0.75
confidence_threshold2 = 0.85
iou_nms_threshold = 0.7
sample_dir = "/vast/palmer/scratch/miranda/fwb7/images/sample"
dataset = sample_dir

output_path = "/vast/palmer/scratch/miranda/fwb7/prediction"
name = "sample_preds_v4_conf75"
name2 = "sample_preds_v4_conf85"
weights = "/home/fwb7/project/yolov8/beta4/v4_yolo11x/weights/best.pt"

model = YOLO(weights)
batch_size = 128
device = [0, 1]

# make dir
if not os.path.exists(output_path):
    os.makedirs(output_path)

csv_path = f"{output_path}/class_counts.csv"

predictions = model.predict(
    source=dataset,
    project=output_path,
    name=name,
    imgsz=400,
    save=True,
    save_txt=False,
    show=False,
    show_labels=True,
    conf=confidence_threshold,
    iou=iou_nms_threshold,
    device='cuda:0',  # Specify device
    batch=32,  # Explicitly set batch size
)

# predictions2 = model.predict(
#     source=dataset,
#     project=output_path,
#     name=name2,
#     imgsz=400,
#     save=True,
#     save_txt=False,
#     show=False,
#     show_labels=False,
#     conf=confidence_threshold2,
#     iou=iou_nms_threshold,
#     device='cuda:0',  # Specify device
#     batch=32,  # Explicitly set batch size
# )

# # Initialize a dictionary to store the counts for each class
# class_counts = {}

# # Iterate through the predictions
# for prediction in predictions:
#     for det in prediction.summary():
#         class_id = det['class']
#         class_name = det['name']
#         if class_name not in class_counts:
#             class_counts[class_name]=0
#         class_counts[class_name] += 1

# # Convert the counts dictionary to a DataFrame
# class_counts_df = pd.DataFrame(list(class_counts.items()), columns=['class', 'count'])

# # Save the DataFrame to a CSV file
# csv_path = f"{output_path}/__sample_class_counts_conf75.csv"
# class_counts_df.to_csv(csv_path, index=False)

# print(f"Class counts saved to {csv_path}")
# print(class_counts_df)

# # Initialize a dictionary to store the counts for each class
# class_counts2 = {}

# # Iterate through the predictions2
# for prediction in predictions2:
#     for det in prediction.summary():
#         class_id = det['class']
#         class_name = det['name']
#         if class_name not in class_counts2:
#             class_counts2[class_name]=0
#         class_counts2[class_name] += 1

# # Convert the counts dictionary to a DataFrame
# class_counts2_df = pd.DataFrame(list(class_counts2.items()), columns=['class', 'count'])

# # Save the DataFrame to a CSV file
# csv_path2 = f"{output_path}/__sample_class_counts_conf85.csv"
# class_counts2_df.to_csv(csv_path2, index=False)

# print(f"Class counts saved to {csv_path2}")
# print(class_counts2_df)

# ###

# # Initialize a list to store the data for each image
# image_data = []


# # Iterate through the predictions
# for prediction in predictions:
#     image_name = prediction.path.split('/')[-1]  # Extract image name from the path
#     class_counts = {class_name: 0 for class_name in prediction.names.values()}  # Initialize class counts to 0
#     for det in prediction.summary():
#         class_name = det['name']
#         class_counts[class_name] += 1
#     class_counts['image_name'] = image_name  # Add image name to the dictionary
    
#     image_data.append(class_counts)

# # Convert the list of dictionaries to a DataFrame
# image_df = pd.DataFrame(image_data)
# # rearrange so image name is first column

# # Save the DataFrame to a CSV file
# image_csv_path = f"{output_path}/__image_sample_class_counts_conf75.csv"
# image_df.to_csv(image_csv_path, index=False)

# print(f"Image class counts saved to {image_csv_path}")
# print(image_df)

# ###

# # Initialize a list to store the data for each image
# image_data2 = []


# # Iterate through the predictions2
# for prediction in predictions2:
#     image_name = prediction.path.split('/')[-1]  # Extract image name from the path
#     class_counts = {class_name: 0 for class_name in prediction.names.values()}  # Initialize class counts to 0
#     for det in prediction.summary():
#         class_name = det['name']
#         class_counts[class_name] += 1
#     class_counts['image_name'] = image_name  # Add image name to the dictionary
    
#     image_data2.append(class_counts)

# # Convert the list of dictionaries to a DataFrame
# image2_df = pd.DataFrame(image_data2)
# # rearrange so image name is first column

# # Save the DataFrame to a CSV file
# image_csv_path2 = f"{output_path}/__image_sample_class_counts_conf85.csv"
# image2_df.to_csv(image_csv_path2, index=False)

# print(f"Image class counts saved to {image_csv_path2}")
# print(image2_df)
