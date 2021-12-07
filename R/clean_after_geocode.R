library(dplyr)
library(readr)
library(janitor)
source("R/col_types_wells.R")
geocoded <- read_csv("github_data/wells_geocoded.csv", col_types = col_types_wells)
newly_geocoded <- read_csv("data/wells_geocoded.csv", col_types = col_types_wells)

all_geocoded <- bind_rows(geocoded,newly_geocoded) %>%
  arrange(well_tag_number)
write_csv(all_geocoded, "data/wells_geocoded.csv")  
