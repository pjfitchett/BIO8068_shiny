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
                 h3("a button"),
               # Submit button
                 actionButton(inputId="my_submitstatus",
                              label="Submit"),
               # Checkboxes - radioButtons
                 radioButtons(inputId = "my_checkgroup", 
                                    h3("Select a habitat"), 
                                    choices = list("Woodland" = 1, 
                                                   "Grassland" = 2, 
                                                   "Urban" = 3),
                                    selected = 1)
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
  output$habitats_plot <- renderPlot(
    # Output depends on which radioButton is selected
    hist(habitats[, as.numeric(input$my_checkgroup)])
  )
}

# Run the app ####
shinyApp(ui = ui, server = server)
