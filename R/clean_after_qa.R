library(dplyr)
library(readr)
library(janitor)

source("R/col_types_wells.R")
source("R/col_types_wells.R")

library(RPostgres)
con1 <- DBI::dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("BCGOV_DB"),
  host = Sys.getenv("BCGOV_HOST"),
  user = Sys.getenv("BCGOV_USR"),
  password=Sys.getenv("BCGOV_PWD")
)


newly_qa <- read_csv("gwells_locationqa.csv", col_types = col_types_qa) %>%
  select(-one_of(c("Unnamed: 0"))) %>% 
  mutate(date_qa = as.Date(Sys.time() , tz = "America/Vancouver")) %>%
  janitor::clean_names()


if(nrow(newly_qa)> 0){
  message("Appending newly qa  wells:", nrow(newly_qa), " rows. well_tag_number=", paste(newly_qa$well_tag_number, collase = " "))
  dbAppendTable(con1, "wells_qa", newly_qa)
  
} else{message("No new qa wells to append.")}

