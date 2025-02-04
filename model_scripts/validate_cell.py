# Setup Scripts
from ultralytics import YOLO
from roboflow import Roboflow
from IPython.display import display
import matplotlib.pyplot as plt
import scipy
import numpy as np
import pandas as pd
import os
import supervision as sv
import papermill
import json

## MODEL 2
data_b2_dir = "/gpfs/gibbs/project/miranda/fwb7/yolov8/v2/data.yaml"
model_b2_dir = "/gpfs/gibbs/project/miranda/fwb7/yolov8/beta2/v2_data_yolo11x/weights/best.pt"
model_b2 = YOLO(model_b2_dir)

for conf in np.arange(0.3, 1.0, 0.05):
    results_b2 = model_b2.val(data=data_b2_dir,
                              name=f"val_b2_c{int(conf*100)}",
                              project="/gpfs/gibbs/project/miranda/fwb7/yolov8/beta2",
                              device=[0, 1, 2, 3],
                              batch=16,
                              verbose=True,
                              plots=True,
                              save_json=True,
                              conf=conf)

print("Results object saved as 'val_results/results_b2.json'")

## MODEL 3
data_b3_dir = "/vast/palmer/scratch/miranda/fwb7/yolov8/v3/data.yaml"
model_b3_dir = "/gpfs/gibbs/project/miranda/fwb7/yolov8/beta3/v3_data_yolo11x/weights/best.pt"
model_b3 = YOLO(model_b3_dir)

for conf in np.arange(0.3, 1.0, 0.05):
    results_b3 = model_b3.val(data=data_b3_dir,
                              name=f"val_b3_c{int(conf*100)}",
                              project="/gpfs/gibbs/project/miranda/fwb7/yolov8/beta3",
                              device=[0, 1, 2, 3],
                              batch=16,
                              verbose=True,
                              plots=True,
                              save_json=True,
                              conf=conf)

print("Results object saved as 'val_results/results_b3.json'")

## MODEL 4
data_b4_dir = "/vast/palmer/scratch/miranda/fwb7/yolov8/v4/data.yaml"
model_b4_dir = "/gpfs/gibbs/project/miranda/fwb7/yolov8/beta4/v4_yolo11x/weights/best.pt"
model_b4 = YOLO(model_b4_dir)

for conf in np.arange(0.3, 1.0, 0.05):
    results_b4 = model_b4.val(data=data_b4_dir,
                              name=f"val_b4_c{int(conf*100)}",
                              project="/gpfs/gibbs/project/miranda/fwb7/yolov8/beta4",
                              device=[0, 1, 2, 3],
                              batch=16,
                              verbose=True,
                              plots=True,
                              save_json=True,
                              conf=conf)

print("Results object saved as 'val_results/results_b4.json'")
