#' ---
#' collate_ground_truth_totals_per_borough.R
#' Title: Collect Ground Truth Parking Totals Per Borough
#' Author: Felix Bridgeman
#' Date: 2024-12-12
#' LAST EDITED: 2025-04-17
#' ---
#'
#' ## Overview
#' This script processes geographical and parking data for London boroughs, 
#' collating totals and preparing the data for further analysis. It integrates 
#' spatial data with parking information and calculates total parking spaces 
#' for each borough based on their respective geometries (point, polygon, or polyline).
#'
#' ## Inputs:
#' - `borough_polygons`: Spatial data for London boroughs.
#' - `joint_points`, `joint_polygons`, `joint_polylines`:
#'   - Shapefiles containing parking space information for points, polygons, and polylines.
#' - !!! CPZ_coverage.csv
#'  - !!!  A CSV file containing controlled parking zone (CPZ) coverage data for each borough.
#'  - !!! (Not yet created, currently hardcoded in the script)
#' 
#' 
#' ## Outputs:
#' - `summed_truth_df`:
#'   - A data frame containing borough-level data with total parking spaces and CPZ coverage, ready for further analysis.
#'   - saved as a shapefile in the `./data/results/by_borough/` directory.
#' 
#' ## Step-by-Step Description
#'
#' 1. **Load Required Libraries**:
#'    - The script loads necessary libraries such as `tidyverse`, `lwgeom`, `sp`, `sf`, and `ggplot2`.
#'
#' 2. **Read Borough Polygons**:
#'    - Reads spatial data for London boroughs from a specified file path.
#'
#' 3. **Define Borough Categories**:
#'    - Defines various borough groupings such as `original_boroughs`, `sampling_boroughs`, 
#'      `regression_boroughs`, and `inner_boroughs`.
#'
#' 4. **Create Mapping Data Frames**:
#'    - Creates data frames (`borough_num`, `cand_num`, `regression_num`) to map borough names 
#'      to numerical identifiers for easier processing.
#'
#' 5. **Join Data to Borough Polygons**:
#'    - Adds numerical identifiers and source information to the borough polygons 
#'      by joining the mapping data frames.
#'
#' 6. **Prepare Evaluation Data**:
#'    - Filters and modifies the borough data to include only those boroughs 
#'      relevant for evaluation. Additional boroughs are appended to the list 
#'      of `data_avail`.
#'
#' 7. **Assign Borough Identifiers**:
#'    - Adds a unique identifier (`id`) for each borough in the evaluation data.
#'
#' 8. **Assign Original Shapes**:
#'    - Manually assigns the original geometry type (`point`, `polygon`, or `polyline`) 
#'      for each borough.
#'
#' 9. **Calculate Total Parking Spaces**:
#'    - Iterates through each borough in the evaluation data and calculates the 
#'      total parking spaces based on the geometry type:
#'        - **Point**: Aggregates parking spaces from `joint_points`.
#'        - **Polygon**: Aggregates parking spaces from `joint_polygons`.
#'        - **Polyline**: Aggregates parking spaces from `joint_polylines`.
#'    - Missing data is handled, and borough-specific totals are manually updated where necessary.
#'
#' 10. **Remove Boroughs with Insufficient Data**:
#'     - Removes boroughs such as "Harrow" that lack sufficient data for analysis.
#'
#' 11. **Add Controlled Parking Zone (CPZ) Coverage**:
#'     - Adds a `CPZ_coverage` column to the evaluation data, specifying the 
#'       percentage of controlled parking zones for each borough.
#'
#' ## Notes
#' - The script includes hardcoded updates for specific boroughs where data is missing.
#' - The final output (`summed_truth_df`) contains borough-level data with total parking 
#'   spaces and CPZ coverage, ready for further analysis.
#' 


# Preparing our boroughs

library(tidyverse)
library(lwgeom)
library(sp)
library(sf)
library(ggplot2)
#setseed(123)

# Here we read in the borough polygons, which we will expand to fill with the parking data for 
# each borough for which we have data,
# and then we will save the data to a CSV file for later use
borough_polygons <- st_read(dsn = "./data/raw/borough_polygons", layer = "london_borough_onstreet")

# We also read in joint_points.sh, joint_polylines.sh, and joint_polygons.sh
joint_points <- st_read(dsn = "./data/clean/joint_points.shp")
joint_polygons <- st_read(dsn = "./data/clean/joint_polygons.shp")
joint_polylines <- st_read(dsn = "./data/clean/joint_polylines.shp")

original_boroughs = c("Camden",
                      "City of London",
                      "Hackney",
                      "Harrow",
                      "Hounslow",
                      "Islington",
                      "Kensington and Chelsea",
                      "Sutton",
                      "Tower Hamlets",
                      "Wandsworth",
                      "Westminster")
sampling_boroughs = c("Camden",
                      "Hackney",
                      "Harrow",
                      "Hounslow",
                      "Islington",
                      "Sutton",
                      "Tower Hamlets",
                      "Wandsworth",
                      "Westminster")
regression_boroughs = c("Camden",
                        "Islington",
                        "Hackney",
                        #"Kensington and Chelsea",
                        "Westminster")
inner_boroughs = c("Camden",
                   "City of London",
                   "Greenwich",
                   "Hackney",
                   "Hammersmith and Fulham",
                   "Islington",
                   "Kensington and Chelsea",
                   "Lambeth",
                   "Lewisham",
                   "Southwark",
                   "Tower Hamlets",
                   "Wandsworth",
                   "Westminster")

borough_num <- data.frame(NUM = c(1:33), NAME = c("City of London", "Westminster", "Kensington and Chelsea", "Hammersmith and Fulham", "Wandsworth", "Lambeth", "Southwark", "Tower Hamlets", "Hackney", "Islington", "Camden", "Brent", "Ealing", "Hounslow", "Richmond upon Thames", "Kingston upon Thames", "Merton", "Sutton", "Croydon", "Bromley", "Lewisham", "Greenwich", "Bexley", "Havering", "Barking and Dagenham", "Redbridge", "Newham", "Waltham Forest", "Haringey", "Enfield", "Barnet", "Harrow", "Hillingdon"))

cand_num <- data.frame(CAND_NUM = c(1:9),
                       NAME = c("Camden",
                                "Hackney",
                                "Harrow",
                                "Hounslow",
                                "Islington",
                                "Sutton",
                                "Tower Hamlets",
                                "Wandsworth",
                                "Westminster"))
regression_num <- data.frame(REGRESS_NUM = c(1:4),
                             NAME = c("Hackney",
                                      "Islington",
                                      "Camden",
                                      "Westminster"
                                      #"Kensington and Chelsea"
                             ))

# Add num to `borough_polygons`
borough_polygons <- borough_polygons %>%
  left_join(borough_num, by = "NAME")
borough_polygons <- borough_polygons %>%
  left_join(cand_num, by = "NAME")
borough_polygons <- borough_polygons %>%
  left_join(regression_num, by = "NAME")

# we prepare the borough_polygons by cleaning some names
borough_polygons <- borough_polygons %>%
  mutate(original_source = NAME %in% original_boroughs) %>%
  mutate(sampling_source = NAME %in% sampling_boroughs) %>%
  mutate(regression_source = NAME %in% regression_boroughs) %>%
  mutate(inner = NAME %in% inner_boroughs)

point_boroughs <- c("camden", "westminster")
polygon_boroughs <- c("hackney", "islington", "camden", "westminster")
line_boroughs <- joint_polylines$borough %>% unique()

############# THE ACTUAL AGGREGATE COUNTING STARTS HERE ###########

# First, we create the london_df, which is the dataframe we will use to store the parking data
london_df <- borough_polygons

# Then, I made data_avail, which is the dataframe that I played around with 
# depending on what boroughs I figured out that I had aggregate ground truth data for

# Current selection of data_avail brouoghs
data_avail <- c( "Camden",
  "Hackney",
  "Hounslow",
  "Islington",
  "Sutton",
  "Tower Hamlets",
  "Wandsworth",
  "Westminster",
  "Southwark",
  "Kensington and Chelsea",
  "Newham",
  "Hammersmith and Fulham"
)

# So then the summed_truth_df is just the london_df
# for boroughs that are in the data_avail dataframe
# TO BE CLEAR, THESE ARE JUST THE BOROUGHS THAT I MANAGED TO FIND GROUND TRUTH DATA FOR
# AND THESE CAN BE EXPANDED UPON THE DISCOVERY OF GROUND TRUTH DATA FOR OTHER BOROUGHS
summed_truth_df <- london_df %>% filter(NAME %in% data_avail) %>%
  mutate(id = case_when(
    NAME == "Camden" ~ "camden",
    NAME == "City of London" ~ "city_of_london",
    NAME == "Hackney" ~ "hackney",
    NAME == "Harrow" ~ "harrow",
    NAME == "Hounslow" ~ "hounslow",
    NAME == "Islington" ~ "islington",
    NAME == "Sutton" ~ "sutton",
    NAME == "Tower Hamlets" ~ "tower_hamlets",
    NAME == "Wandsworth" ~ "wandsworth",
    NAME == "Westminster" ~ "westminster",
    NAME == "Brent" ~ "brent",
    NAME == "Southwark" ~ "southwark",
    NAME == "Kensington and Chelsea" ~ "kensington_and_chelsea",
    NAME == "Newham" ~ "newham",
    NAME == "Hammersmith and Fulham" ~ "hammersmith_and_fulham"
  ))


# I just wanted to add a column here which informed me how the ground truth data was originally
# encoded in the parking shape files
# However, I did also use boroughs for which I did not have geospatial ground truth data
# Just one single statistic given out by the borough o
# fill original_shape manually
summed_truth_df <- summed_truth_df %>%
  mutate(original_shape = case_when(
    NAME == "Camden" ~ "point",
    NAME == "City of London" ~ "polygon",
    NAME == "Hackney" ~ "polygon",
    NAME == "Harrow" ~ "polygon",
    NAME == "Hounslow" ~ "polyline",
    NAME == "Islington" ~ "polygon",
    NAME == "Sutton" ~ "polyline",
    NAME == "Tower Hamlets" ~ "polyline",
    NAME == "Wandsworth" ~ "polygon",
    NAME == "Westminster" ~ "point"
  )
  )

## GET TOTAL PARKING SPACES / BOROUGH
for (i in 1:length(summed_truth_df$NAME)) {
  # Create a temp df
  df <- summed_truth_df[i,]
  
  # Here we automate the aggregate number of parking spaces 
  # If it's a borough for which we didn't have a geospatial data file, we don't fill it
  # but if it is, we count all the spaces contained in the shape file depending on 
  # whether it was a point, a polyline, or a polygon encoded shape file
  # e.g. Westminster data was point data
  if (is.na(df$original_shape)) {
    print(paste("No original shape for", df$NAME))
    next
  }
  if(df$original_shape == "point") {
    print(paste("Point", df$NAME))
    points <- joint_points %>% filter(borough == df$id) %>%
      mutate(parking_spaces = ifelse(is.na(parking_spaces), 1, parking_spaces)) %>%
      summarise(total_spaces = sum(parking_spaces))
    print(points)
    total_spaces <- points$total_spaces[1]
    summed_truth_df[i, "total_spaces"] <- total_spaces
    print(total_spaces)
    
  } else if(df$original_shape == "polygon") {
    print(paste("Polygon", df$NAME))
    polygons <- joint_polygons %>% filter(borough == df$id) %>%
      summarise(total_spaces = sum(parking_spaces))
    print(polygons)
    total_spaces <- polygons$total_spaces[1]
    summed_truth_df[i, "total_spaces"] <- total_spaces
    print(total_spaces)
    
    
  } else if(df$original_shape == "polyline") {
    print(paste("Polyline", df$NAME))
    lines <- joint_polylines %>% filter(borough == df$id) %>%
      summarise(total_spaces = sum(parking_spaces))
    print(lines)
    total_spaces <- lines$total_spaces[1]
    summed_truth_df[i, "total_spaces"] <- total_spaces
    print(total_spaces)
    
  } else{}
}

# Here, I overwrote my final analysis with the most up to date aggregate parking statistics I could
# find submitted by the borough, but in future, we need to compare the aggregates released by the borough
# to our own actual summation of the parking points that we count in the raw shape files they give us
# (for the boroughs we have geospatial parking data for)
# See Zotero for the sources of these updated data 

# in future, these data should just be put into a CSV and then it should be right merged

# westminster 44,003 spaces
summed_truth_df[summed_truth_df$id == "westminster", ]$total_spaces <- 44003

# camden 35,523 spaces
summed_truth_df[summed_truth_df$id == "camden", ]$total_spaces <- 35523

# hounslow 76,890 spaces
# summed_truth_df[summed_truth_df$id == "hounslow", ]$total_spaces <- 76890
### hounslow is commented out because of the anomalous data between our own aggregate of the data
### that the borough published and the aggregate figure they published

# wandsworth 61,946 spaces
summed_truth_df[summed_truth_df$id == "wandsworth", ]$total_spaces <- 61946
  
# tower hamlets 28,373 spaces
summed_truth_df[summed_truth_df$id == "tower_hamlets", ]$total_spaces <- 28373

# kensington and chelsea 35,640 spaces
summed_truth_df[summed_truth_df$id == "kensington_and_chelsea", ]$total_spaces <- 35640
### Kensington & Chelsea is a borough where it was great to have an aggregate because
### it was not clear how to convert the shape files provided by the borough into an aggregate

# southwark 28,717 spaces
summed_truth_df[summed_truth_df$id == "southwark", ]$total_spaces <- 28717

# brent 88,000
#summed_truth_df[summed_truth_df$id == "brent", ]$total_spaces <- 88000
### Brent data was excluded for being anomalous too, despite the council publishing the
### aggregate of 88,000 spaces, we couldn't verify this data as we did not have 
### a shape file provided by the borough

# hammersmith and fulham 43,954 spaces
summed_truth_df[summed_truth_df$id == "hammersmith_and_fulham", ]$total_spaces <- 43954

# newham 72,000 spaces
summed_truth_df[summed_truth_df$id == "newham", ]$total_spaces <- 72000

# no aggregate data for islington but we were able to sum the geospatial data

# no aggregate data for sutton

# no aggregate data for harrow, nor was the geospatial data file complete (it was patchy)
#remove harrow
summed_truth_df <- summed_truth_df %>% filter(NAME != "Harrow")

# check NAs
summed_truth_df %>% filter(is.na(total_spaces))

# add CPZ_coverage
### IN FUTURE THIS CPZ COVERAGE SHOULD ALSO JUST BE UPDATED IN A CSV AND IMPORTED 
### INSTEAD OF BEING HARD CODED INTO THIS SCRIPT!!!!
# SEE ZOTERO FOR THE SOURCE OF THESE CPZ COVERAGE STATISTICS
summed_truth_df <- summed_truth_df %>%
  mutate(CPZ_coverage = case_when(
    NAME == "Camden" ~ 0.98,
    NAME == "Hackney" ~ 1,
    NAME == "Hounslow" ~ 0.36,
    NAME == "Islington" ~ 1,
    NAME == "Tower Hamlets" ~ 1,
    NAME == "Wandsworth" ~ 0.67,
    NAME == "Westminster" ~ 0.99,
    #NAME == "Brent" ~ 0.14,
    NAME == "Southwark" ~ 0.6,
    NAME == "Sutton" ~ 0.16,
    NAME == "Kensington and Chelsea" ~ 1,
    NAME == "Newham" ~ 0.99,
    NAME == "Hammersmith and Fulham" ~ 0.92
  ))

# SAVE THE DF A .shp FILE
st_write(summed_truth_df, "./data/results/by_borough/parking_ground_truth_per_borough.shp")


