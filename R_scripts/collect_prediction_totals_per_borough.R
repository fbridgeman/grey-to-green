#' ---
#' collect_prediction_totals_per_borough.R
#' Title: Collect Prediction Totals Per Borough
#' Author: Felix Bridgeman
#' Date: 2024-12-12
#' LAST EDITED: 2025-04-17
#' ---
#' 
#' ## Description
#' This script processes parking count data for different boroughs by reading 
#' prediction results from CSV files and aggregating the counts into a single 
#' data frame (`counts_df`). The script handles two configurations (`075` and `085`) 
#' and processes data from two directories: `OTHER BOROUGHS` and `REGRESSION BOROUGHS`.
#' 
#' ## Inputs:
#' - CSV files containing parking count predictions for different boroughs.
#'   - File naming convention includes borough name and confidence configuration (`075` or `085`).
#'   - These files were created in the DEPLOY.ipynb notebook.
#'   - The script assumes that the CSV files are located in:
#'     - `/Users/felixbridgeman/My Drive/_STATS THESIS/GIS Match/RESULTS/OTHER BOROUGHS`
#'     - `/Users/felixbridgeman/My Drive/_STATS THESIS/GIS Match/RESULTS/REGRESSION BOROUGHS`
#'   - The CSV files contain columns for vehicle class and count.
#'   - The script processes the following vehicle classes:
#'     - `moving-vehicle`
#'     - `stationary-vehicle-onstreet`
#'     - `stationary-vehicle-offstreet`
#' 
#' - Directories:
#'   - `OTHER BOROUGHS`: Contains prediction results for other boroughs.
#'   - `REGRESSION BOROUGHS`: Contains prediction results for regression boroughs.
#' 
#' ## Outputs:
#' - An updated `counts_df` data frame with aggregated parking counts for each borough 
#'   and configuration (`075` and `085`).
#' - Missing data (`NA`) in the final data frame indicates unmatched borough terms 
#'   or missing files in the directories.
#' 
#' ## Step-by-Step Workflow
#' 1. **Initialize Data Frame**:
#'    - Start with a data frame (`counts_df`) containing borough polygons.
#'    - Add a `term` column by converting borough names to lowercase and removing spaces.
#' 
#' 2. **Define Directories**:
#'    - Specify paths for the main results directory, `OTHER BOROUGHS`, and `REGRESSION BOROUGHS`.
#' 
#' 3. **Add Placeholder Columns**:
#'    - Add columns to `counts_df` for storing counts of moving vehicles, stationary vehicles 
#'      (on-street and off-street) for both configurations (`075` and `085`).
#' 
#' 4. **Process Files in `OTHER BOROUGHS` Directory**:
#'    - Loop through all CSV files in the `OTHER BOROUGHS` directory.
#'    - Extract the configuration (`075` or `085`) and borough term from the file name.
#'    - Read the CSV file and filter rows based on vehicle class.
#'    - Populate the corresponding columns in `counts_df` with the counts for the matching borough.
#' 
#' 5. **Process Files in `REGRESSION BOROUGHS` Directory**:
#'    - Repeat the same steps as above for files in the `REGRESSION BOROUGHS` directory.
#' 
#' 6. **Handle Missing Data**:
#'    - Identify rows in `counts_df` where counts are still `NA` (missing) for further investigation.
#' 
#' ## Notes
#' - The script assumes a specific file naming convention for the CSV files.
#' - Missing data (`NA`) in the final data frame may indicate unmatched borough terms 
#'   or missing files in the directories.
#' - Ensure the required libraries (e.g., `dplyr`, `readr`, `stringr`) are loaded before running the script.
#' 

# Read the parking counts for each borough

counts_df <- borough_polygons

counts_df$term <- tolower(borough_polygons$NAME)
# remove spaces
counts_df$term <- gsub(" ", "", counts_df$term)

dir <- '/Users/felixbridgeman/My Drive/_STATS THESIS/GIS Match/RESULTS'
other_dir <- '/Users/felixbridgeman/My Drive/_STATS THESIS/GIS Match/RESULTS/OTHER BOROUGHS'
regress_dir <- '/Users/felixbridgeman/My Drive/_STATS THESIS/GIS Match/RESULTS/REGRESSION BOROUGHS'

list.files(dir)

#075
counts_df$moving_vehicle_075 <- NA
counts_df$stationary_vehicle_onstreet_075 <- NA
counts_df$stationary_vehicle_offstreet_075 <- NA
# 085
counts_df$moving_vehicle_085 <- NA
counts_df$stationary_vehicle_onstreet_085 <- NA
counts_df$stationary_vehicle_offstreet_085 <- NA

# Read the parking counts for each borough
for (file in list.files(other_dir)) {
  file_path <- paste(other_dir, file, sep = "/")
  message(file_path)
  file_conf <- strsplit(file, "_")[[1]][5] %>%
    # remove .csv
    str_remove(".csv")
  
  
  # everything before first _
  file_term <- tolower(strsplit(file, "_")[[1]][1])
  message(file_term)
  # read file
  df <- read_csv(file_path)
  message("file read")
  
  
  if(file_conf == "075") {
    moving <- df %>%
      filter(class == "moving-vehicle") %>% select(count)
    stationary_onstreet <- df %>%
      filter(class == "stationary-vehicle-onstreet") %>% select(count)
    stationary_offstreet <- df %>%
      filter(class == "stationary-vehicle-offstreet") %>% select(count)
    
    counts_df[counts_df$term == file_term, "moving_vehicle_075"] <- moving
    counts_df[counts_df$term == file_term, "stationary_vehicle_onstreet_075"] <- stationary_onstreet
    counts_df[counts_df$term == file_term, "stationary_vehicle_offstreet_075"] <- stationary_offstreet
    
  } else if(file_conf == "085") {
    moving <- df %>%
      filter(class == "moving-vehicle") %>% select(count)
    stationary_onstreet <- df %>%
      filter(class == "stationary-vehicle-onstreet") %>% select(count)
    stationary_offstreet <- df %>%
      filter(class == "stationary-vehicle-offstreet") %>% select(count)
    
    counts_df[counts_df$term == file_term, "moving_vehicle_085"] <- moving
    counts_df[counts_df$term == file_term, "stationary_vehicle_onstreet_085"] <- stationary_onstreet
    counts_df[counts_df$term == file_term, "stationary_vehicle_offstreet_085"] <- stationary_offstreet
    
  } else {}
}

# Read the parking counts for each borough
for (file in list.files(regress_dir)) {
  file_path <- paste(regress_dir, file, sep = "/")
  message(file_path)
  file_conf <- strsplit(file, "_")[[1]][5] %>%
    # remove .csv
    str_remove(".csv")
  
  
  # everything before first _
  file_term <- tolower(strsplit(file, "_")[[1]][1])
  message(file_term)
  # read file
  df <- read_csv(file_path)
  message("file read")
  
  
  if(file_conf == "075") {
    moving <- df %>%
      filter(class == "moving-vehicle") %>% select(count)
    stationary_onstreet <- df %>%
      filter(class == "stationary-vehicle-onstreet") %>% select(count)
    stationary_offstreet <- df %>%
      filter(class == "stationary-vehicle-offstreet") %>% select(count)
    
    counts_df[counts_df$term == file_term, "moving_vehicle_075"] <- moving
    counts_df[counts_df$term == file_term, "stationary_vehicle_onstreet_075"] <- stationary_onstreet
    counts_df[counts_df$term == file_term, "stationary_vehicle_offstreet_075"] <- stationary_offstreet
    
  } else if(file_conf == "085") {
    moving <- df %>%
      filter(class == "moving-vehicle") %>% select(count)
    stationary_onstreet <- df %>%
      filter(class == "stationary-vehicle-onstreet") %>% select(count)
    stationary_offstreet <- df %>%
      filter(class == "stationary-vehicle-offstreet") %>% select(count)
    
    counts_df[counts_df$term == file_term, "moving_vehicle_085"] <- moving
    counts_df[counts_df$term == file_term, "stationary_vehicle_onstreet_085"] <- stationary_onstreet
    counts_df[counts_df$term == file_term, "stationary_vehicle_offstreet_085"] <- stationary_offstreet
    
  } else {}
}

# show NA lines
counts_df %>% filter(is.na(moving_vehicle_075))


