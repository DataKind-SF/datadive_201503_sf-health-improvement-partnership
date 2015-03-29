library(dplyr)
library(reshape2)
options(stringsAsFactors = F)

# load census tract data
census = read.csv('data/census_tract_demographics.csv')
census = census %>%
  mutate(white = white_cnt / (white_cnt+black_cnt+asian_cnt+other_cnt_+hispanic_c),
         black = black_cnt / (white_cnt+black_cnt+asian_cnt+other_cnt_+hispanic_c),
         asian = asian_cnt / (white_cnt+black_cnt+asian_cnt+other_cnt_+hispanic_c),
         hispanic = hispanic_c / (white_cnt+black_cnt+asian_cnt+other_cnt_+hispanic_c)
         ) %>%
  select(Id, Tract2010, Pop2010, white, black, asian, hispanic, med_income, Unemploy_p)

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
crime_census$Category = paste('crime', crime_census$Category, sep = '_')

# reshape to wide
crime_census_wide = dcast(crime_census, 
                          Id + Tract2010 + Pop2010 + white + black + asian + hispanic + med_income + Unemploy_p ~ Category)
crime_census_wide[is.na(crime_census_wide)] = 0

# merge with alcohol data
alcohol = read.csv('data/counts_census_by_alcohol_license_melted.csv')
alcohol = alcohol %>%
  rename(Tract2010 = Census_tra) %>%
  filter(!is.na(Tract2010)) %>%
  mutate(license = paste('license', License_Ty, sep = '_'))

# merge with census
alcohol_census = alcohol %>%
  inner_join(select(census, Tract2010, Pop2010), by = 'Tract2010') %>%
  mutate(num_stores_per_person = n_stores / Pop2010) %>%
  select(Tract2010, license, num_stores_per_person) %>%
  dcast(Tract2010 ~ license)
alcohol[is.na(alcohol)] = 0

crime_census_alcohol = crime_census_wide %>%
  left_join(alcohol_census, by = 'Tract2010')
crime_census_alcohol[is.na(crime_census_alcohol)] = 0

write.csv(crime_census_alcohol, file = 'output/crime_census_alcohol.csv', row.names = F)
save(crime_census_alcohol, file = 'output/crime_census_alcohol.rda')
