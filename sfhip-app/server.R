server <- function(input, output) {  
  output$map <- renderPlot({
    p_theme <- theme(axis.line=element_blank(), axis.text.x=element_blank(),
                     axis.text.y=element_blank(), axis.ticks=element_blank(),
                     axis.title.x=element_blank(), axis.title.y=element_blank(),
                     plot.margin = unit(c(0,0,0,0), "cm"),
                     # legend.position="none",
                     panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
                     panel.grid.minor=element_blank(),plot.background=element_blank()
    )
    # Set up map
    map <- get_map(location = c(lon = mean(df_alcohol$X),
                                lat = mean(df_alcohol$Y)),
                   maptype = "roadmap", source = "google", zoom = 12)
    p <- ggmap(map, 
               base_layer = ggplot(data = df_censustracts_proc, 
                                   aes(x = long, y = lat))) + 
      scale_x_continuous(limits = c(-122.52, -122.36)) +
      scale_y_continuous(limits = c(37.708, 37.835)) + 
      xlab("") + ylab("") + p_theme
    # Plot chloropeth regions
    if (input$select_plot_category != "Please select") {
      p <- p + geom_polygon(aes_string(group = "group", fill = input$select_plot_category),
                            colour = "white", alpha = 0.4, size = 0.3) +
        scale_fill_distiller(palette = "Blues", name = input$select_plot_category,
                             breaks = pretty_breaks(n = 5))
    }
    # Plot crime density
    if (input$select_crime_categories != "Please select") {
      select_df_crime <- df_crime$Category %in% input$select_crime_categories &
        df_crime$Date >= as.POSIXct(input$dates_range[1], format = "%Y-%m-%d") & 
        df_crime$Date <= as.POSIXct(input$dates_range[2], format = "%Y-%m-%d") 
      p <- p + 
        stat_density2d(data = df_crime[select_df_crime, ],
                       aes(x = Longitude, y = Latitude, fill = ..level.., alpha = ..level..),
                       size = 2, bins = 10, geom = "polygon") +
        scale_fill_distiller(palette = "YlOrRd", name = input$select_crime_categories, 
                             breaks = pretty_breaks(n = 5))
    }
    # Plot alcohol establishments
    select_df_alcohol <- df_alcohol$Premise_Type %in% input$select_onoff &
      df_alcohol$Orig_Iss_Date >= as.POSIXct(input$dates_range[1], format = "%Y-%m-%d") & 
      df_alcohol$Orig_Iss_Date <= as.POSIXct(input$dates_range[2], format = "%Y-%m-%d") 
    p <- p + geom_point(data = df_alcohol[select_df_alcohol, ], 
               aes(x = X, y = Y, shape = Premise_Type), alpha = 0.5) +
      scale_shape_discrete(name = "Establishment type")
    # Plot centroids
    if (!any(input$select_centroids == "Please select")) {
      select_df_crime_centroids <- df_crime_centroids$Category %in% input$select_centroids
      p <- p + 
        geom_point(data = df_crime_centroids[select_df_crime_centroids, ], 
                   aes(x = Longitude, y = Latitude, colour = Category), 
                   shape = 9, size = 4) + # or shape = 9
        scale_colour_discrete(name = "Crime type (centroids)")
    }
    print(p)
  })
}
