from ultralytics import YOLO
import matplotlib.pyplot as plt
#import wandb
import json
import os

# Initialize the YOLO model
model3 = YOLO("/gpfs/gibbs/project/miranda/fwb7/yolov8/beta4/v4_yolo11x/weights/best.pt")
data = "/vast/palmer/scratch/miranda/fwb7/yolov8/v4/data.yaml"
#data = "/gpfs/gibbs/project/miranda/fwb7/yolov8/v2/data.yaml"
# Tune hyperparameters on COCO8 for 30 epochs
result_grid = model3.tune(data=data, use_ray = True, device = [0,1,2,3], name = "v4_tune_A")

print(result_grid)

if result_grid.errors:
    print("One or more trials failed!")
else:
    print("No errors!")

print("Best hyperparameters saved in dict.")


savedir = "/gpfs/gibbs/project/miranda/fwb7/project/yolov8/tune_results_v4_A"
# make sure this dir exists
if not os.path.exists(savedir):
    os.makedirs(savedir)

# model1.tune() returns a Dict. Save this Dict to a file for later use
with open(savedir + "tune_results_v4_A.json", "w") as f:
    json.dump(result_grid, f)

for i, result in enumerate(result_grid):
    plt.plot(
        result.metrics_dataframe["training_iteration"],
        result.metrics_dataframe["mean_accuracy"],
        label=f"Trial {i}",
    )

plt.xlabel("Training Iterations")
plt.ylabel("Mean Accuracy")
plt.legend()
# save plot as png
plt.savefig(savedir + "/tune_results_v4_A.png")

for i, result in enumerate(result_grid):
    print(f"Trial #{i}: Configuration: {result.config}, Last Reported Metrics: {result.metrics}")