library(maptools)
library(plyr)
library(spatstat)
library(sp)
library(rgdal)
library(vegan) ## For Shannon diversity index
##library("OpenStreetMap")
##library("sparr")
## State plane coordinate symtems for California, zone 3 which includes Bay Area
NAD83_Z4 <- CRS("+proj=lcc +lat_1=38.43333333333333 +lat_2=37.06666666666667 +lat_0=36.5 +lon_0=-120.5 +x_0=2000000 +y_0=500000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")
NAD83HARN_Z4 <- CRS("+proj=lcc +lat_1=38.43333333333333 +lat_2=37.06666666666667 +lat_0=36.5 +lon_0=-120.5 +x_0=2000000 +y_0=500000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")
filecord_proj <- CRS("+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")
## Spatial layers and Brondfield data
coverages <- dir("Brondfield_ACS_alcohol_data/", pattern="*.shp")
coverages <- sub("\\.shp","",coverages)
coverages <- coverages[-grep("xml",coverages)]

## No dbf file for Alc_outlets_13_final_Project
## If this layer is important need to fix
sfmaps <- alply(coverages[-3],1,function(f){
    ##readShapeSpatial(paste("Brondfield_ACS_alcohol_data/",f,sep=""))
    readOGR("Brondfield_ACS_alcohol_data",layer=f)
})

### Plot the neighborhoods and points
plot(sfmaps[[3]])
plot(sfmaps[[1]],add=T) ## Off sale points
plot(sfmaps[[2]],add=T,col=2) ##On sale points
summary(sfmaps[[1]])
summary(sfmaps[[2]])
summary(sfmaps[[3]])
summary(sfmaps[[4]])

i <- which(sfmaps[[1]]$X>=0 | sfmaps[[1]]$Y<=0)
## i is 10 unmatched addresses, 2 in the ferry building
## and the rest are at SF airport
offSaleAlcLic <- spTransform(sfmaps[[1]][-i,],NAD83_Z4)
j <- which(sfmaps[[2]]$X>=0 | sfmaps[[2]]$Y<=0)
## j is 43 unmatched addresses in SF airport, ferry building
## and a few other locations
onSaleAlcLic <- spTransform(sfmaps[[2]][-j,],NAD83_Z4)
SFCensTractACS <- spTransform(sfmaps[[3]],NAD83_Z4)
SFNeighb <- spTransform(sfmaps[[4]],NAD83_Z4)
##SFzips <- spTransform(sfmaps[[5]],NAD83_Z4)

## Try spplot
spplot(sfmaps[[3]], c("below_25k", "k25_50k", "k50_100k","over_100k"))
## Tenderloin and Bayview/Hunters point stand out, as low income areas


## Kernel density of licenses
p <- as.ppp(sfmaps[[1]])
p <- SpatialPoints(coords = matrix(c(p$x[p$x>0], p$y[p$y>0]), ncol = 2))
p <- as.ppp(p)
d <- density.ppp(p, 400)
plot(d)

p2 <- as.ppp(sfmaps[[2]])
p2 <- SpatialPoints(coords = matrix(c(p2$x[p2$x>0], p2$y[p2$y>0]), ncol = 2))
p2 <- as.ppp(p2)
d2 <- density.ppp(p2, 400)
plot(d2)
plot(sfmaps[[3]],add=T,col='white')
## Spatial join of licenses and census tracts, total count
## number of licenses, number of types and a diversity measure for license types(Shannon?)
#aggre



## Demographic data
##demog <- read.csv("Brondfield_ACS_alcohol_data/ACS_11_5YR_SF_full_demographics.csv")
demog <- read.csv("Brondfield_ACS_alcohol_data/ACS_11_5YR_SF_selected_demo_edit.csv")
summary(demog)

## Note: all Max's data seem to be for 2010, do we need years closer to 2015? should we adjust by
##the acs data?

## Police data
## Crimes
## NAD 1983 HARN -> NAD83
##crimeDat <- read.csv("SSciortino_data_docs/sfpdgeo_out4datakind_SSciortino.csv")
##with(crimeDat,plot(X,Y))
##with(crimeDat,table(year,crimecat, PdDistrict))
##coordinates(crimeDat) <- ~X+Y
##p1 <- CRS("+proj=longlat +datum=NAD83")
##p1 <- CRS("+proj=longlat +datum=WGS84")
## Need to figure out what projecton each of these data sets are in. Sigh
## Figured out using Qgis
##proj4string(crimeDat) <- filecord_proj
##crimeDat_trans <- spTransform(crimeDat,NAD83_Z4)

##crimeDat2003 <- read.csv("Other data/Map__Crime_Incidents_-_from_1_Jan_2003.csv")
##with(crimeDat2003,table(Category, PdDistrict))
## This is the more complete data downloaded from sfdata.gov
## Filtered down to 2010 to 2015 bu still has some categories
## that may not be relevant
crimeDatReduced<- read.csv("Other data_NJLK/Map__Crime_Incidents_-_from_1_Jan_2003_REDUCED.csv")
coordinates(crimeDatReduced) <- ~X+Y
proj4string(crimeDatReduced) <- filecord_proj
crimeDat_trans <- spTransform(crimeDatReduced,NAD83_Z4)


## 311 Data
##complaints311 <- read.csv("Other data_NJLK/Map__Crime_Incidents_-_from_1_Jan_2003.csv")

## If we want to do any distance based calculations,
## should probably reproject everything into UTM coordinates, I think that one
## preserves distances

## Now think about plotting crime density by year and type, do
## I probably need to put the density calculation in the panel function.
## for spplot, what about ggmap?

