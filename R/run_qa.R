library(dplyr)
library(readr)
library(janitor)
max_number_geocoded <- 50
max_number_qa <- 1000
source("R/col_types_wells.R")

#------------------------------------------------------------
# qa  wells that have never been geocoded
#------------------------------------------------------------
gwells_data_first_appearance <- read_csv("data/gwells_data_first_appearance.csv", col_types = col_types_wells)
all_geocoded <- read_csv("data/wells_geocoded.csv", col_types = col_types_wells)

old_qa  <- read_csv("github_data/gwells_locationqa.csv", col_types = col_types_wells) %>%
  select(-one_of(c("Unnamed: 0")))

to_qa_geocoded <- all_geocoded %>%
  anti_join(old_qa %>% select(well_tag_number)) %>%
  tail(max_number_qa)


  write.csv(to_qa_geocoded, "data/wells_geocoded.csv") # overwrite wells_geocoded.csv and wells.csv to allow script to run..
  to_qa_wells <- gwells_data_first_appearance %>%
    inner_join(to_qa_geocoded %>% select(well_tag_number))
  to_qa_wells <- gwells_data_first_appearance %>%
    inner_join(to_qa_geocoded %>% select(well_tag_number))
  write.csv(to_qa_wells, "data/wells.csv")
  

# 
# # this takes 800 seconds (12 minutes) on 5 rows..
# if(nrow(to_qa_geocoded)> 0){
#   write.csv(to_qa_geocoded, "data/wells_geocoded.csv") # overwrite wells_geocoded.csv and wells.csv to allow script to run..
#   to_qa_wells <- gwells_data_first_appearance %>%
#     inner_join(to_qa_geocoded %>% select(well_tag_number))
#   to_qa_wells <- gwells_data_first_appearance %>%
#     inner_join(to_qa_geocoded %>% select(well_tag_number))
#   write.csv(to_qa_wells, "data/wells.csv")
# 
#   p <- process$new(command = "python/qa.sh")
#   i <- 1
#   while(p$is_alive()){
#     print(paste0("Waiting for QA to complete. Total wait = ",  i, " s" ))
#     i <- i + 1
#     Sys.sleep(1)
#   }
#   
#   new_qa <- read_csv("gwells_locationqa.csv") %>%
#     select(-one_of(c("Unnamed: 0")))
#   
#   all_qa <- bind_rows(old_qa, new_qa)
#   
#   write_csv(all_qa, "data/gwells_locationqa.csv")
# } else {
#   write_csv(old_qa, "data/gwells_locationqa.csv")
# }
