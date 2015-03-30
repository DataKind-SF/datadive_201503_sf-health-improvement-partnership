# Combine cluster_outputs from Bill
cluster_file_dir <- "processed_data/cluster_outputs"
cluster_files <- list.files(cluster_file_dir)
df_cluster_all <- read.csv(file.path(cluster_file_dir, cluster_files[1]))
df_cluster_all$Category <- strsplit(cluster_files[1], split = "_")[[1]][1]
for (file in cluster_files[-1]) {
  df_cluster <- read.csv(file.path(cluster_file_dir, file))
  df_cluster$Category <- strsplit(file, split = "_")[[1]][1]
  df_cluster_all <- rbind(df_cluster_all, df_cluster)
}
names(df_cluster_all) <- c("Longitude", "Latitude", "Category")
df_cluster_all$Category[df_cluster_all$Category == "liquor"] <- "ALCOHOL STORES"
table(df_cluster_all$Category)
write.csv(df_cluster_all, file = "processed_data/crime_centroids.csv", row.names = FALSE)
