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
names(crime_census_alcohol)[4:9] = paste('demo', tolower(names(crime_census_alcohol)[4:9]), sep = '_')
census_alcohol = crime_census_alcohol %>%
  select(starts_with('demo'), starts_with('license'))

do_kmeans = function(dat, k, seed) {
  set.seed(seed)
  model = kmeans(dat, k)
  
  kmeans_result = list()
  kmeans_result$within = model$tot.withinss
  kmeans_result$between = model$betweenss
  kmeans_result$cluster = model$cluster
  
  kmeans_result
}

kmeans_results = lapply(1:40, function(x) do_kmeans(census_alcohol, x, 123456))

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
  select(Id, Tract2010, Pop2010, starts_with('demo'), starts_with('license'), cluster) %>%
  cbind(crime_census_alcohol[names(crime_census_alcohol)[grep(relevant_crimes, names(crime_census_alcohol))]])

crime_census_alcohol$agg_crime = rowSums(crime_census_alcohol[names(crime_census_alcohol)[grep('crime', names(crime_census_alcohol))]])

# calculate the variance of crimes within each cluster
crime_per_cluster = crime_census_alcohol %>%
  group_by(cluster) %>%
  summarise(agg_crime_var = var(agg_crime))

crime_census_alcohol = crime_census_alcohol %>%
  left_join(crime_per_cluster, by = 'cluster') %>%
  tbl_df()

write.csv(crime_census_alcohol, file = 'output/crime_census_alcohol.csv', row.names = F)
write.csv(crime_per_cluster, file = 'output/crime_per_cluster.csv', row.names = F)

# make maps
tract = readOGR(dsn = "data/gz_2010_06_140_00_500k", layer = "gz_2010_06_140_00_500k")
tract = fortify(tract, region="GEO_ID")
tract = select(tract, long, lat, group, order, id)

crime_census_alcohol = crime_census_alcohol %>%
  left_join(tract, by = c('Id' = 'id'))

plot_data = subset(crime_census_alcohol, lat < 37.85)
cluster_label = plot_data %>%
  group_by(cluster, Tract2010) %>%
  summarise(avg_long = mean(long), avg_lat = mean(lat))

cluster_plot = 
  ggplot() +
  geom_polygon(data = plot_data, 
               aes(x = long, y = lat, group = group, fill = factor(cluster)), 
               color = 'black', size = 0.25) +
  geom_text(data = cluster_label, aes(avg_long, avg_lat, label = cluster), size = 3) +
  scale_x_continuous('') + scale_y_continuous('') +
  ggtitle('Geographic locations of clusters') +
  theme(legend.position = 'none', panel.background = element_blank(), panel.border = element_blank())

avg_crime_plot = 
  ggplot() +
  geom_polygon(data = plot_data, 
               aes(x = long, y = lat, group = group, fill = agg_crime), 
               color = 'black', size = 0.25) +
  scale_fill_gradient(name = 'Average incidence per person', low = '#dadaeb', high = '#3f007d') +
  geom_text(data = cluster_label, aes(avg_long, avg_lat, label = cluster), size = 3) +
  scale_x_continuous('') + scale_y_continuous('') +
  ggtitle('Alcohol-related incidence\nper person and per tract') +
  theme(legend.position = 'bottom', panel.background = element_blank(), panel.border = element_blank())

cluster_plots = list(cluster_plot, avg_crime_plot)
save(cluster_plots, file = 'output/cluster_plots.rda')
ggsave(cluster_plot, file = 'output/cluster_plot_1.png', width = 6, height = 6, dpi = 1000)
ggsave(avg_crime_plot, file = 'output/cluster_plot_2.png', width = 6, height = 7.3, dpi = 1000)
