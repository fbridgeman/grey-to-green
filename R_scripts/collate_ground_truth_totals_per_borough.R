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
#' - `../raw_london/On-street parking/On-street parking (Alex)`:
#'   - Spatial data for London boroughs.
#' - `joint_points`, `joint_polygons`, `joint_polylines`:
#'   - Data frames containing parking space information for points, polygons, and polylines.
#' - CPZ_coverage.csv
#'  - A CSV file containing controlled parking zone (CPZ) coverage data for each borough.
#'  - (Not yet created, currently hardcoded in the script)
#' 
#' 
#' ## Outputs:
#' - `evaluation_df`:
#'   - A data frame containing borough-level data with total parking spaces and CPZ coverage, ready for further analysis.
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
#' - The final output (`evaluation_df`) contains borough-level data with total parking 
#'   spaces and CPZ coverage, ready for further analysis.
#' 


# Preparing our boroughs

library(tidyverse)
library(lwgeom)
library(sp)
library(sf)
library(ggplot2)
#setseed(123)

borough_polygons <- st_read(dsn = "../raw_london/On-street parking/On-street parking (Alex)", layer = "london_borough_onstreet")
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

borough_polygons <- borough_polygons %>%
  mutate(original_source = NAME %in% original_boroughs) %>%
  mutate(sampling_source = NAME %in% sampling_boroughs) %>%
  mutate(regression_source = NAME %in% regression_boroughs) %>%
  mutate(inner = NAME %in% inner_boroughs)



point_boroughs <- c("camden", "westminster")
polygon_boroughs <- c("hackney", "islington", "camden", "westminster")
line_boroughs <- joint_polylines$borough %>% unique()



######## START HERE ###########
london_df <- borough_polygons

data_avail <- sampling_boroughs
# remove harrow
#data_avail <- data_avail %>% filter(NAME != "Harrow")
# add southwark
data_avail <- append(data_avail, "Southwark")
# add ken and chelsea
data_avail <- append(data_avail, "Kensington and Chelsea")
# add newham
data_avail <- append(data_avail, "Newham")
# add hammer and fulham
data_avail <- append(data_avail, "Hammersmith and Fulham")
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
  
evaluation_df <- london_df %>% filter(NAME %in% data_avail) %>%
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



# fill original_shape manually
evaluation_df <- evaluation_df %>%
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
for (i in 1:length(evaluation_df$NAME)) {
  df <- evaluation_df[i,]
  
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
    evaluation_df[i, "total_spaces"] <- total_spaces
    print(total_spaces)
    
  } else if(df$original_shape == "polygon") {
    print(paste("Polygon", df$NAME))
    polygons <- joint_polygons %>% filter(borough == df$id) %>%
      summarise(total_spaces = sum(parking_spaces))
    print(polygons)
    total_spaces <- polygons$total_spaces[1]
    evaluation_df[i, "total_spaces"] <- total_spaces
    print(total_spaces)
    
    
  } else if(df$original_shape == "polyline") {
    print(paste("Polyline", df$NAME))
    lines <- joint_polylines %>% filter(borough == df$id) %>%
      summarise(total_spaces = sum(parking_spaces))
    print(lines)
    total_spaces <- lines$total_spaces[1]
    evaluation_df[i, "total_spaces"] <- total_spaces
    print(total_spaces)
    
  } else{}
}
# See zotero for these updated data

# westminster 44003
evaluation_df[evaluation_df$id == "westminster", ]$total_spaces <- 44003

# camden 35523
evaluation_df[evaluation_df$id == "camden", ]$total_spaces <- 35523

# hounslow 76890
# evaluation_df[evaluation_df$id == "hounslow", ]$total_spaces <- 76890

# wandsworth 61946
evaluation_df[evaluation_df$id == "wandsworth", ]$total_spaces <- 61946
  
# tower hamlets 28,373
evaluation_df[evaluation_df$id == "tower_hamlets", ]$total_spaces <- 28373

# kensington and chelsea 35,640
evaluation_df[evaluation_df$id == "kensington_and_chelsea", ]$total_spaces <- 35640

# southwark 28,717
evaluation_df[evaluation_df$id == "southwark", ]$total_spaces <- 28717

# brent 88,000
#evaluation_df[evaluation_df$id == "brent", ]$total_spaces <- 88000

# hammersmith and fulham 43,954
evaluation_df[evaluation_df$id == "hammersmith_and_fulham", ]$total_spaces <- 43954

# newham
evaluation_df[evaluation_df$id == "newham", ]$total_spaces <- 72000
# no data for islington
# no data for sutton
# no data for harrow

#remove harrow
evaluation_df <- evaluation_df %>% filter(NAME != "Harrow")

# check NAs
evaluation_df %>% filter(is.na(total_spaces))

# add CPZ_coverage
evaluation_df <- evaluation_df %>%
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


