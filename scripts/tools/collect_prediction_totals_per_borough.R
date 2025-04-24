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
#' data frame (`summed_preds_df`). The script handles two configurations (`075` and `085`) 
#' and processes data from two directories: `OTHER BOROUGHS` and `REGRESSION BOROUGHS`.
#' 
#' ## Inputs:
#' - 'borough_polygons': A shapefile containing borough polygons.
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
#' - An updated `summed_preds_df` data frame with aggregated parking counts for each borough 
#'   and configuration (`075` and `085`). Saved as a shapefile.
#'    - Missing data (`NA`) in the final data frame indicates unmatched borough terms 
#'      or missing files in the directories.
#' 
#' ## Step-by-Step Workflow
#' 1. **Initialize Data Frame**:
#'    - Start with a data frame (`summed_preds_df`) containing borough polygons.
#'    - Add a `term` column by converting borough names to lowercase and removing spaces.
#' 
#' 2. **Define Directories**:
#'    - Specify paths for the main results directory, `OTHER BOROUGHS`, and `REGRESSION BOROUGHS`.
#' 
#' 3. **Add Placeholder Columns**:
#'    - Add columns to `summed_preds_df` for storing counts of moving vehicles, stationary vehicles 
#'      (on-street and off-street) for both configurations (`075` and `085`).
#' 
#' 4. **Process Files in `OTHER BOROUGHS` Directory**:
#'    - Loop through all CSV files in the `OTHER BOROUGHS` directory.
#'    - Extract the configuration (`075` or `085`) and borough term from the file name.
#'    - Read the CSV file and filter rows based on vehicle class.
#'    - Populate the corresponding columns in `summed_preds_df` with the counts for the matching borough.
#' 
#' 5. **Process Files in `REGRESSION BOROUGHS` Directory**:
#'    - Repeat the same steps as above for files in the `REGRESSION BOROUGHS` directory.
#' 
#' 6. **Handle Missing Data**:
#'    - Identify rows in `summed_preds_df` where counts are still `NA` (missing) for further investigation.
#' 
#' ## Notes
#' - The script assumes a specific file naming convention for the CSV files.
#' - Missing data (`NA`) in the final data frame may indicate unmatched borough terms 
#'   or missing files in the directories.
#' - Ensure the required libraries (e.g., `dplyr`, `readr`, `stringr`) are loaded before running the script.
#' 

getwd() # should be the project directory

# SET THE DIRECTORIES FOR THE INPUTS AND OUTPUTS
# Originally, some of the files were in the RESULTS DIR, but later, they were split between 2 DIRECTORIES
# hence the need for doing the for loop below in this file over and over
dir <- '/Users/felixbridgeman/My Drive/_STATS THESIS/GIS Match/RESULTS'
other_dir <- '/Users/felixbridgeman/My Drive/_STATS THESIS/GIS Match/RESULTS/OTHER BOROUGHS'
regress_dir <- '/Users/felixbridgeman/My Drive/_STATS THESIS/GIS Match/RESULTS/REGRESSION BOROUGHS'

list.files(dir) # we should see al of the results folders (results per borough)

# Load required libraries
library(dplyr)
library(readr)
library(stringr)

# Load borough polygons
borough_polygons <- st_read(dsn = "./data/raw/borough_polygons", layer = "london_borough_onstreet")

# Read the parking counts for each borough
# summed_preds_df is the new dataframe that we will be saving the total predicted parking counts per borough into
summed_preds_df <- borough_polygons

# Should print confirmation message
getOption("repos")

summed_preds_df$term <- tolower(borough_polygons$NAME)

# remove spaces
summed_preds_df$term <- gsub(" ", "", summed_preds_df$term)

#075 # we create columns for the 0.75 confidence level counts of each class
summed_preds_df$moving_vehicle_075 <- NA
summed_preds_df$stationary_vehicle_onstreet_075 <- NA
summed_preds_df$stationary_vehicle_offstreet_075 <- NA

# 085 # and we also create columns for the 0.85 confidence level counts of each class
summed_preds_df$moving_vehicle_085 <- NA
summed_preds_df$stationary_vehicle_onstreet_085 <- NA
summed_preds_df$stationary_vehicle_offstreet_085 <- NA

# Now we will read each file that contains all of the parking counts for each borough
# Read the parking counts for each borough
for (file in list.files(other_dir)) {
  file_path <- paste(other_dir, file, sep = "/")
  message(file_path)
  # we use a strsplit to identify the confidence level of the detections that the file contains
  file_conf <- strsplit(file, "_")[[1]][5] %>%
    # remove .csv
    str_remove(".csv")
  
  # everything before first _
  file_term <- tolower(strsplit(file, "_")[[1]][1])
  message(file_term)
  # read file
  df <- read_csv(file_path)
  message("file read")
  
  # If we are dealing with a file that contains the 0.75 confidence level detections:
  if(file_conf == "075") {
    # we create a temp variable for each class of vehicle
    moving <- df %>%
      filter(class == "moving-vehicle") %>% select(count)
    stationary_onstreet <- df %>%
      filter(class == "stationary-vehicle-onstreet") %>% select(count)
    stationary_offstreet <- df %>%
      filter(class == "stationary-vehicle-offstreet") %>% select(count)
    
    # we then assign the temp variables to the correct column in the summed_preds_df dataframe
    summed_preds_df[summed_preds_df$term == file_term, "moving_vehicle_075"] <- moving
    summed_preds_df[summed_preds_df$term == file_term, "stationary_vehicle_onstreet_075"] <- stationary_onstreet
    summed_preds_df[summed_preds_df$term == file_term, "stationary_vehicle_offstreet_075"] <- stationary_offstreet

  # If we are dealing with a file that contains the 0.85 confidence level detections:
  } else if(file_conf == "085") {
    moving <- df %>%
      filter(class == "moving-vehicle") %>% select(count)
    stationary_onstreet <- df %>%
      filter(class == "stationary-vehicle-onstreet") %>% select(count)
    stationary_offstreet <- df %>%
      filter(class == "stationary-vehicle-offstreet") %>% select(count)
    
    summed_preds_df[summed_preds_df$term == file_term, "moving_vehicle_085"] <- moving
    summed_preds_df[summed_preds_df$term == file_term, "stationary_vehicle_onstreet_085"] <- stationary_onstreet
    summed_preds_df[summed_preds_df$term == file_term, "stationary_vehicle_offstreet_085"] <- stationary_offstreet
    
  } else {} # if neither of the above, do nothing.
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
    
    summed_preds_df[summed_preds_df$term == file_term, "moving_vehicle_075"] <- moving
    summed_preds_df[summed_preds_df$term == file_term, "stationary_vehicle_onstreet_075"] <- stationary_onstreet
    summed_preds_df[summed_preds_df$term == file_term, "stationary_vehicle_offstreet_075"] <- stationary_offstreet
    
  } else if(file_conf == "085") {
    moving <- df %>%
      filter(class == "moving-vehicle") %>% select(count)
    stationary_onstreet <- df %>%
      filter(class == "stationary-vehicle-onstreet") %>% select(count)
    stationary_offstreet <- df %>%
      filter(class == "stationary-vehicle-offstreet") %>% select(count)
    
    summed_preds_df[summed_preds_df$term == file_term, "moving_vehicle_085"] <- moving
    summed_preds_df[summed_preds_df$term == file_term, "stationary_vehicle_onstreet_085"] <- stationary_onstreet
    summed_preds_df[summed_preds_df$term == file_term, "stationary_vehicle_offstreet_085"] <- stationary_offstreet
    
  } else {}
}

# show NA lines
summed_preds_df %>% filter(is.na(moving_vehicle_075))

# save the summed_preds_df dataframe to a .shp file
# we save this in './data/results/by_borough/parking_predictions_per_borough.shp'
st_write(summed_preds_df, "./data/results/by_borough/parking_predictions_per_borough.shp")


