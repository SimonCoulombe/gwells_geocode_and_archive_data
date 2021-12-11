library(purrr)
library(furrr)
library(dplyr)
library(readr)

 z <- read_csv("~/git/GWELLS_LocationQA/data/wells.csv")
 to_geocode <- z %>% filter(!is.na(latitude_Decdeg), !is.na(longitude_Decdeg)) 

 GEOCODER_ENDPOINT = "http://geocoder.api.gov.bc.ca/sites/nearest.json"
 
 library(httr)
 
 r <- httr::GET(url = paste0(GEOCODER_ENDPOINT, "?point=-123.7064038,48.8498537&apikey=",Sys.getenv("BCGOV_GEOCODER_API") ))
 plan(multiprocess, workers = availableCores()-1)
 
 
 geocode_and_save <- function(x,y, well_tag_number) {
    r <- httr::GET(url = paste0(GEOCODER_ENDPOINT, "?point=", x, ",", y, "&apikey=",Sys.getenv("BCGOV_GEOCODER_API") ))
   write_rds(content(r), paste0("geocoded/", well_tag_number))
   
 }
 
 furrr::future_pmap(list(x= to_geocode$longitude_Decdeg, y = to_geocode$latitude_Decdeg, well_tag_number = to_geocode$well_tag_number),
                    geocode_and_save,
                    .progress= TRUE)
 
 Data2 = data %>%
   mutate(pouet = future_map(object, ~ .x *2, .progress=TRUE)
          
 
 
 
 content(r)
 def reverse_geocode(
   x,
   y,
   geocoder_api_key,
   distance_start=200,
   distance_increment=200,
   distance_max=2000,
 ):
   """
    Provided a location as x/y coordinates (EPSG:4326), request an address
    from BC Geocoder within given distance_start (metres)

    If no result is found, request using an expanding search radius in
    distance_increment steps, until distance_max is reached.

    A dict with 'distance' = 99999 is returned if no result is found.

    This could sped up by:
    - just make the request using the max distance and derive distance between
      source point and returned location
    - make requests either in parallel or async

    """
 result = False
 distance = distance_start
 # expand the search distance until we get a result or hit the max distance
 while result is False and distance <= distance_max:
   params = {
     "point": str(x) + "," + str(y),
     "apikey": geocoder_api_key,
     "outputFormat": "json",
     "maxDistance": distance,
   }
 r = requests.get(GEOCODER_ENDPOINT, params=params)
 LOG.debug(r.request.url)
 
 # pause for 2s per request if near limit of 1000 requests/min
 if int(r.headers["RateLimit-Remaining"]) < 30:
   LOG.info("Approaching API limit, sleeping for 2 seconds to refresh.")
 sleep(2)
 if r.status_code == 200:
   result = True
 else:
   distance = distance + distance_increment
 if r.status_code == 200:
   address = r.json()["properties"]
 address["distance"] = distance
 return address
 else:
   empty_result = dict([(k, "") for k in ADDRESS_COLUMNS])
 empty_result["distance"] = 99999
 return empty_result
 
  
 
 