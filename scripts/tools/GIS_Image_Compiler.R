#' # GIS Image Compiler Script: GIS_Image_Compiler.R
#' # Author: Felix Bridgeman
#'
#' This script reads CSV files containing SVI image metadata for the SVIs sampled near parking spaces
#' and SVIs sampled for from parking spaces, processes the data to generate new file paths, 
#' and copies the corresponding image files to specified directories.
#'
#' ## Inputs:
#' - Specific CSV files:
#'   - `../data/processed/sampled_panoID_locations/CSVs/london-panoid_fileInfo-roboflow.csv`
#'   - `../data/processed/sampled_panoID_locations/CSVs/near_parking_london-panoid_fileInfo-roboflow.csv`
#'   - `../data/processed/sampled_panoID_locations/CSVs/outside_parking_london-panoid_fileInfo-roboflow.csv`
#' - Each CSV file is expected to contain columns such as `folder` and `name` for image metadata.
#'
#' ## Outputs:
#' - Images are copied into the same directory under `/vast/palmer/scratch/miranda/fwb7/images`, 
#'   (The more powerful version copies images specifically into subdirectories 
#'    named based on the category extracted from the CSV filenames.)
#' - Processed images are saved with new paths derived from the metadata in the input CSV files.
#'
#' ## Workflow:
#' 1. Reads near_parking and outside_parking CSV files matching the pattern "roboflow.csv" in the `../data/processed/sampled_panoID_locations/CSVs` directory.
#' 2. Extracts category names from the filenames and creates corresponding directories.
#' 3. Prompts the user for confirmation before proceeding with each file.
#' 4. Processes the metadata to generate old and new file paths for the images.
#' 5. Copies the images from the old paths to the new paths.
#' 6. Separately processes specific CSV files (`inside_selected_panoids` and `outside_selected_panoids`) 
#'    to copy images to their respective directories.
#'
#' ## Notes:
#' - The script uses the `dplyr` library for data manipulation.
#' - At the bottom, there is a more powerful version of the script that can loop over every CSV in a folder
#'   instead of just two named CSVs.
#'   - In this case, the user is prompted to confirm whether to proceed with processing each file.
#'   - Ensure that the input CSV files and corresponding image files exist in the expected locations.
#'   - The script creates directories as needed and handles warnings for existing directories.

# create the folder if it doesn't exist
# operating in output dir: "/gpfs/gibbs/project/miranda/shared/", this is DIFFERENT from the project dir

library(dplyr)

setwd("/gpfs/gibbs/project/miranda/shared")
print(getwd())
dir.create("./GIS Match/collected_images", showWarnings = TRUE)

dir.create("./GIS Match/collected_images/inside_collected_images", showWarnings = TRUE)
dir.create("./GIS Match/collected_images/outside_collected_images", showWarnings = TRUE)
# dir.create("./GIS Match/collected_images/far_outside_collected_images", showWarnings = TRUE)

output_dir <- "./GIS Match/collected_images/"

# load panoids csv
# original_selected_panoids <- read.csv("./GIS Match/london-panoid_fileInfo-roboflow.csv")
inside_selected_panoids <- read.csv("./GIS Match/near_parking_london-panoid_fileInfo-roboflow.csv")
outside_selected_panoids <- read.csv("./GIS Match/outside_parking_london-panoid_fileInfo-roboflow.csv")
far_outside_selected_panoids <- read.csv("./GIS Match/far_outside_parking_london-panoid_fileInfo-roboflow.csv")

project_dir <- "/gpfs/gibbs/project/miranda/fwb7/yolov8/"
csv_dir <- "data/processed/sampled_panoID_locations/CSVs/"
inside_name <- "near_parking_london-panoid_fileInfo-roboflow.csv"
outside_name <- "outside_parking_london-panoid_fileInfo-roboflow.csv"

inside_location <- paste0(project_dir, csv_dir, inside_name)
outside_location <- paste0(project_dir, csv_dir, outside_name)

# test <- original_selected_panoids %>%
#   filter(name %in% inside_selected_panoids$name)

inside_selected_panoids <- inside_selected_panoids %>%
  # grep delete everything before the third "/"
  mutate(location = gsub(".*?/.*?/.*?/(.*)", "\\1", folder)) %>%
  mutate(old_pathname = paste0("/", location, "/", name)) %>%
  mutate(old_pathname = gsub(".*?/.*?/.*?/(.*)", "\\1", old_pathname)) %>%
  mutate(old_pathname = paste0("./", old_pathname)) %>%
  mutate(new_pathname = paste0(output_dir, "inside_collected_images/", name))

outside_selected_panoids <- outside_selected_panoids %>%
  # grep delete everything before the third "/"
  mutate(location = gsub(".*?/.*?/.*?/(.*)", "\\1", folder)) %>%
  mutate(old_pathname = paste0("/", location, "/", name)) %>%
  mutate(old_pathname = gsub(".*?/.*?/.*?/(.*)", "\\1", old_pathname)) %>%
  mutate(old_pathname = paste0("./", old_pathname)) %>%
  mutate(new_pathname = paste0(output_dir, "outside_collected_images/", name))

# far_outside_selected_panoids <- far_outside_selected_panoids %>%
#   # grep delete everything before the third "/"
#   mutate(location = gsub(".*?/.*?/.*?/(.*)", "\\1", folder)) %>%
#   mutate(old_pathname = paste0("/", location, "/", name)) %>%
#   mutate(old_pathname = gsub(".*?/.*?/.*?/(.*)", "\\1", old_pathname)) %>%
#   mutate(old_pathname = paste0("./", old_pathname)) %>%
#   mutate(new_pathname = paste0("./GIS Match/far_outside_collected_images/", name))

# save each image using "pathname" to a folder called "collected images" in current directory
file.copy(from = inside_selected_panoids$old_pathname,
          to = inside_selected_panoids$new_pathname,
          overwrite = FALSE)

file.copy(from = outside_selected_panoids$old_pathname,
          to = outside_selected_panoids$new_pathname,
          overwrite = FALSE)

# file.copy(from = far_outside_selected_panoids$old_pathname,
#           to = far_outside_selected_panoids$new_pathname,
#           overwrite = FALSE)





# csv_dir <- "..data/processed/sampled_panoID_locations/CSVs/"
# inside_name <- "near_parking_london-panoid_fileInfo-roboflow.csv"
# outside_name <- "outside_parking_london-panoid_fileInfo-roboflow.csv"
# inside_location <- paste0(csv_dir, inside_name)
# outside_location <- paste0(csv_dir, outside_name)

# #LEGACY#: original_selected_panoids <- read.csv("./GIS Match/london-panoid_fileInfo-roboflow.csv")
# inside_selected_panoids <- read.csv(inside_location)
# outside_selected_panoids <- read.csv(outside_location)

# #LEGACY#: test <- original_selected_panoids %>%
# #LEGACY#:   filter(name %in% inside_selected_panoids$name)

# inside_selected_panoids <- inside_selected_panoids %>%
#   # grep delete everything before the third "/"
#   mutate(location = gsub(".*?/.*?/.*?/(.*)", "\\1", folder)) %>%
#   mutate(old_pathname = paste0("/", location, "/", name)) %>%
#   mutate(old_pathname = gsub(".*?/.*?/.*?/(.*)", "\\1", old_pathname)) %>%
#   mutate(old_pathname = paste0("./", old_pathname)) %>%
#   mutate(new_pathname = paste0("/vast/palmer/scratch/miranda/fwb7/images/inside_buffers_sample/", name))

# outside_selected_panoids <- outside_selected_panoids %>%
#   # grep delete everything before the third "/"
#   mutate(location = gsub(".*?/.*?/.*?/(.*)", "\\1", folder)) %>%
#   mutate(old_pathname = paste0("/", location, "/", name)) %>%
#   mutate(old_pathname = gsub(".*?/.*?/.*?/(.*)", "\\1", old_pathname)) %>%
#   mutate(old_pathname = paste0("./", old_pathname)) %>%
#   mutate(new_pathname = paste0("/vast/palmer/scratch/miranda/fwb7/images/outside_buffers_sample/", name))

# # save each image using "pathname" to a folder called "collected images" in current directory
# file.copy(from = inside_selected_panoids$old_pathname,
#           to = inside_selected_panoids$new_pathname,
#           overwrite = FALSE)

# file.copy(from = outside_selected_panoids$old_pathname,
#           to = outside_selected_panoids$new_pathname,
#           overwrite = FALSE)


# FROM GIS_match.Rmd (just for file name sanity checking):
#inside_output_path <- paste0(csv_dir, "near_parking_london-panoid_fileInfo-roboflow.csv")
#outside_output_path <- paste0(csv_dir, "outside_parking_london-panoid_fileInfo-roboflow.csv")

### THIS IS A MORE POWERFUL SCRIPT TO ESSENTIALLY DO THE SAME THING BUT
### LOOP OVER EVERY CSV IN A FOLDER INSTEAD OF JUST 2 NAMED CSVs

# read every csv file in the folder
# load panoids csv
# for (file in list.files(csv_dir, pattern = "roboflow.csv", full.names = TRUE)) {
#   print(file)
#   cat_name <- str_extract(file, "(?<=/)[^/]*(?=_)")
#   print(cat_name)
#   # make a directory in vast palmer scratch with the name
#   dir.name <- paste0("/vast/palmer/scratch/miranda/fwb7/images", cat_name)
#   print(dir.name)
#   dir.create(path = dir.name, showWarnings = TRUE)
#   # ask whether to proceed
#   proceed <- readline(prompt = "Do you want to proceed? (y/n): ")
#   if (proceed != "y") {
#    # abort entire loop
#     break
#   }

#   # copy panoids from each disparate location into ONE FOLDER FOR EACH SUBSET
#   # each folder is named with the category name, e.g. for outside_parking_london-panoid_fileInfo-roboflow.csv
#   # the folder will be called "outside_parking"
#   panoids <- read.csv(file)
#   panoids <- panoids %>%
#     # grep delete everything before the third "/"
#     mutate(location = gsub(".*?/.*?/.*?/(.*)", "\\1", folder)) %>%
#     mutate(old_pathname = paste0("/", location, "/", name)) %>%
#     mutate(old_pathname = gsub(".*?/.*?/.*?/(.*)", "\\1", old_pathname)) %>%
#     mutate(old_pathname = paste0("./", old_pathname)) %>%
#     mutate(new_pathname = paste0(dir.name, name))
  
#   # save each image using "pathname" to a folder called "collected images" in current directory
#   file.copy(from = panoids$old_pathname,
#             to = panoids$new_pathname,
#             overwrite = FALSE)
# }
