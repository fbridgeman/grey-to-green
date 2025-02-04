# create the folder if it doesn't exist
setwd("/gpfs/gibbs/project/miranda/shared")
print(getwd())
get
# dir.create("./GIS Match/collected_images", showWarnings = TRUE)

library(dplyr)

# read every csv file in the folder
# load panoids csv
for (file in list.files("./GIS Match", pattern = "roboflow.csv", full.names = TRUE)) {
  print(file)
  cat_name <- str_extract(file, "(?<=/)[^/]*(?=_)")
  print(cat_name)
  # make a directory in vast palmer scratch with the name
  dir.name <- paste0("/vast/palmer/scratch/miranda/fwb7/images", cat_name)
  print(dir.name)
  dir.create(path = dir.name, showWarnings = TRUE)
  # ask whether to proceed
  proceed <- readline(prompt = "Do you want to proceed? (y/n): ")
  if (proceed != "y") {
   # abort entire loop
    break
  }
  # copy panoids
  panoids <- read.csv(file)
  panoids <- panoids %>%
    # grep delete everything before the third "/"
    mutate(location = gsub(".*?/.*?/.*?/(.*)", "\\1", folder)) %>%
    mutate(old_pathname = paste0("/", location, "/", name)) %>%
    mutate(old_pathname = gsub(".*?/.*?/.*?/(.*)", "\\1", old_pathname)) %>%
    mutate(old_pathname = paste0("./", old_pathname)) %>%
    mutate(new_pathname = paste0(dir.name, name))
  
  # save each image using "pathname" to a folder called "collected images" in current directory
  file.copy(from = panoids$old_pathname,
            to = panoids$new_pathname,
            overwrite = FALSE)
}
?str_extract




original_selected_panoids <- read.csv("./GIS Match/london-panoid_fileInfo-roboflow.csv")
inside_selected_panoids <- read.csv("./GIS Match/near_parking_london-panoid_fileInfo-roboflow.csv")
outside_selected_panoids <- read.csv("./GIS Match/outside_parking_london-panoid_fileInfo-roboflow.csv")

test <- original_selected_panoids %>%
  filter(name %in% inside_selected_panoids$name)

inside_selected_panoids <- inside_selected_panoids %>%
  # grep delete everything before the third "/"
  mutate(location = gsub(".*?/.*?/.*?/(.*)", "\\1", folder)) %>%
  mutate(old_pathname = paste0("/", location, "/", name)) %>%
  mutate(old_pathname = gsub(".*?/.*?/.*?/(.*)", "\\1", old_pathname)) %>%
  mutate(old_pathname = paste0("./", old_pathname)) %>%
  mutate(new_pathname = paste0("/vast/palmer/scratch/miranda/fwb7/images", name))

outside_selected_panoids <- outside_selected_panoids %>%
  # grep delete everything before the third "/"
  mutate(location = gsub(".*?/.*?/.*?/(.*)", "\\1", folder)) %>%
  mutate(old_pathname = paste0("/", location, "/", name)) %>%
  mutate(old_pathname = gsub(".*?/.*?/.*?/(.*)", "\\1", old_pathname)) %>%
  mutate(old_pathname = paste0("./", old_pathname)) %>%
  mutate(new_pathname = paste0("/vast/palmer/scratch/miranda/fwb7/images", name))

# save each image using "pathname" to a folder called "collected images" in current directory
file.copy(from = inside_selected_panoids$old_pathname,
          to = inside_selected_panoids$new_pathname,
          overwrite = FALSE)

file.copy(from = outside_selected_panoids$old_pathname,
          to = outside_selected_panoids$new_pathname,
          overwrite = FALSE)

