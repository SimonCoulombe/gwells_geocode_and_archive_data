library(dplyr)
library(readr)
library(janitor)

max_number_qa <- 1000
source("R/col_types_wells.R")

#------------------------------------------------------------
# qa  wells that have never been "qa-ed"
#------------------------------------------------------------

# read the historical characteristics
gwells_data_first_appearance <- read_csv("data/gwells_data_first_appearance.csv", col_types = col_types_wells)

# this is all the well that have ever been geocoded
all_geocoded <- read_csv("data/wells_geocoded.csv", col_types = col_types_geocoded)

# this is the wells that have already been "qa-ed"
old_qa  <- read_csv("github_data/gwells_locationqa.csv", col_types = col_types_qa) 


# today we will qa the well that have already been geocoded but never  qa'ed
# up to a limit of the most recent 'max_number_qa'
to_qa_geocoded <- all_geocoded %>%
  anti_join(old_qa %>% select(well_tag_number)) %>%
  tail(max_number_qa)

# the python qa scripts requires the data/wells.csv and the data/wells_geocoded.csv files
# so we update them with the characteristics of the wells we want to QA. 
write.csv(to_qa_geocoded, "data/wells_geocoded.csv") # overwrite wells_geocoded.csv and wells.csv to allow script to run..

to_qa_wells <- gwells_data_first_appearance %>%
  inner_join(to_qa_geocoded %>% select(well_tag_number))

to_qa_wells <- gwells_data_first_appearance %>%
  inner_join(to_qa_geocoded %>% select(well_tag_number))

write.csv(to_qa_wells, "data/wells.csv")