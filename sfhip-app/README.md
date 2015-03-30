sfhip-app
======
### About
sfhip-app is a working prototype of an interactive data visualization web tool created for the [San Francisco Health Improvement Partnership (SFHIP)](http://www.sfhip.org/) that allows users to explore data on alcohol licenses and crime in the city of San Francisco. The tool is available live at [http://bit.ly/sf-hip-viz-tool](https://jrnew.shinyapps.io/sfhip-app). This was built in a day for the [DataKind San Francisco](http://www.datakind.org/howitworks/datachapters/datakind-sf/) DataDive on Mar 27 to 29, 2015 in R with the Shiny package.

### Data
Data sets used for sfhip-app are is available from SFHIP, the US Census Bureau [American Community Survey](http://www.census.gov/acs/www/) and the San Francisco Police Department. Crime rate data aggregated to the census tract (based on the 2010 US Census) level was provided by Kris Sankaran, while [Bill Chambers](http://billchambers.me/) did the k-means clustering analysis to identify geographical cluster centroids of establishments with alcohol licenses and crime incidents.

### Disclaimer
This tool is only a first step towards the final goal of a full-fledged interactive data visualization with real-time (or as real-time as possible) updates of various data sources. We would advise against drawing any conclusions from the tool at this point as it is still pending more rigorous data cleaning and analysis as well as bug fixes.

### Maintainers
Jin Rou (JR) New [http://www.github.com/jrnew](http://www.github.com/jrnew)
