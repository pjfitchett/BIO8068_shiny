# Integrating leaflet with shiny 

library(shiny)
library(leaflet)
library(leafem)

# Define UI ####
ui <- fluidPage(
  
  # Title
  titlePanel("Nafferton Farm"),
  
  # Adding the map to the main panel (placement)
  mainPanel(
    leafletOutput(outputId = "nafferton_map")
  )
  
)

# Define server logic ####
server <- function(input, output) {
  # Code for the map above goes here
  output$nafferton_map <- renderLeaflet({
    leaflet() %>% 
      addTiles(group = "OSM (default)") %>% 
      addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>% 
      addFeatures(nafferton_fields_ll, group = c("Organic", "Conventional")) %>% 
      addLayersControl(
        baseGroups = c("OSM (default)", "Satellite"), 
        overlayGroups = c("Organic", "Conventional"), # can select/unselect this layer
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  # The below will print the coords in the console when clicked
  # Could then be manipulated to control another function
    observeEvent(input$nafferton_map_click, {
      click<-input$nafferton_map_click
      text<-paste("Lattitude ", click$lat, "Longtitude ",
                  click$lng)
      print(text)
    })
  
}

# Run the app ####
shinyApp(ui = ui, server = server)
