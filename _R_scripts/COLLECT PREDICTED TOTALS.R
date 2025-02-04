
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


