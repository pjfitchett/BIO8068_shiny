# Basic layout

library(shiny)

# Define UI ####
ui <- fluidPage(
  titlePanel("title panel"),
  
  sidebarLayout(
    sidebarPanel("sidebar panel"),
    mainPanel("main panel")
  ),
  mainPanel(
    h1("This is the main heading for my app"),
    h2("here is a subheading")
)
)

# Define server logic ####
server <- function(input, output) {
  
}

# Run the app ####
shinyApp(ui = ui, server = server)
