# 🚀 Grey to Green
## About
**Grey to Green** is an ongoing machine learning project to develop a modle that can estimate urban parking stock to identify opportunities for repurposing underutilized parking spaces in London (and hopefully other cities).

This repo contains the necessary raw data, scripts, and results from my research for reproduction purposes.

---

## Repository Structure !! This is a work in progress !!
*Parentheses () indicate the subdirectory is included in .gitignore and not synced with repo.*

```
grey-to-green/
│── configs/              # Config files for training/evaluation
│   ├── yolov8_config.yaml
│   ├── hyperparameters.json
│   ├── model_params.yaml
│   ├── .env.example      # Template for env variables (not tracked)
│
│── data/                 # Raw and processed data (still to be organised)
│   ├── raw/
│   │   ├── london_parking/     # Contains mainly .shp files collected from each London borough (where available), providing ground truth parking data.
│   │   ├── (london_SVIs/)      # Contains all raw SVIs organised into each borough. Due to the large size of this dataset, this data is not uploaded to GitHub.
│   │
│   ├── processed/
│   │   ├── (sampled_panoID_locations/)   # Contains CSV files enumerating the original file storage locations of SVIs to be included in various sampling sets,
│   │   ├── (all_panoID_location/)        # Contains CSV files detailing the original locations of all SVIs for each london borough.
│   │   ├── labelled_SVI_datasets/      # Contains sample datasets comprised of labelled SVIs in COCO format for model training, validation, and testing purposes.
│   │ 
│   ├── outputs/
│
│── pretrained_models/               # Saved pre-trained models downloaded w/ Ultralytics API
│
│── model_builds/       # Weights of CNN models that recognise moving and stationary vehicles
│   ├── beta1               # 1st model trained on small dataset and large number of classes
│   ├── beta2               # 2nd model trained on enlarged dataset maintaining large number of classes
│   ├── beta3               # 3rd model trained on enlarged dataset with reduced number of classes
│   ├── beta4               # 4th model trained on enlarged dataset with minimal number of classes. Includes further experiments with hyperparameter optimisation.
│
│── model_results/      # Contains CSVs describing key performance metrics for various validation runs of each model at different confidence and IOU thresholds
│   ├── class_metrics/
│   ├── confusion_matrices/
│   ├── TPs_and_FPs/
│
│── (model_runs/)       # Model runs, primarily validation runs, results detailed in model_results/
│
│── model_scripts/      # Python scripts for settung up model
│
│── notebooks/          # Jupyter Notebooks used to prepare, explore, and evaluate models.
│
│── R_scripts/          # R scripts used for raw data preparation
│
│── slurm/              # Slurm job scripts & logs
│   ├── jobs/               # Slurm job submission scripts
│   ├── (logs/)             # Output logs from Slurm jobs
│   ├── (failed/)           # Failed job outputs
│
│── _model_results/              # Training results, logs, and metrics
│   ├── class_metrics/                # Collection of CSVs containing class-specific performance metrics including mAP50 from various validation runs.
│   ├── confusion_matrices/           # Collection of CSVs containing confusion matrices from various validation runs.
│   ├── TPs_and_FPs/                  # Collection of CSVs containing the true positives and false positives from various validation runs.
│
│── report/              # Submitted reports including submitted thesis PDF
|
│── environments/        # Environment setup
│   ├── requirements.txt
│   ├── environment.yml
│   ├── r_requirements.txt
│
│── .gitignore           # Ignore large/temp files
│── .gitattributes       # Rules detemining which file types to use Git LFS for
│── README.md            # Documentation
```