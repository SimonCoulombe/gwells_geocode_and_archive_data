# this script is used  to pre-populate the 3 DBs 
# after running the 3 commands in the python scripts.


library(DBI)
library(readxl)
library(dplyr)
library(readr)
library(RPostgres)
source("R/col_types_wells.R")
con1 <- DBI::dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("BCGOV_DB"),
  host = Sys.getenv("BCGOV_HOST"),
  user = Sys.getenv("BCGOV_USR"),
  password=Sys.getenv("BCGOV_PWD")
)

# Some quick commands to get started
# https://db.rstudio.com/getting-started/database-queries
# dbListTables(con1)
# 
# dbWriteTable(conn = con1, 
#              name = "iris", 
#              value = iris, 
#              row.names = FALSE, 
#              overwrite = TRUE)
# 
# dbReadTable(con1, "iris")
#
# my_means <- tbl(con1, "iris") %>%
#   group_by(Species) %>%
#   summarise(
#    pouet = mean(Petal.Length) 
#   ) %>%
#   collect()
#
# dbGetQuery(con1, "select * from iris limit 10") 




# Option A : load from github first attemps
# 
# gwells_data_first_appearance <-
#   read_csv("https://raw.githubusercontent.com/SimonCoulombe/gwells_geocode_and_archive_data/main/data/gwells_data_first_appearance.csv",
#            col_types = col_types_wells)
# 
# gwells_geocoded <- read_csv("https://raw.githubusercontent.com/SimonCoulombe/gwells_geocode_and_archive_data/main/data/wells_geocoded.csv",
#                      col_types= col_types_geocoded) %>%
#   select(-X1)
# 
# 
# gwells_qa  <- read_csv("https://raw.githubusercontent.com/SimonCoulombe/gwells_geocode_and_archive_data/main/data/gwells_locationqa.csv",
#                     col_types = col_types_qa
#                   ) 

# Option B : load from PC.

#dbExecute(con1, "drop table wells;")
#dbExecute(con1, "drop table wells_geocoded;")
#dbExecute(con1, "drop table wells_qa;") 

## ajouter drilling method 
url <- "https://s3.ca-central-1.amazonaws.com/gwells-export/export/v2/gwells.zip"
temp_zip <- tempfile()
download.file(url, destfile = temp_zip)
temp_dir <- tempdir()
utils::unzip(temp_zip,exdir = temp_dir) 


drilling_method <-  read_csv(
  paste0(temp_dir, "/drilling_method.csv")  ,
  col_types = cols(well_tag_number = col_double(), drilling_method_code = col_character())
)  %>%
  mutate(date_added = lubridate::ymd("20211213"))


dbWriteTable(conn = con1, 
             name = "drilling_method", 
             value = drilling_method, 
             row.names = FALSE, 
             overwrite = TRUE)



wells <- read_csv("~/git/GWELLS_LocationQA/data/wells.csv",
                  col_types = col_types_wells) %>%
  filter(well_tag_number <= 124480)  %>% 
  mutate(date_added = lubridate::ymd("20211213")) %>%
  janitor::clean_names()

dbWriteTable(conn = con1, 
             name = "wells", 
             value = wells, 
             row.names = FALSE, 
             overwrite = TRUE)

wells_geocoded1 <- read_csv("~/git/GWELLS_LocationQA/data/wells_geocoded.csv",
                  col_types = col_types_geocoded) %>%
  filter(well_tag_number <= 124480)

wells_with_no_latlon <- wells %>% filter(is.na(latitude_decdeg) | is.na(longitude_decdeg)) %>% select(well_tag_number)

wells_geocoded <- wells_geocoded1 %>%
  anti_join(wells_with_no_latlon) %>%
  mutate(date_geocoded = lubridate::ymd("20211213")) %>%
  janitor::clean_names()

write_csv(wells_geocoded, "~/git/GWELLS_LocationQA/data/wells_geocoded.csv")

dbWriteTable(conn = con1, 
             name = "wells_geocoded", 
             value = wells_geocoded, 
             row.names = FALSE, 
             overwrite = TRUE)

wells_qa <- read_csv("~/git/GWELLS_LocationQA/gwells_locationqa.csv",
                            col_types = col_types_qa) %>%
  anti_join(wells_with_no_latlon) %>%
  filter(well_tag_number <= 124480) %>%
  mutate(date_qa = lubridate::ymd("20211213")) %>%
  janitor::clean_names()

dbWriteTable(conn = con1, 
             name = "wells_qa", 
             value = wells_qa, 
             row.names = FALSE, 
             overwrite = TRUE)

# create index, pas trop nécessaire
dbExecute(con1, "CREATE INDEX IF NOT EXISTS wells_wtn ON wells (well_tag_number);") 
dbExecute(con1, "CREATE INDEX IF NOT EXISTS wells_geocoded_wtn ON wells_geocoded (well_tag_number);")
dbExecute(con1, "CREATE INDEX IF NOT EXISTS wells_qa_wtn ON wells_qa (well_tag_number);") 

