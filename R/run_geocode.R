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

# geocoding takes about 1 second per row
if(nrow(to_geocode)> 0){
  write.csv(to_geocode, "data/wells.csv") # overwrite wells.csv because the shell script will read that file
  p <- process$new(command = "python/geocode.sh")
  i <- 1
  while(p$is_alive()){
    print(paste0("Waiting for geocode to complete. Total wait = ",  i, " s" ))
    i <- i + 1
    Sys.sleep(1)
  }
}
newly_geocoded <- read_csv("data/wells_geocoded.csv")
all_geocoded <-
  bind_rows(geocoded, newly_geocoded)

write_csv(all_geocoded, "data/wells_geocoded.csv")
