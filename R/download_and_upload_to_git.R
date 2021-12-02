library(dplyr)
library(readr)
library(janitor)
source("R/col_types_wells.R")


# NOTE : when creating github secrets to not add quotes around the keys and regions.
# file.edit(".Renviron")
# AWS_ACCESS_KEY_ID = "mykey"
# AWS_SECRET_ACCESS_KEY = "mysecret"
# AWS_DEFAULT_REGION = "us-east-1"


# lubridate can return time given a specific time zone.
lubridate::with_tz(Sys.time(), "America/Vancouver")

# voici la date de vancouver  
as.Date(Sys.time() , tz = "America/Vancouver")

# download the wells zip  to a temporary file
url <- "https://s3.ca-central-1.amazonaws.com/gwells-export/export/v2/gwells.zip"
temp_zip <- tempfile()
download.file(url, destfile = temp_zip)
temp_dir <- tempdir()
utils::unzip(temp_zip, files =  "well.csv", exdir = temp_dir)

current_well <- read_csv(
  paste0(temp_dir, "/well.csv")
  , col_types = col_types_wells # from R/coltypes_we
) %>%
  janitor::clean_names()

# create fake  "historical" wells file without the last 500 rows.
if(FALSE){
  fake_old_list_of_date_added <- current_well %>% head(-500) %>% 
    select(well_tag_number) %>%
    mutate(date_added = Sys.Date() - (max(well_tag_number)-well_tag_number)/ 1000)
}


new_wells <- current_well %>%
  select(well_tag_number) %>% 
  anti_join(fake_old_list_of_date_added) %>%
  mutate(date_added = Sys.Date())


# this is our  new list of date added, overwrite the old one
new_list_of_date_added <-
  bind_rows(fake_old_list_of_date_added, new_wells)
write_csv(new_list_of_date_added, "data/list_of_date_added.csv")


# this is the list of well_tag_number in the csv today, might be useful to rebuild the list of dates added on day
well_tags_in_current_wells <-current_well  %>% select(well_tag_number)
write_csv(well_tags_in_current_wells, paste0("data/well_tag_numbers_",format(as.Date(Sys.time() , tz = "America/Vancouver"), "%Y%m%d")  ,".csv"))
zip(paste0("data/well_tag_numbers_",format(as.Date(Sys.time() , tz = "America/Vancouver"), "%Y%m%d")  ,".zip"),
    paste0("data/well_tag_numbers_",format(as.Date(Sys.time() , tz = "America/Vancouver"), "%Y%m%d")  ,".csv")
    )





