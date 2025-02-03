
# This script is used to deploy a model to Roboflow.
from roboflow import Roboflow
import os

cd = os.getcwd()
print(f"Current working directory: {cd}")

# ask if the user wants to deploy the model with yes or y
user_input = input("Do you want to deploy the model with this current working directory? (yes/y): ").strip().lower()
if user_input not in ['yes', 'y']:
    print("Deployment aborted.")
    exit()
else:
    print("Proceeding with deployment...")

user_input2 = input("What version number do you want to deploy?").strip().lower()

rf = Roboflow(api_key='CBfyNcr7kbpR77E7GwFx')
project = rf.workspace('fbridgeman').project('grey-to-green')
#can specify weights_filename, default is "weights/best.pt"
version = project.version(1)
version.deploy("yolo11",  "beta1/yolo11x_test1")
