library(dplyr)
library(readr)
library(janitor)
source("R/col_types_wells.R")

# this is the list of wells we already geocoded
geocoded <- read_csv("github_data/wells_geocoded.csv", col_types = col_types_wells)

# this is the list of well we geocoded today
newly_geocoded <- read_csv("data/wells_geocoded.csv", col_types = col_types_wells)

# update list of geocoded wells
all_geocoded <- bind_rows(geocoded,newly_geocoded) %>%
  arrange(well_tag_number)

write_csv(all_geocoded, "data/wells_geocoded.csv")  
