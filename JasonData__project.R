jsonToDataFrame <- function(job, pMap){
    require(jsonlite)
    ## Assumes that input json object can be translated to a dataframe
    ## and that there are two columns X and Y with coordinates in long, lat decimal degrees
    ## ouput is an R data frame with X and Y columns in state plane coordinates as well as census
    ## tract id's
    NAD83_Z3 <- CRS("+proj=lcc +lat_1=38.43333333333333 +lat_2=37.06666666666667 +lat_0=36.5 +lon_0=-120.5 +x_0=2000000 +y_0=500000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")
    decdeg_proj <- CRS("+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")    

    df <- fromJSON(job, simplifyVector = TRUE, simplifyDataFrame = simplifyVector, flatten = TRUE)
    df <- coordinates(df) <- ~X+Y
    proj4string(df) <- filecord_proj
    df_trans <- spTransform(df,NAD83_Z3)
    censTracts <- over(df_trans,pMap)$Tract2010
    df_trans_fin <- as.data.frame(df_trans)
    df_trans_fin<- cbind(df_trans_fin, censTracts)
    df_trans_fin

}
