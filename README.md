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
│
│── _pretrained_models/               # Saved pre-trained models downloaded w/ Ultralytics API
│
│── _notebooks/            # Jupyter Notebooks
│
│── _model_scripts/              # Python scripts for settung up model
│   ├── python/           # Python scripts for training, validation, 
|
│── _R_scripts/              # R scripts used for raw data preparation
│
│── slurm/                # Slurm job scripts & logs
│   ├── jobs/             # Slurm job submission scripts
│   │
│   ├── (logs/)             # Output logs from Slurm jobs
│   │
│   ├── (failed/)           # Failed job outputs
│
│── _model_results/              # Training results, logs, and metrics
│   ├── class_metrics/             # Collection of CSVs containing class-specific performance metrics including mAP50 from various validation runs.
│   ├── confusion_matrices/          # Collection of CSVs containing confusion matrices from various validation runs.
│   ├── TPs_and_FPs/      # Collection of CSVs containing the true positives and false positives from various validation runs.
│
│── report/         # Submitted reports including submitted thesis PDF
|
│── environments/         # Environment setup
│   ├── requirements.txt
│   ├── environment.yml
│   ├── r_requirements.txt
│
│── .gitignore            # Ignore large/temp files
│── README.md             # Documentation
```