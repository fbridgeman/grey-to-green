
import sys
import os
import torch

print("Python executable:", sys.executable)
print("Python version:", sys.version)


venv_location = os.environ.get("VIRTUAL_ENV")
conda_env = os.environ.get("CONDA_DEFAULT_ENV")

if venv_location:
    print("Venv location:", venv_location)
elif conda_env:
    print("Conda environment:", conda_env)
else:
    print("Not using a virtual environment")


print("Installed packages:")
print(os.popen("pip list").read())
print()
print(torch.cuda.is_available())
print(torch.cuda.device_count())
