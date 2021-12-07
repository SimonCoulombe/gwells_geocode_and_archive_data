library(dplyr)
library(readr)
library(janitor)

#library(reticulate)
#use_condaenv(condaenv = "gwells_locationqa", required= TRUE)

# this script has the type of all columns in the wells.csv
source("R/col_types_wells.R")

# lubridate can return time given a specific time zone. here are vancouver time and date
#lubridate::with_tz(Sys.time(), "America/Vancouver")
#as.Date(Sys.time() , tz = "America/Vancouver")

# read the  frehsly downloaded data/wells.csv downloaded by the python script.
current_well <- read_csv("data/wells.csv" , col_types = col_types_wells) # coltypes from R/coltypes_we

gwells_data_first_appearance <- 
  read_csv(
    "github_data/gwells_data_first_appearance.csv",
    col_types = col_types_wells
    )

#------------------------------------------------------------
# Update historical caracteristics of wells on the day they were added
#------------------------------------------------------------

new_wells <- current_well %>%
  anti_join(gwells_data_first_appearance %>% select(well_tag_number)) %>%
  mutate(date_added = as.Date(Sys.time() , tz = "America/Vancouver"))

# this is our  new list of date added, overwrite the old one
gwells_data_first_appearance <-
  bind_rows(gwells_data_first_appearance, new_wells)

write_csv(gwells_data_first_appearance, "data/gwells_data_first_appearance.csv")


# this is the list of well_tag_number in the csv today, might be useful to rebuild the list of dates added one day
# Initial idea was to save all the data every day, but 50 MB is too heavy for us..
well_tags_in_current_wells <-current_well  %>% select(well_tag_number)
write_csv(well_tags_in_current_wells, paste0("data/well_tag_numbers_",format(as.Date(Sys.time() , tz = "America/Vancouver"), "%Y%m%d")  ,".csv"))
zip(paste0("data/well_tag_numbers_",format(as.Date(Sys.time() , tz = "America/Vancouver"), "%Y%m%d")  ,".zip"),
    paste0("data/well_tag_numbers_",format(as.Date(Sys.time() , tz = "America/Vancouver"), "%Y%m%d")  ,".csv")
)
