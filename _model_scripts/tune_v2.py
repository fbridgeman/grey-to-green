from ultralytics import YOLO
import matplotlib.pyplot as plt
#import wandb
import json


# Initialize the YOLO model
model1 = YOLO("/gpfs/gibbs/project/miranda/fwb7/yolov8/beta2/v2_data_yolo11x/weights/best.pt")
#data = "/vast/palmer/scratch/miranda/fwb7/yolov8/v4/data.yaml"
data = "/gpfs/gibbs/project/miranda/fwb7/yolov8/v2/data.yaml"
# Tune hyperparameters on COCO8 for 30 epochs
result_grid = model1.tune(data=data, use_ray = True, device = [0,1,2,3])

print(result_grid)

if result_grid.errors:
    print("One or more trials failed!")
else:
    print("No errors!")

print("Best hyperparameters saved in dict.")

# model1.tune() returns a Dict. Save this Dict to a file for later use

with open("/home/fwb7/project/yolov8/tune_results_v2_A.json", "w") as f:
    json.dump(result_grid, f)
