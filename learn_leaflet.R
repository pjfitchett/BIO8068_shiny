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

# Vector maps and leaflet ####

library(sf)

# st_read part of sf package 
nafferton_fields <- st_read("www/naff_fields/naff_fields.shp")
# data originally from GRASS GIS 
st_crs(nafferton_fields) # show projection system
# DATUM is OSGB 1936 but ESPG is not the usual 27700 - to be transformed

# First reset nafferton fields to OS 27700
nafferton_fields <- nafferton_fields %>% 
  st_set_crs(27700) %>% 
  st_transform(27700)

# Transform to latitude longitude
nafferton_fields_ll <- st_transform(nafferton_fields, 4326) # Lat-Lon

# Can plot the data directly with plot()
plot(nafferton_fields)
# Plot a single map
plot(nafferton_fields[, 1])

# Displaying the map in leaflet using latlong
leaflet() %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addFeatures(nafferton_fields_ll)
# Can zoom and pan with this map

# Displaying subsets of vector data
leaflet() %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addFeatures(nafferton_fields_ll[nafferton_fields_ll$Farm_Meth=="Organic",],
              fillColor = "blue",  
              color = "white",
              opacity = 0.7,
              fillOpacity = 0.4) %>%
  addFeatures(nafferton_fields_ll[nafferton_fields_ll$Farm_Meth=="Conventional",],
              fillColor = "red",
              color = "white",
              opacity = 0.7,
              fillOpacity = 0.4)

# Continuous colour options

# Need to decide how to split the continuous variable up into categorical "bins"
# Then use colorBin to apply a colour pallette

summary(nafferton_fields)
# Area varies from 12189 to 200919
hist(nafferton_fields$Area_m) # basic histogram

library(ggplot2)
ggplot(nafferton_fields) +
  geom_histogram(aes(Area_m),
                 binwidth = 25000,
                 color = "blue",
                 fill = "blue") +
  labs(x = "Area", y = "Number")

# Colouring the continuous variable on the map

# Set the bins to divide up your areas
bins <- c(0, 25000, 50000, 75000, 100000, 125000, 150000, 175000, 200000, 225000)

# Decide on the colour palatte
pal <- colorBin(palette = "Greens", domain = bins)

# Create the map
leaflet() %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addFeatures(nafferton_fields_ll,
              fillColor = ~pal(nafferton_fields_ll$Area_m),
              fillOpacity = 1)

pal2 <- colorQuantile(palette = "Greens", domain = bins, n = 6)

leaflet() %>%
  addProviderTiles(providers$Esri.WorldImagery) %>%
  addFeatures(nafferton_fields_ll,
              fillColor = ~pal2(nafferton_fields_ll$Area_m),
              fillOpacity = 1)


pal <- colorNumeric(palette = "Greens", domain = bins)

# Now leaflet is called with nafferton_fields_ll
leaflet(nafferton_fields_ll) %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addFeatures(fillColor = ~pal(Area_m),
              fillOpacity = 1) %>% 
  addLegend("bottomright",
            pal = pal,
            values = ~Area_m,
            title = "Field area",
            labFormat = labelFormat(suffix = " m^2"),
            opacity = 1)

# Highlight and popups ####

# Individual polygons can be highlighted by mousing over them
leaflet(nafferton_fields_ll) %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addFeatures(fillColor = ~pal(Area_m),
              fillOpacity = 1,
              # Add the highlight option
              highlightOptions = highlightOptions(color = "yellow",
                                                  weight = 5,
                                                  bringToFront = TRUE)) %>% 
  addLegend("bottomright",
            pal = pal,
            values = ~Area_m,
            title = "Field area",
            labFormat = labelFormat(suffix = " m^2"),
            opacity = 1)

# Can add a popup to display additional info 
field_info <- paste("Method: ", nafferton_fields_ll$Farm_Meth,
                    "<br>",
                    "Crop: ", nafferton_fields_ll$Crop_2010)

# Add popup to map


# Interactive control of foreground and background maps ####

# Gives the user the choice of Open StreetMap or satellite
leaflet() %>% 
  addTiles(group = "OSM (default)") %>% 
  addProviderTiles(providers$Esri.WorldImagery,
                   group = "Satellite") %>% 
  addLayersControl( # choice is here
    baseGroups = c("OSM (default)", "Satellite")
  ) %>% # add the focus to NE England
  setView(lat = 54.9857, lng=-1.8990, zoom=10)

# Add the overlay map for Nafferton farm
leaflet() %>% 
  addTiles(group = "OSM (default)") %>% 
  addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>% 
  addFeatures(nafferton_fields_ll, group = "Nafferton Farm") %>% 
  addLayersControl(
    baseGroups = c("OSM (default)", "Satellite"), 
    overlayGroups = "Nafferton Farm", # can select/unselect this layer
    options = layersControlOptions(collapsed = FALSE)
  )

