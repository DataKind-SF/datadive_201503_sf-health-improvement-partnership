library(dplyr)
library(reshape2)
options(stringsAsFactors = F)

# load census tract data
census = read.csv('data/census_tract_demographics.csv')
census = select(census, Tract2010, Pop2010)

# merge with crime data
load('output/crime_agg.rda')
crime_census = crime_agg %>%
  filter(!is.na(crimeTracts)) %>%
  rename(Tract2010 = crimeTracts) %>%
  left_join(census, by = 'Tract2010') %>%
  mutate(incidnt_per_person = num_of_incidnt / Pop2010) %>%
  select(-num_of_incidnt) %>%
  ungroup()

crime_census$Category = gsub('[^a-z0-9]+', '_', tolower(crime_census$Category))

# reshape to wide
crime_census_wide = dcast(crime_census, Tract2010 + Pop2010 ~ Category)
crime_census_wide[is.na(crime_census_wide)] = 0

# merge with alcohol data
alcohol = read.csv('data/counts_census_by_alcohol_license_melted.csv')
alcohol$Tract2010 = as.integer(gsub('Census Tract: |\\.', '', alcohol$Census_tra))
alcohol = alcohol %>%
  filter(!is.na(Tract2010)) %>%
  select(Tract2010, License_Nu, n_stores) %>%
  dcast(Tract2010 ~ License_Nu)
alcohol[is.na(alcohol)] = 0

crime_census_alcohol = crime_census_wide %>%
  left_join(alcohol, by = 'Tract2010')
crime_census_alcohol[is.na(crime_census_alcohol)] = 0

write.csv(crime_census_alcohol, file = 'output/crime_census_alcohol.csv', row.names = F)
save(crime_census_alcohol, file = 'output/crime_census_alcohol.rda')
