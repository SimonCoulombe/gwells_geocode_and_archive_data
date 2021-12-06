library(dplyr)
library(readr)
library(janitor)
library(reticulate)
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
#url <- "https://s3.ca-central-1.amazonaws.com/gwells-export/export/v2/gwells.zip"
#temp_zip <- tempfile()
#download.file(url, destfile = temp_zip)
#temp_dir <- tempdir()
#utils::unzip(temp_zip, files =  "well.csv", exdir = temp_dir)

current_well <- read_csv(
  paste0(temp_dir, "/well.csv")
  , col_types = col_types_wells # from R/coltypes_we
) 
current_well %>% write_csv("data/current_well.csv")
# create fake  "historical" wells file without the last 500 rows.
if(FALSE){
  fake_old_list_of_date_added <- current_well %>% head(120000) %>% 
    select(well_tag_number) %>%
    mutate(date_added = Sys.Date() - (max(well_tag_number)-well_tag_number)/ 1000)
} else{
  fake_old_list_of_date_added <- read_csv("https://raw.githubusercontent.com/SimonCoulombe/schedule_github_actions_to_save_csv_to_amazon_s3/main/data/list_of_date_added.csv")

# code from get_rls_data in  covidtwitterbot
  # https://stackoverflow.com/questions/25485216/how-to-get-list-files-from-a-github-repository-folder-using-r
  # req <- GET("https://api.github.com/repos/jeanpaulrsoucy/covid-19-canada-gov-data-montreal/git/trees/master?recursive=1")
  # stop_for_status(req)
  # filelist <- unlist(lapply(content(req)$tree, "[", "path"), use.names = F)
  # liste_tableau_rls_new <- grep("cases-by-rss-and-rls/tableau-rls-new_", filelist, value = TRUE, fixed = TRUE)
  #
  #
  # suppressWarnings(
  #   csvs <-
  #     furrr::future_map(
  #       liste_tableau_rls_new,
  #       ~ readr::read_csv(
  #         paste0("https://raw.githubusercontent.com/jeanpaulrsoucy/covid-19-canada-gov-data-montreal/master/", .x),
  #         col_types = readr::cols(
  #           No = readr::col_character(),
  #           RSS = readr::col_character(),
  #           NoRLS = readr::col_character(),
  #           RLS = readr::col_character(),
  #           .default = readr::col_number()
  #         )
  #       )
  #     )
  # )
  # end -- this old code has been depre
  
}


new_wells <- current_well %>%
  select(well_tag_number) %>% 
  anti_join(fake_old_list_of_date_added) %>%
  mutate(date_added = as.Date(Sys.time() , tz = "America/Vancouver"))

new_wells

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


# here is our empty list of well addresses  (run once to initialize)
#write_csv(well_tags_in_current_wells %>% filter(TRUE == FALSE), "data/addressed_well.csv")


