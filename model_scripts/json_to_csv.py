
from ultralytics import YOLO
import ultralytics as ultra
# from IPython.display import display, Image
import os
import yaml
import json
import pandas as pd

# convert saved results from JSON file to CSV
# Assuming your JSON results are saved as 'results.json'

results_json = f"{project_dir}/results/{validation_name}/results.json"

# read the JSON file
with open(results_json, 'r') as file:
    data = json.load(file)

# Convert JSON to DataFrame then save as CSV
df = pd.DataFrame(data)

# Print df
print("Validation results:")
print(df)

# Ask if user wants to save as csv
#response = input("Do you want to save the results as CSV? (yes/no): ").strip().lower()
response = "yes"
if response not in ['yes', 'y']:
    print("Exiting the program.")
    exit()
else:
    # Save as CSV
    df.to_csv(os.path.join(save_dir, 'validation_results.csv'), index=False)
    print(f"Validation results saved as 'validation_results.csv' in {validation_dir}")
