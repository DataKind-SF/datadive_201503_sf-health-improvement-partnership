#! /usr/bin/env Rscript

# File description -------------------------------------------------------------
# 
#

# Setup packages ---------------------------------------------------------------
# List of packages for session
.packages = c("plyr", 
              "data.table", 
              "dplyr",
              "reshape2"
              ) 

# Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])

# Load packages into session 
lapply(.packages, require, character.only=TRUE)
cat("\014")  # Clear console

# Create a table of counts with census tracts as rows, license types as columns ----
alcohol <- read.csv("data/processed_data/alcohol_licenses_locations.csv")
alcohol <- data.table(alcohol)

census_by_license <- group_by(alcohol, Census_tra, License_Nu)

malcohol_table <- summarise(census_by_license, n_stores=n())
alcohol_table <- dcast(malcohol_table, formula=License_Nu~Census_tra, value=n_stores)
alcohol_table[is.na(alcohol_table)] <- 0

write.csv(malcohol_table, file="data/processed_data/counts_census_by_alcohol_license_melted.csv")
write.csv(alcohol_table, file="data/processed_data/counts_census_by_alcohol_license.csv")
