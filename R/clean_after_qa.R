library(dplyr)
library(readr)
library(janitor)

source("R/col_types_wells.R")

#this script combines the old QA and the newly  QAed files

old_qa  <- read_csv("github_data/gwells_locationqa.csv", col_types = col_types_wells) %>%
  select(-one_of(c("Unnamed: 0")))

new_qa <- read_csv("gwells_locationqa.csv", col_types = col_types_wells) %>%
  select(-one_of(c("Unnamed: 0")))

all_qa <- bind_rows(old_qa, new_qa) %>%
  arrange(well_tag_number)

write_csv(all_qa, "data/gwells_locationqa.csv")

