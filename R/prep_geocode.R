library(dplyr)
library(readr)
library(janitor)
library(processx)
max_number_geocoded <- 1000 # this is the maximum number of wells we are willing to geocode today
source("R/col_types_wells.R")


# read the historical caracteristics
gwells_data_first_appearance <- read_csv("data/gwells_data_first_appearance.csv", col_types = col_types_wells)

# read the list of wells that have already been geocoded  
geocoded <- read_csv("github_data/wells_geocoded.csv")

# this is the list of wells that need geocoding
to_geocode <- gwells_data_first_appearance %>%
  anti_join(geocoded %>% select(well_tag_number)) %>%
  tail(max_number_geocoded)
message(paste0(Sys.time() , "created to_geocode"))


# since the geocode python script reads data/wells.csv, we overwrite the 
# wells.csv file with the data we want to geocode.
write.csv(to_geocode, "data/wells.csv")
