library(dplyr)
library(readr)
library(janitor)
max_number_geocoded <- 50
max_number_qa <- 1000

source("R/col_types_wells.R")


old_qa  <- read_csv("github_data/gwells_locationqa.csv", col_types = col_types_wells) %>%
  select(-one_of(c("Unnamed: 0")))

new_qa <- read_csv("gwells_locationqa.csv", col_types = col_types_wells) %>%
  select(-one_of(c("Unnamed: 0")))

all_qa <- bind_rows(old_qa, new_qa)

write_csv(all_qa, "data/gwells_locationqa.csv")

