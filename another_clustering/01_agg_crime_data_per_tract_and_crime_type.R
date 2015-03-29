library(dplyr)
library(lubridate)
options(stringsAsFactors = F)

# load raw crime data
crime = read.csv('data/Raw_Crime_Data_with_Projected_coords_andTract.csv')

# format dates
crime$date_time = paste(substr(crime$Date, 1, 10), crime$Time)
crime$date_time = mdy_hm(crime$date_time)
range(crime$date_time)
# 2003-01-01 - 2015-03-04

# save as .rda
save(crime, file = 'output/crime.rda')

# check the uniqueness of incident number
cat(nrow(crime), length(unique(crime$IncidntNum)))
# it's not unique - one incident is records as multiple categories

# aggregate per tract and type
crime_agg = crime %>%
  group_by(crimeTracts, Category) %>%
  summarise(num_of_incidnt = n())

save(crime_agg, file = 'output/crime_agg.rda')
