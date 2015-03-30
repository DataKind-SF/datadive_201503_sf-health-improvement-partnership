#----------------------------------------------------------------------
# ui.R
# User interface for app
# JR New, 2015
#----------------------------------------------------------------------
header <- dashboardHeader(title = "SFHIP")

# sidebar <- dashboardSidebar(
#   disable = TRUE)

sidebar <- dashboardSidebar(
  sidebarMenu(
    id = "tabs", # Setting id makes input$tabs give the tabName of currently-selected tab
    menuItem("Overview", tabName = "about", icon = icon("info")),
    menuItem("Visualization", tabName = "viz", icon = icon("dashboard"))
  )
)

boxAbout <- source("about.R")$value
body <- dashboardBody(
  tabItems(
    # Overview tab
    tabItem(tabName = "about",
            boxAbout()
    ), 
    # Dashboard tab
    tabItem(tabName = "viz",
            fluidRow(
              box(width = 9,
                  plotOutput("map", height = 500, width = 650)),
              box(title = "Plot options", width = 3,
                  status = "info", solidHeader = TRUE,
                  collapsible = TRUE,
                  dateRangeInput("dates_range", "Date range",
                                 start = "2010-01-01", end = "2013-12-31",
                                 min = "2010-01-01", max = "2013-12-31"),
                  checkboxGroupInput("select_onoff", 
                                     label = "Establishment type", 
                                     choices = onoff_categories,
                                     selected = c("On-sale", "Off-sale")),
                  selectInput("select_plot_category", 
                              label = "License/crime rate", 
                              choices = plotcategories),
                  selectInput("select_crime_categories", 
                              label = "Crime type (density)", 
                              choices = crime_categories),
                  checkboxGroupInput("select_centroids", 
                                     label = "Crime type (centroids)", 
                                     choices = crime_categories_and_alcohol,
                                     selected = "Please select"))
            )
    )
  )
)

dashboardPage(header, sidebar, body)
