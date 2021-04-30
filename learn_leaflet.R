# Learn Leaflet

library(leaflet)
library(leafem)
library(mapview)

# Create the map ####

my_map <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=-1.6178, lat=54.9783,  popup="World's most important city!")
# Be careful of different coordinate systems - different projections

my_map  # Display the map in Viewer window
# This map is dynamic - can pan and zoom etc 

# Multiple backdrop maps ####

# Modify the transparency so more than one can be seen at a time

# This shows the satellite map with the roads and road names overlaid
leaflet() %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addProviderTiles(providers$Stamen.TonerLines,
                   options = providerTileOptions(opacity = 0.5)) %>%
  addProviderTiles(providers$Stamen.TonerLabels) %>% 
  addMarkers(lng=-1.6178, lat=54.9783, popup="World's most important city!")

# Changing marker symbols ####

leaflet() %>%
  addTiles() %>%  
  addCircleMarkers(lng=-1.6178, lat=54.9783, # Adds a marker to the city centre
                   popup="The world's most important city!",
                   radius = 5, color = "red")


# London and Newcastle with markers proportional to their populations
leaflet() %>%
  addTiles() %>%  
  addCircleMarkers(lng=-0.1278, lat=51.5074, # Adds a marker to the city centre
                   popup="London",
                   radius = 5, color = "blue") %>% # London has blue marker
  addCircleMarkers(lng=-1.6178, lat=54.9783,
                   popup="Newcastle",
                   radius = (270000/8000000)*5, color = "red") # Ncl has red marker
# Newcastle population is 270,000 , London is 8,000,000

# Use 'label =' to enable editing of the size of text etc 
leaflet() %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addProviderTiles(providers$Stamen.TonerLines,
                   options = providerTileOptions(opacity = 0.5)) %>%
  addProviderTiles(providers$Stamen.TonerLabels) %>% 
  addCircleMarkers(lng=-1.6178, lat=54.9783,
                   label="Newcastle population 270k",
                   labelOptions = labelOptions(textsize = "25px"))

