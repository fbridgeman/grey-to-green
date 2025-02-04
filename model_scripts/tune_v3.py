from ultralytics import YOLO

# Initialize the YOLO model
model2 = YOLO("/gpfs/gibbs/project/miranda/fwb7/yolov8/beta3/v3_data_yolo11x/weights/best.pt")
data = "/vast/palmer/scratch/miranda/fwb7/yolov8/v3/data.yaml"
#data = "/gpfs/gibbs/project/miranda/fwb7/yolov8/v2/data.yaml"
# Tune hyperparameters on COCO8 for 30 epochs
result_grid = model2.tune(data=data, use_ray = True, device = [0,1,2,3], name = "v3_tune_A")
print(result_grid)