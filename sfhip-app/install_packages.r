# Setup packages ---------------------------------------------------------------
# List of packages for session
.packages = c("shiny", 
              "dplyr",
              "ggplot2",
              "scales",
              "grid",
              "ggmap") 
devtools::install_github("rstudio/shinydashboard")
# Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])

# Load packages into session 
lapply(.packages, require, character.only=TRUE)
cat("\014")  # Clear console
