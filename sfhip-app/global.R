#----------------------------------------------------------------------
# global.R
# Global functions and code for app
# JR New, 2015
#----------------------------------------------------------------------
# Load packages
library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(scales) # to access breaks/formatting function for dates
library(grid) # required for arrow
library(ggmap)
#----------------------------------------------------------------------
# Load and process data
# Alcohol establishments
if (!file.exists("df_alcohol.rda")) {
  df_alcohol_file <- "processed_data/alcohol_licenses_locations.csv"
  df_alcohol <- read.csv(df_alcohol_file, stringsAsFactors = FALSE)
  df_alcohol <- df_alcohol %>%
    mutate(Premise_Type = ifelse(License_Ty %in% c(1:29, 79, 81, 82, 85, 86), "Off-sale", "On-sale")) %>%
    mutate(License_Ty = as.factor(License_Ty),
           Premise_Type = as.factor(Premise_Type)) %>%
    mutate(Orig_Iss_Date = as.POSIXct(Orig_Iss_D, format = "%Y/%m/%d"),
           Orig_Iss_Year = as.numeric(sapply(Orig_Iss_D, function(x) strsplit(x, "/")[[1]][1])),
           Orig_Iss_Month = as.numeric(sapply(Orig_Iss_D, function(x) strsplit(x, "/")[[1]][2])),
           Orig_Iss_DateYM = as.POSIXct(paste(Orig_Iss_Year, Orig_Iss_Month, "01", sep = "-"), 
                                        format = "%Y-%m-%d")) %>%
    mutate(Zip_Code = sapply(zip, function(x) strsplit(x, "-")[[1]][1]))
  save(df_alcohol, file = "df_alcohol.rda")
} else {
  load("df_alcohol.rda")
}

onoff_categories <- as.character(unique(df_alcohol$Premise_Type))
onoff_categories <- as.list(sort(onoff_categories, decreasing = TRUE))
names(onoff_categories) <- c("On-premise alcohol sale", "Off-premise alcohol sale")
#----------------------------------------------------------------------
# Crimes
if (!file.exists("df_crime.rda")) {
  df_crime_file <- "processed_data/Raw_Crime_Data_with_Projected_coords_andTract_REDUCED.csv"
  df_crime <- read.csv(df_crime_file, stringsAsFactors = FALSE)
  df_crime <- df_crime %>%
    mutate(Date_Orig = Date,
           Date = as.POSIXct(sapply(Date, function(x) strsplit(x, " ")[[1]][1]), format = "%Y-%m-%d"),
           Year = as.numeric(sapply(Date_Orig, function(x) strsplit(x, "-")[[1]][1])),
           Month = as.numeric(sapply(Date_Orig, function(x) strsplit(x, "-")[[1]][2])),
           DateYM = as.POSIXct(paste(Year, Month, "01", sep = "-"), 
                               format = "%Y-%m-%d"),
           Longitude = as.numeric(gsub("\\)", "", sapply(Location, function(x) strsplit(x, ", ")[[1]][2]))),
           Latitude = as.numeric(gsub("\\(", "", sapply(Location, function(x) strsplit(x, ", ")[[1]][1]))))
  df_crime <- df_crime[, colnames(df_crime) != "Date_Orig"]
  save(df_crime, file = "df_crime.rda")
} else {
  load(file = "df_crime.rda")
}
#----------------------------------------------------------------------
# Crime centroids
df_crime_centroids_file <- "processed_data/crime_centroids.csv"
df_crime_centroids <- read.csv(df_crime_centroids_file, 
                               stringsAsFactors = FALSE)
crime_categories <- unique(df_crime_centroids$Category)
crime_categories <- crime_categories[!(crime_categories %in% "ALCOHOL STORES")]
crime_categories_and_alcohol <- as.list(c("ALCOHOL STORES", crime_categories))
crime_categories <- as.list(c("Please select", crime_categories))
names(crime_categories) <- crime_categories ###
names(crime_categories_and_alcohol) <- crime_categories_and_alcohol ###
#----------------------------------------------------------------------
# Census tracts shape files
# ggmap: http://journal.r-project.org/archive/2013-1/kahle-wickham.pdf
# http://www.kevjohnson.org/making-maps-in-r/
# http://www.kevjohnson.org/making-maps-in-r-part-2/
# Shape file downloaded for CA from https://www.census.gov/geo/maps-data/data/cbf/cbf_tracts.html
if (!file.exists("df_censustracts.rda")) {
  # # Fix weird error when boundaries of census tract intersect with boundaries of map
  # library(raster)
  # library(rgdal)
  # library(rgeos)
  # # 1. Install GDAL framework for MAC OS
  # # 2. Install rgeos and rgdal from source, see http://tlocoh.r-forge.r-project.org/mac_rgeos_rgdal.html
  # # a. First download source package of rgdal/rgeos
  # # b. In terminal:
  # # R CMD INSTALL ~/Copy/sfhip/libraries/rgdal_0.9-2.tar.gz --configure-args='--with-gdal-config=/Library/Frameworks/GDAL.framework/Programs/gdal-config
  # # --with-proj-include=/Library/Frameworks/PROJ.framework/Headers
  # # --with-proj-lib=/Library/Frameworks/PROJ.framework/unix/lib'
  # # R CMD INSTALL ~/Copy/sfhip/libraries/rgeos_0.3-9.tar.gz --configure-args='--with-geos-config=/Library/Frameworks/GEOS.framework/unix/bin/geos-config'
  box <- as(extent(as.numeric(attr(map, 'bb'))[c(2,4,1,3)] + c(.001,-.001,.001,-.001)), "SpatialPolygons")
  tract <- readOGR(dsn = "processed_data/gz_2010_06_140_00_500k", layer = "gz_2010_06_140_00_500k")
  proj4string(box) <- CRS(summary(tract)[[4]])
  df_censustracts <- gIntersection(tract, box, byid = TRUE, id = as.character(tract$TRACT))
  df_censustracts <- fortify(df_censustracts, id = "TRACT")
  save(df_censustracts, file = "df_censustracts.rda")
} else {
  load("df_censustracts.rda")
}
# Alternative way of getting shape file...
# library(maptools)
# library(gpclib)
# library(sp)
# gpclibPermit()
# if (!file.exists("df_censustracts.rda")) {
#   shapefile <- readShapeSpatial("processed_data/gz_2010_06_140_00_500k/gz_2010_06_140_00_500k.shp",
#                                 proj4string = CRS("+proj=longlat +datum=WGS84"), 
#                                 IDvar = "GEO_ID")
#   # Convert to a data.frame for use with ggplot2/ggmap and plot
#   df_censustracts <- fortify(shapefile, id = "GEO_ID")
#   df_censustracts$id <- substring(df_censustracts$id, 
#                                   nchar(df_censustracts$id[1]) - 5, nchar(df_censustracts$id[1]))
#   save(df_censustracts, file = "df_censustracts.rda")
# } else {
#   load("df_censustracts.rda")
# }
#----------------------------------------------------------------------
# Merge aggregated census tract level data with shape file data
if (!file.exists("df_censustracts_proc.rda")) {
  df_allbycensustract_file <- "processed_data/crime_census_alcohol.csv"
  df_allbycensustract <- read.csv(df_allbycensustract_file, stringsAsFactors = FALSE)
  # Alcohol and crime rates by census tracts
  df_allbycensustract <- df_allbycensustract %>%
    mutate(Tract2010 = as.character(Tract2010)) %>%
    mutate(Tract2010 = ifelse(nchar(Tract2010) == 5, paste0("0", Tract2010), Tract2010))
  # intersect(df_allbycensustract$Tract2010, df_censustracts$id)
  df_censustracts_proc <- df_censustracts %>%
    left_join(df_allbycensustract, by = c("id" = "Tract2010")) %>%
    filter(!is.na(Pop2010))
  save("df_censustracts_proc", file = "df_censustracts_proc.rda")
} else {
  load("df_censustracts_proc.rda")
}
plotcategories <- names(df_censustracts_proc)
plotcategories <- c("Please select",
                    plotcategories[!(plotcategories %in% 
                                   c("id", "long", "lat", "order", "hole", "piece", "group"))])
