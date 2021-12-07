library(dplyr)
library(readr)
library(janitor)
library(processx)
max_number_geocoded <- 50
max_number_qa <- 1000

source("R/col_types_wells.R")

gwells_data_first_appearance <- read_csv("data/gwells_data_first_appearance.csv", col_types = col_types_wells)

geocoded <- read_csv("github_data/wells_geocoded.csv")

to_geocode <- gwells_data_first_appearance %>%
  anti_join(geocoded %>% select(well_tag_number)) %>%
  tail(max_number_geocoded)
message("created to_geocode")

# geocoding takes about 1 second per row
if(nrow(to_geocode)> 0){
  message("geocoding")
  message("overwrite data/wells.csv")
  write.csv(to_geocode, "data/wells.csv") # overwrite wells.csv because the shell script will read that file
  
  message("launching geocode process")
  p <- process$new(command = "python/geocode.sh")
  i <- 1
  while(p$is_alive()){
    print(paste0("Waiting for geocode to complete. Total wait = ",  i, " s" ))
    i <- i + 1
    Sys.sleep(1)
  }
  message("print list files")
  print(list.files())
  message("print list files data/")
  print(list.files("data/"))
  
  message("read the hopefully newly created wells_geocoded.csv")
  newly_geocoded <- read_csv("data/wells_geocoded.csv")
  message("combine new and old geocoded csv")
  all_geocoded <-
    bind_rows(geocoded, newly_geocoded)
  message("write new wells_geocoded.csv")
  write_csv(all_geocoded, "data/wells_geocoded.csv")  
} else {
  write_csv(geocoded, "data/wells_geocoded.csv")
}


