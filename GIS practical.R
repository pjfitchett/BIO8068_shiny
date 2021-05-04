# GIS practical

library(sf)
library(raster)
library(mapview)
# Prevent warnings 
options("rgdal_show_exportToProj4_warnings"="none")

# Display elevation data - contours and shading

# Import raster elevation data Ordnance Survey projection
pan50m <- raster("gis_data/pan50m.tif")
plot(pan50m)

# Colours are wrong way round - use terrain.colors to set low to green and high 
# to brown with 30 colour categories

plot(pan50m, col=terrain.colors(30))
# this uses the OS projection system

# Convert to lat long so this can be used with other maps
ll_crs <- CRS("+init=epsg:4326")  # 4326 is the code for latitude longitude
pan50m_ll <- projectRaster(pan50m, crs=ll_crs)
mapview(pan50m_ll) # can zoom/pan etc 

# Create a hillshade map from elevation data 
# This highlights the structure of the elevation if caught by sunlight
hs = hillShade(slope = terrain(pan50m, "slope"), aspect = terrain(pan50m, "aspect"))
plot(hs, col = gray(0:100 / 100), legend = FALSE)
# overlay with DEM
plot(pan50m, col = terrain.colors(25), alpha = 0.5, add = TRUE)

# Creation of contours from raster DTM - rasterToContour
pan_contours <- rasterToContour(pan50m) %>% st_as_sf()
plot(pan50m)
plot(pan_contours, add=TRUE)

# Add DTM-derived information to site data ####

# Read in the wind_turbines.shp file
wind_turbines <- st_read("gis_data/wind_turbines.shp")

print(wind_turbines)

plot(pan50m)
# Add the turbines to the map
plot(wind_turbines["WF_Name"], add = TRUE)

# Create a latlong version of the windfarm data to use in mapview
wind_turbines_ll <- st_transform(wind_turbines, 4326)
mapview(wind_turbines_ll)
# Can click on each turbine for more info

# Calculate slope and aspect

dem_slope  <- terrain(pan50m, unit="degrees") # defaults to slope
dem_aspect <- terrain(pan50m, opt="aspect", unit="degrees")
plot(dem_slope)
plot(dem_aspect)

# Add slope and aspect to wind turbines attributes

# Transfer info from dem_slope and dem_aspect to new columns in wind_turbines
wind_turbines$slope <- extract(dem_slope, wind_turbines)
wind_turbines$aspect <- extract(dem_slope, wind_turbines)

print(wind_turbines, n=10) # shows new columns

# Create a viewshed ####

source("shiny_LOS/LOS.R")

# Viewshed for western area

# Display wind turbines as ll in mapview 
mapview(wind_turbines_ll)
# Select a turbine - CC7 

west_windfarm <- dplyr::filter(wind_turbines, Turb_ID == "CC7")

# Change to coarser 500m elevation map for speed
pan500m <- aggregate(pan50m, fact=5) # fact=5 is the number of cells aggregated together

# Extract just the geometry for a single mast, and pass to viewshed function.
# Adding a 5km maximum radius
# Takes 1 to 2 minutes to run viewshed depending on your PC
west_windfarm_geom <- st_geometry(west_windfarm)[[1]]
west_viewshed <- viewshed(dem=pan500m, windfarm=west_windfarm_geom,
                          h1=1.5, h2=49, radius=5000)

# Display map
plot(pan500m)
# Display viewshed
plot(west_viewshed, add=TRUE, legend=FALSE, col="red")

# Viewshed for eastern area

# Select a turbine from the mapview again 
mapview(wind_turbines_ll)

# Get the OM7 turbine
east_windfarm <- dplyr::filter(wind_turbines, Turb_ID == "OM7")

# Extract geometry and calculate viewshed
east_windfarm_geom <- st_geometry(east_windfarm)[[1]]
east_viewshed <- viewshed(dem=pan500m, windfarm=east_windfarm_geom,
                          h1=1.5, h2=54, radius=5000)

# Display results
plot(pan500m)
plot(west_viewshed, add=TRUE, legend=FALSE, col="red")
plot(east_viewshed, add=TRUE, legend=FALSE, col="blue")

# Merge east and west viewsheds into a single map

# Need to ensure they have the same extent - reset to full elevation map
west_viewshed <- extend(west_viewshed, pan500m) # could use 50m
east_viewshed <- extend(east_viewshed, pan500m)
both_viewshed <- merge(west_viewshed, east_viewshed)
plot(pan500m, col=terrain.colors(25))
plot(both_viewshed, legend=FALSE, add=TRUE, col="red")

# Which settlements can see the viewshed?

# Import the map of settlements
settlements <- st_read("gis_data/settlements.shp")

# Convert to latlong
settlements_ll <- st_transform(settlements, 4326)
mapview(settlements_ll)

# Convert viewshed map into polygon map
both_viewshed_poly <- rasterToPolygons(both_viewshed) %>% st_as_sf()
plot(both_viewshed_poly)
print(both_viewshed_poly, n=5)
# Shows each raster cell has been turned into its own polygon - >800 entries

# Dissolve viewshed polygons into a single polygon
library(rgeos)
both_viewshed_poly <- rasterToPolygons(both_viewshed, dissolve=TRUE) %>% st_as_sf()
plot(both_viewshed_poly)
print(both_viewshed_poly, n=5)
# Shows only 1 polygon (multipolygon)

# Clip the settlements map with the dissolved viewshed map
# Only keep features where both occur

# Need to convert coordinate system
both_viewshed_poly <- st_transform(both_viewshed_poly, 27700)
settlements_my_viewshed <- st_intersection(settlements, both_viewshed_poly)
print(settlements_my_viewshed)
plot(settlements_my_viewshed)
mapview(settlements_my_viewshed)


