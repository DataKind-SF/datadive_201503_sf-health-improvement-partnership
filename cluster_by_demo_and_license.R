library(dplyr)
library(reshape2)
library(ggplot2)
library(rgdal)
library(maptools)
options(stringsAsFactors = F)

load('output/crime_census_alcohol.rda')

# check out dimension
summary(crime_census_alcohol)

# transform variables
crime_census_alcohol$med_income = (crime_census_alcohol$med_income - min(crime_census_alcohol$med_income)) /
  (max(crime_census_alcohol$med_income) - min(crime_census_alcohol$med_income))
crime_census_alcohol$Unemploy_p = crime_census_alcohol$Unemploy_p / 100

# check out small populations
hist(crime_census_alcohol$Pop2010)
summary(crime_census_alcohol$Pop2010[crime_census_alcohol$Pop2010 < 2000])

# throw out tracts with populations less than 500
crime_census_alcohol = subset(crime_census_alcohol, Pop2010 >= 500)

# k-means clustering
names(crime_census_alcohol)[3:8] = paste('demo', tolower(names(crime_census_alcohol)[3:8]), sep = '_')
census_alcohol = crime_census_alcohol %>%
  select(starts_with('demo'), starts_with('license'))

do_kmeans = function(dat, k) {
  model = kmeans(dat, k)
  
  kmeans_result = list()
  kmeans_result$within = model$tot.withinss
  kmeans_result$between = model$betweenss
  kmeans_result$cluster = model$cluster
  
  kmeans_result
}

kmeans_results = lapply(1:40, function(x) do_kmeans(census_alcohol, x))

# plot results
kmeans_dists = data.frame(
    k = 1:40,
    within = sapply(kmeans_results, function(x) x$within),
    between = sapply(kmeans_results, function(x) x$between)
  )
kmeans_dists_long = melt(kmeans_dists, id = 'k')
kmeans_dists_plot =
  ggplot(kmeans_dists_long, aes(x = k, y = value, colour = variable)) +
  geom_line()

# 20 appears to be a good number of clusters
crime_census_alcohol$cluster = kmeans_results[[20]]$cluster

# pick alcohol-related crimes
relevant_crimes = 'arson|assault|burglary|disorderly_conduct|driving_under_the_influence|drunkenness|liquor_laws|prostitution|robbery|sex_offenses|vandalism'

# calculate aggregate crime rate
crime_census_alcohol = crime_census_alcohol %>%
  select(Tract2010, Pop2010, starts_with('demo'), starts_with('license'), cluster) %>%
  cbind(crime_census_alcohol[names(crime_census_alcohol)[grep(relevant_crimes, names(crime_census_alcohol))]])

crime_census_alcohol$agg_crime = rowSums(crime_census_alcohol[names(crime_census_alcohol)[grep('crime', names(crime_census_alcohol))]])

# calculate the variance of crimes within each cluster
crime_per_cluster = crime_census_alcohol %>%
  group_by(cluster) %>%
  summarise(agg_crime_var = var(agg_crime))

write.csv(crime_census_alcohol, file = 'output/crime_census_alcohol.csv', row.names = F)
write.csv(crime_per_cluster, file = 'output/crime_per_cluster.csv', row.names = F)
