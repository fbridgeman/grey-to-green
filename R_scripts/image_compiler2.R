# File: image_compiler2.R
# Author: Felix Bridgeman
# Description:
# This script compiles SVI images described by the results in the panoid_locations subdirectory
# and copies the images into a single subdirectory in the scratch space.


# create the folder if it doesn't exist
setwd("/gpfs/gibbs/project/miranda/shared")
# print(getwd())
# dir.create("./GIS Match/collected_images", showWarnings = TRUE)

library(dplyr)
library(stringr)
library(fs)
?fs::file_copy()
# load panoids csv
# setwd("/gpfs/gibbs/project/miranda/fwb7/yolov8")
getwd()

list.files("/gpfs/gibbs/project/miranda/fwb7/yolov8/panoid_locations/results", "deploy.csv", full.names = TRUE) 

for (file in list.files("/gpfs/gibbs/project/miranda/fwb7/yolov8/panoid_locations/results", "deploy.csv", full.names = TRUE)) {
  print(file)
  after_last_slash <- str_extract(file, "[^/]+$") # Matches everything after the last "/"
  cat_name <- str_extract(after_last_slash, "^[^_]+")
  print(cat_name)
}

for (file in list.files("/gpfs/gibbs/project/miranda/fwb7/yolov8/panoid_locations/results", "deploy.csv", full.names = TRUE)) {
     print(file)
     after_last_slash <- str_extract(file, "[^/]+$") # Matches everything after the last "/"
     cat_name <- str_extract(after_last_slash, "^[^_]+")
     print(cat_name)
     # proceed <- readline(prompt = "Do you want to proceed? (y/n): ")
     # if (proceed != "y") {
     #   next
     # }
     # make a directory in vast palmer scratch with the name
     dir.name <- paste0("/vast/palmer/scratch/miranda/fwb7/images/", cat_name)
     print(dir.name)
     dir.create(path = dir.name, showWarnings = TRUE)
     # ask whether to proceed
     # copy panoids
     panoids <- read.csv(file)
     message("file successfully read")
     print(head(panoids))
     panoids <- panoids %>%
       # grep delete everything before the third "/"
       mutate(location = gsub(".*?/.*?/.*?/(.*)", "\\1", folder)) %>%
       mutate(old_pathname = paste0("/", location, "/", name)) %>%
       mutate(old_pathname = gsub(".*?/.*?/.*?/(.*)", "\\1", old_pathname)) %>%
       mutate(old_pathname = paste0("./", old_pathname)) %>%
       mutate(new_pathname = paste0(dir.name, "/", name))
     message("successfully created the old and new pathnames")
     
     
     # save each image using "pathname" to a folder called "collected images" in current directory
     batch_size <- 200000
     total_rows <- nrow(panoids)
     total_batches <- ceiling(total_rows / batch_size)
     
     for (batch in 1:total_batches) {
       start_idx <- ((batch - 1) * batch_size) + 1
       end_idx <- min(batch * batch_size, total_rows)
       
       message(sprintf("Processing batch %d of %d (rows %d to %d)", 
                       batch, total_batches, start_idx, end_idx))
       
       # Vector operations instead of inner loop
       file.copy(from = panoids$old_pathname[start_idx:end_idx],
                 to = panoids$new_pathname[start_idx:end_idx],
                 overwrite = TRUE)
       message("Images copied")
       
       #Sys.sleep(0.1)  # Small delay between batches
     }
}
