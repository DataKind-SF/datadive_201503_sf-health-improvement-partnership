rm(list = ls())
# (Run the following lines if this is the first time you are using runapp.R.)
# pkgs <- c("shiny", "devtools",
#           "dplyr", "ggplot2", "ggmap", "scales", "grid")
# install.packages(pkgs, repos = "http://cran.r-project.org")
# sapply(pkgs, library, character.only = T)
# devtools::install_github("rstudio/shinydashboard")
# devtools::install_github("rstudio/shinyapps")

# To view app in browser
library(shiny)
work_dir <- "~/Copy/sfhip"
setwd(work_dir)
runApp(getwd(), port = 1234)

# To deploy app to web
setwd("~/Copy/sfhip-app")
library(shinyapps)
### CHANGE!!!
name <- "username"
token <- "shinytoken"
secret <- "shinysecret"
shinyapps::setAccountInfo(name = name, token = token, secret = secret)
# sessionInfo()
options(shinyapps.http.trace = TRUE) # for log to trace error
deployApp()
Y
shinyapps::showLogs()
#----------------------------------------------------------------------
# End
#----------------------------------------------------------------------

