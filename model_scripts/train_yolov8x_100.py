# Yale HPC
# Trial 1

from ultralytics import YOLO

# Update ultralytics settins
data_name = "/gpfs/gibbs/project/miranda/fwb7/yolov8/data/data.yaml"
project_name = "/gpfs/gibbs/project/miranda/fwb7/yolov8/beta1"

print(data_name)
print(project_name)

# Ask user if they want to continue:
# response = input("Do you want to continue? (yes/no): ").strip().lower()
# if response not in ['yes', 'y']:
#     print("Exiting the program.")
#     exit()
# else:
#     print("Continuing...")

# Load a model
## yolov8
yolov8n = YOLO("yolov8n.pt")  # load a pretrained model (recommended for training)
yolov8m = YOLO("yolov8m.pt")  # load a pretrained model (recommended for training)
yolov8x = YOLO("yolov8l.pt")  # load a pretrained model (recommended for training)

## yolo 11
yolo11n = YOLO("yolo11n.pt")  # load a pretrained model (recommended for training)
yolo11m = YOLO("yolo11m.pt")  # load a pretrained model (recommended for training)
yolo11x = YOLO("yolo11l.pt")  # load a pretrained model (recommended for training)

# project.version(DATASET_VERSION).deploy(model_type=”yolov8”, model_path=f”{HOME}/runs/detect/train/”)
# Train the model with MPS
yolov8x.train(name = "yolov8x_test1",
              data = data_name,
              project = project_name,
              epochs = 100,
              batch = 32,
              imgsz = 416,
              device=[0,1,2],
              verbose = True,
              time = 2,
              plots = True)





