header <- dashboardHeader(title = "SFHIP")

sidebar <- dashboardSidebar(
  disable = TRUE)

# sidebar <- dashboardSidebar(
#   sidebarMenu(
#     id = "tabs", # Setting id makes input$tabs give the tabName of currently-selected tab
#     # menuItem("Overview", tabName = "overview", icon = icon("th")),
#     menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
#   )
# )

body <- dashboardBody(
#   tabItems(
#     # Overview tab
#     tabItem(tabName = "overview",
#             h3("Overview of data tool")
#     ), 
    # Dashboard tab
#     tabItem(tabName = "dashboard",
            fluidRow(
              box(width = 9,
                  plotOutput("map", height = 500, width = 650)),
              box(title = "Plot options", width = 3,
                  status = "primary",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  # sliderInput("dates_range", "Dates:", 
                  #             min = 2010, max = 2013, value = c(2010, 2013), step = 1, sep = ""),
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
                  # checkboxGroupInput("select_crime_categories", 
                  #                    label = "Crime type (density)", 
                  #                    choices = crime_categories),
                  checkboxGroupInput("select_centroids", 
                                     label = "Crime type (centroids)", 
                                     choices = crime_categories_and_alcohol,
                                     selected = "Please select"))
            )
#     )
#   )
)


dashboardPage(header, sidebar, body)