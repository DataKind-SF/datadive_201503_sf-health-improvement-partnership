# Load libraries
library("data.table")
library("dplyr")

# Load data
data_311 <- read.csv("data/raw_data/Map__Crime_Incidents_-_from_1_Jan_2003.csv")
data_311 <- data.table(data_311)

################################################################################
# Filter dates
################################################################################

# Format data strings
date <- strsplit(as.character(data_311$Date), split=" ")
date <- lapply(date, function(x) x[1])
date <- unlist(date)
date <- as.Date(date, "%m/%d/%Y", tz="GMT")
data_311$Date <- date

# Extract only dates after 2010
after_2010_ix <- which(date > "2010-01-01")
data_311_filtered <- data_311[after_2010_ix, ]

################################################################################
# Map elements in description to either violence, drugs, alcohol, domestic
# violence, vandalism, or other, by matching relevant strings. The point is we
# want a description column more relevant to the public health interests of this
# data dive.
################################################################################

# Initialize data frame to store the mapping
descript_map <- unique(data_311_filtered[, c("Descript", "Category"), with=F])
descript_map <-data.table(descript_map,
                          CoarseDescript=rep("other", nrow(descript_map)))
setnames(descript_map, c("Descript", "Category", "CoarseDescript"))

# First, using coarse category columns
descript_map[which(descript_map$Category=="ASSAULT"), "CoarseDescript"] <- "violence"
descript_map[which(descript_map$Category=="DRUG/NARCOTIC"), "CoarseDescript"] <- "drugs"
descript_map[which(descript_map$Category=="LIQUOR LAWS"), "CoarseDescript"] <- "alcohol"
descript_map[which(descript_map$Category=="VANDALISM"), "CoarseDescript"] <- "vandalism"

# Filling in any possible missing labels using finer grain Descript column
descript_map[grep("ASSAULT|BATTERY|RAPE|PENETRATION|SUICIDE|FORCE", descript_map$Descript), "CoarseDescript"] <- "violence"
descript_map[grep("DRUG|SUBSTANCE|HEROIN|HYPODERMIC|GLUE|NARCOTICS|AMPHETAMINE|OPIUM|OPIATES|HALLUCINOGENIC|METHADONE|COCAINE|BARBITUATES|MARIJUANA", descript_map$Descript), "CoarseDescript"] <- "drugs"
descript_map[grep("ALCOHOL|INTOXICATED|DRUNK", descript_map$Descript), "CoarseDescript"] <- "alcohol"
descript_map[grep("THEFT|BURGLARY|ROBBERY|STOLEN|CARJACKING|SHOPLIFTING", descript_map$Descript), "CoarseDescript"] <- "theft"
descript_map[grep("DOMESTIC|COHABITEE|SPOUSAL", descript_map$Descript), "CoarseDescript"] <- "domestic_violence"
descript_map[grep("VANDALISM|GRAFFITI|MISCHIEF|GANG|NUISANCE|MAYHEM|DAMAGE", descript_map$Descript), "CoarseDescript"] <- "vandalism"

################################################################################
# View, and write results to file
################################################################################
data_311_filtered <- merge(data_311_filtered, descript_map, by=c("Descript", "Category"))

# See how overall categories related to general categories
table(data_311_filtered$Category, data_311_filtered$CoarseDescript)
data_311_filtered <- arrange(data_311_filtered, by=IncidntNum)
write.csv(data_311_filtered, file="data/processed_data/crime_incidents_map_since_2010.csv")
save(data_311_filtered, file="data/processed_data/crime_incidents_map_since_2010.RData")

# How to load into R
# data_311 <- get(load("data/processed_data/crime_incidents_map_since_2010.RData"))

