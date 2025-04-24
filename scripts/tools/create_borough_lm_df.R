#' ---
#' create_borough_lm_df.R
#' Title: Create Borough Linear Model Dataframe
#' Author: Felix Bridgeman
#' Date: 2024-04-17
#' LAST EDITED: 2025-04-20
#' ---
#'
#' Inputs:
#' - summed_preds_df: Dataframe containing predicted parking counts per borough.
#' - summed_truth_df: Dataframe containing ground truth parking counts per borough.
#' - density: Dataframe containing population density data for London boroughs.
#'
#' Outputs:
#' - borough_data: Dataframe prepared for linear regression analysis,
#' combining predictions, ground truth, and population density data.
#'
#' Description:
#' This script processes parking prediction and ground truth data,
#' combines it with population density data, and creates additional variables for analysis. 
#' The resulting dataframe is saved for use in further analysis and visualization.
#' - summed_preds_df: dataframe with counts data created by `collate_prediction_totals_per_borough.R`
#' - summed_truth_df: dataframe with evaluation data created by `collate_evaluation_totals_per_borough.R`
#' 

library(tidyverse)
library(dplyr)

# import the summed_preds_df
summed_preds_df <- st_read("./data/results/by_borough/parking_predictions_per_borough.csv")

# import the summed_truth_df
summed_truth_df <- st_read("./data/results/by_borough/parking_ground_truth_per_borough.csv")

# import the population density data
# get population density data
density <- read_csv("https://data.london.gov.uk/download/land-area-and-population-density-ward-and-borough/77e9257d-ad9d-47aa-aeed-59a00741f301/housing-density-borough.csv")
density <- density %>%
  dplyr::filter(Year == 2023)

density_selection <- density %>%
  dplyr::select(Name, Population, Population_per_hectare)

# combine summed_preds_df with summed_truth_df
# get names for each to check
names(summed_preds_df)
names(summed_truth_df)
names(density)

head(summed_preds_df)
head(summed_truth_df)
names(density)

# here, we prepare the data for analysis
preds_to_join <- summed_preds_df %>% dplyr::select(NAME,
                          moving_vehicle_075:stationary_vehicle_offstreet_085) # %>%
  # # remove geometry
  # st_drop_geometry()

# We create the `data` df which will be the basis for our linear regression analysis
borough_data <- summed_truth_df %>%
  # remove geometry
  st_drop_geometry()
borough_data <- borough_data %>% left_join(preds_to_join, by = c("NAME" = "NAME"))

# in order to also add additional predictors based off of density, we join the density data
borough_data <- borough_data %>%
  left_join(density_selection, by = c("NAME" = "Name"))

  ### CREATING VARIABLES FOR ADDITIONAL ANALYSIS
# create a new variable spaces_per_hectare, as well as predictions per hectare (FOR EACH CONF LEVEL)
borough_data$spaces_per_hectare <- borough_data$total_spaces / borough_data$HECTARES
borough_data$predictions_per_hectare_075 <- borough_data$stationary_vehicle_onstreet_075 / borough_data$HECTARES
borough_data$predictions_per_hectare_085 <- borough_data$stationary_vehicle_onstreet_085 / borough_data$HECTARES

# create new variables spaces and predictions over density
borough_data$spaces_over_density <- borough_data$total_spaces / borough_data$Population / borough_data$HECTARES
borough_data$predictions_over_density_075 <- borough_data$stationary_vehicle_onstreet_075 / borough_data$Population / borough_data$HECTARES
borough_data$predictions_over_density_085 <- borough_data$stationary_vehicle_onstreet_085 / borough_data$Population / borough_data$HECTARES

# make spaces / Population and predictions / Population  
borough_data$spaces_per_population <- borough_data$total_spaces / borough_data$Population
borough_data$predictions_per_population_075 <- borough_data$stationary_vehicle_onstreet_075 / borough_data$Population
borough_data$predictions_per_population_085 <- borough_data$stationary_vehicle_onstreet_085 / borough_data$Population

### SAVE THE DATAFRAME FOR LM ANALYSIS IN BOROUGHWIDE_LINEAR_ANALYSIS.R
### AND FOR VISUALISATION IN BOROUGHWIDE_LA_VISUALISATION.R
  # save the `borough_data` df for analysis in data/results/by_borough as "borough_lm_df.shp"
st_write(borough_data, "./data/results/by_borough/borough_lm_df.shp", row.names = FALSE)