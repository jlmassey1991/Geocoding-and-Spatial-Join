#############################

#   LTC  ICE  CTs Mapped 

#############################

# Load library

library(dplyr)
library(sf)
library(foreign)
library(dplyr)
library(tidyverse)
library(readxl)
library(ggplot2)
library(usmap)
library(patchwork)
library(scales)
library(tidycensus)
library(rgdal)
options(tigris_use_cache = TRUE)


# Load NHSN data
ltc_ice <- read.csv('//cdc.gov/project/CCID_NCPDCID_NHSN_SAS/Data/work/_Projects/LTC/COVID-19/Codes/Jason/Surveillance Branch/SDOH/Geospatial/ice_maps.csv')

# add leading 0s to FIPS variable
library(stringi)
ltc_ice$FIPS <- stri_pad_left(str=ltc_ice$FIPS, 11, pad="0")

# Load shapefile
shapename <- read_sf('//cdc.gov/project/CCID_NCPDCID_NHSN_SAS/Data/work/_Projects/LTC/COVID-19/Codes/Jason/Surveillance Branch/SDOH/Geospatial/ICE/nhgis0005_shape/nhgis0005_shape/nhgis0005_shapefile_tl2022_us_tract_2022/US_tract_2022.shp')

# Rename GEOID to FIPS in Shapefile to match NHSN variable 
shapename <- shapename %>% 
  rename(FIPS = GEOID)

# Join/Merge NHSN to Shapefile 

ltc_ice_map <- left_join(ltc_ice, shapename, by = "FIPS")

ltc_ice_map = subset(ltc_ice_map, select = -c(geometry.x) )

ltc_ice_map <- ltc_ice_map %>% 
  rename(geometry = geometry.y)

#ICE and Res/Bed Ratio Maps in R 
plot(ltc_ice_map$geometry)


plot(shapename)