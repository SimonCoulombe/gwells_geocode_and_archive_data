library(dplyr)
library(readr)
library(janitor)
library(DBI)
library(RPostgres)
source("R/col_types_wells.R")
con1 <- DBI::dbConnect(
  #RPostgreSQL::PostgreSQL(),
  RPostgres::Postgres(),
  dbname = Sys.getenv("BCGOV_DB"),
  host = Sys.getenv("BCGOV_HOST"),
  user = Sys.getenv("BCGOV_USR"),
  password=Sys.getenv("BCGOV_PWD")
)

#library(reticulate)
#use_condaenv(condaenv = "gwells_locationqa", required= TRUE)

# this script has the type of all columns in the wells.csv
source("R/col_types_wells.R")

# lubridate can return time given a specific time zone. here are vancouver time and date
#lubridate::with_tz(Sys.time(), "America/Vancouver")
#as.Date(Sys.time() , tz = "America/Vancouver")

# read the  frehsly downloaded data/wells.csv downloaded by the python script.
newest_wells_file <- read_csv("data/wells.csv" , col_types = col_types_wells) # coltypes from R/coltypes_we

#newest_wells_file <- read_csv("~/git/GWELLS_LocationQA/data/wells.csv" , col_types = col_types_wells) # coltypes from R/coltypes_we

# gwells_data_first_appearance <- 
#   read_csv(
#     "github_data/gwells_data_first_appearance.csv",
#     col_types = col_types_wells
#     )

wells_in_db <- dbGetQuery(con1, "select well_tag_number from wells") 


test <-  dbGetQuery(con1, "select * from wells limit 100") 
#------------------------------------------------------------
# Update historical caracteristics of wells on the day they were added
#------------------------------------------------------------

new_wells <- newest_wells_file %>%
  anti_join(wells_in_db) %>%
  mutate(date_added = as.Date(Sys.time() , tz = "America/Vancouver")) %>%
  janitor::clean_names()

if(nrow(new_wells)> 0){
  message("Appending new wells:", nrow(new_wells), " rows.", new_wells$well_tag_number)
  dbAppendTable(con1, "wells", new_wells)
  
} else{message("No new wells to append.")}
