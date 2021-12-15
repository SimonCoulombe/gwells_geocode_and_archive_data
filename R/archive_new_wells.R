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
#newest_wells_file <- read_csv("data/wells.csv" , col_types = col_types_wells) # coltypes from R/coltypes_we

# actually we arent going to use the python script here because we need to read the other csvs in the zip file.
url <- "https://s3.ca-central-1.amazonaws.com/gwells-export/export/v2/gwells.zip"
temp_zip <- tempfile()
download.file(url, destfile = temp_zip)
temp_dir <- tempdir()
utils::unzip(temp_zip,exdir = temp_dir) #  files =  "well.csv", 

newest_wells_file <- read_csv(
  paste0(temp_dir, "/well.csv"), col_types = col_types_wells # from R/coltypes_we
) 


wells_in_db <- dbGetQuery(con1, "select well_tag_number from wells") 

#test <-  dbGetQuery(con1, "select * from wells limit 100") 
#------------------------------------------------------------
# Update historical caracteristics of wells on the day they were added
#------------------------------------------------------------

new_wells <- newest_wells_file %>%
  anti_join(wells_in_db) %>%
  mutate(date_added = as.Date(Sys.time() , tz = "America/Vancouver")) %>%
  janitor::clean_names()

if(nrow(new_wells)> 0){
  message("Appending new wells:", nrow(new_wells), " rows.", paste(new_wells$well_tag_number, collapse = " "))
  dbAppendTable(con1, "wells", new_wells)
  
} else{message("No new wells to append.")}


############## do same thing for drilling method file 

newest_drilling_method <-  read_csv(
  paste0(temp_dir, "/drilling_method.csv")  ,
  col_types = cols(well_tag_number = col_double(), drilling_method_code = col_character())
) 

wells_in_drilling_method_db <- dbGetQuery(con1, "select well_tag_number from drilling_method") 

new_drilling_method <- newest_drilling_method %>%
  anti_join(wells_in_drilling_method_db) %>% 
  mutate(date_added = as.Date(Sys.time() , tz = "America/Vancouver")) %>%
  janitor::clean_names()


if(nrow(new_drilling_method)> 0){
  message("Appending  new_drilling_method:", nrow(new_drilling_method), " rows.", paste(new_drilling_method$well_tag_number, collapse = " "))
  dbAppendTable(con1, "drilling_method", new_drilling_method)
  
} else{message("No new drilling method to append.")}
