# Basic layout

library(shiny)

# read in relevant data
wfarm <- base64enc::dataURI(file="www/UKwindfarm.png", mime="image/png") # image
habitats <- read.csv("www/habitats.csv")

# Define UI ####
ui <- fluidPage(
  titlePanel("Windfarm in Cumbria"),
  
  # Sidebar with buttons
  sidebarLayout(
  sidebarPanel("MySidebar",
               # Checkboxes - radioButtons
                 radioButtons(inputId = "my_checkgroup", 
                                    h3("Select a habitat"), 
                                    choices = list("Woodland" = 1, 
                                                   "Grassland" = 2, 
                                                   "Urban" = 3),
                                    selected = 1),
               sliderInput(inputId = "bins",
                           h3("Number of bins"),
                           min = 4, 
                           max = 50,
                           value = 8)
    ),  
  
  # Main panel with text and images
  mainPanel(
    h1("Main heading"),
    h2("Subheading"),
    p("This will be to help planners assess potential windfarm", 
      "development areas in Cumbria, and achieve a ", strong("balance "),
      "between different", em("interest groups"), "and other users."),
    img(src=wfarm),
    plotOutput(outputId = "habitats_plot")
)
)
)
# Define server logic ####
# Server takes info from buttons/sliders in UI and displays them
server <- function(input, output) {
  
  # creating a histogram
  output$habitats_plot <- renderPlot({
    
    # Generate bins from UI
    bins <- seq(min(habitats), max(habitats), length.out = input$bins + 1)
    # Output depends on which radioButton is selected
    hist(habitats[, as.numeric(input$my_checkgroup)], breaks = bins,
         main = "Habitat histogram",
         xlab = "Edited x label",
         ylab = "Edited y label",
         col = "red", border = NULL)
  })
}

# Run the app ####
shinyApp(ui = ui, server = server)
