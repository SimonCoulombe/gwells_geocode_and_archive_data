library(dplyr)
library(readr)
library(janitor)

#library(reticulate)
#use_condaenv(condaenv = "gwells_locationqa", required= TRUE)

#list.files("python")

max_number_geocoded <- 50
max_number_qa <- 1000

#system("git clone https://github.com/SimonCoulombe/gwells_geocode_and_archive_data.git")
source("R/col_types_wells.R")

# lubridate can return time given a specific time zone.
lubridate::with_tz(Sys.time(), "America/Vancouver")

# voici la date de vancouver
as.Date(Sys.time() , tz = "America/Vancouver")

# readthe frehsly downloaded data/wells.csv downloaded by the python script.
current_well <- read_csv("data/wells.csv" , col_types = col_types_wells) # coltypes from R/coltypes_we


if(FALSE){
  gwells_data_first_appearance <- current_well %>% head(120000) %>%
    mutate(date_added = Sys.Date() - (max(well_tag_number)-well_tag_number)/ 1000)
} else{
  gwells_data_first_appearance <-
    read_csv("github_data/gwells_data_first_appearance.csv",
             col_types = col_types_wells)
}

#------------------------------------------------------------
# Update historical list of wells on the day they were added
#------------------------------------------------------------

new_wells <- current_well %>%
  anti_join(gwells_data_first_appearance %>% select(well_tag_number)) %>%
  mutate(date_added = as.Date(Sys.time() , tz = "America/Vancouver"))


# this is our  new list of date added, overwrite the old one
gwells_data_first_appearance <-
  bind_rows(gwells_data_first_appearance, new_wells)
write_csv(gwells_data_first_appearance, "data/gwells_data_first_appearance.csv")


# this is the list of well_tag_number in the csv today, might be useful to rebuild the list of dates added on day
# it would be nice to save all the data each day, but 50 MB is too heavy for us..
well_tags_in_current_wells <-current_well  %>% select(well_tag_number)
write_csv(well_tags_in_current_wells, paste0("data/well_tag_numbers_",format(as.Date(Sys.time() , tz = "America/Vancouver"), "%Y%m%d")  ,".csv"))
zip(paste0("data/well_tag_numbers_",format(as.Date(Sys.time() , tz = "America/Vancouver"), "%Y%m%d")  ,".zip"),
    paste0("data/well_tag_numbers_",format(as.Date(Sys.time() , tz = "America/Vancouver"), "%Y%m%d")  ,".csv")
)


