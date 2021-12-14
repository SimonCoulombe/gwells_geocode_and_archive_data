library(dplyr)
library(readr)
library(janitor)

source("R/col_types_wells.R")
library(RPostgres)
con1 <- DBI::dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("BCGOV_DB"),
  host = Sys.getenv("BCGOV_HOST"),
  user = Sys.getenv("BCGOV_USR"),
  password=Sys.getenv("BCGOV_PWD")
)
#------------------------------------------------------------
# identify wells that have never been "qa-ed"
#------------------------------------------------------------

# read the historical characteristics
wells_in_db <- dbGetQuery(con1, "select well_tag_number from wells") 

# this is all the well that have ever been geocoded
wells_geocoded_in_db <- dbGetQuery(con1, "select well_tag_number from wells_geocoded") 

# this is the wells that have already been "qa-ed"
wells_qa_in_db <- dbGetQuery(con1, "select well_tag_number from wells_qa") 

# this is the list of wells that need to be QAed today  (in wells and geocoded, but not in QA)
well_tag_number_that_need_QA <- wells_in_db %>%
  inner_join(wells_geocoded_in_db) %>%
  anti_join(wells_qa_in_db )  %>% 
  pull(well_tag_number)


if(length(well_tag_number_that_need_QA)>0){
  message(length(well_tag_number_that_need_QA), " records need QA. ", paste(well_tag_number_that_need_QA, collapse = " "))
  wells_for_csv <- tbl(con1, "wells" ) %>% 
    filter(well_tag_number %in% well_tag_number_that_need_QA) %>%
    rename(latitude_Decdeg = latitude_decdeg, 
           longitude_Decdeg = longitude_decdeg
    )
  
  write.csv(
    wells_for_csv, "data/wells.csv") # overwrite wells_geocoded.csv and wells.csv to allow script to run..
  
  wells_geocoded_for_csv <- tbl(con1, "wells_geocoded" ) %>% 
    filter(well_tag_number %in% well_tag_number_that_need_QA)     %>%
    rename(fullAddress = full_address,
           civicNumber = civic_number,
           civicNumberSuffix = civic_number_suffix,
           streetName = street_name,
           streetType = street_type, 
           isStreetTypePrefix = is_street_type_prefix,
           streetDirection = street_direction,
           isStreetDirectionPrefix = is_street_direction_prefix,
           streetQualifier = street_qualifier,
           localityName = locality_name
    )
  
  
  write.csv(wells_geocoded_for_csv, "data/wells_geocoded.csv")
} else {
  message("no record need QA")
  write_csv(
    dbGetQuery(con1, "select * from wells limit 0")  %>%
      rename(latitude_Decdeg = latitude_decdeg, 
             longitude_Decdeg = longitude_decdeg
      ) , "data/wells.csv")
  write_csv(
    dbGetQuery(con1, "select * from wells_geocoded limit 0")     %>%
      rename(fullAddress = full_address,
             civicNumber = civic_number,
             civicNumberSuffix = civic_number_suffix,
             streetName = street_name,
             streetType = street_type, 
             isStreetTypePrefix = is_street_type_prefix,
             streetDirection = street_direction,
             isStreetDirectionPrefix = is_street_direction_prefix,
             streetQualifier = street_qualifier,
             localityName = locality_name
      ),
    "data/wells_geocoded.csv")
  
}


