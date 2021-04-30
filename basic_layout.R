# Basic layout

library(shiny)

# read in the image of the windfarm
wfarm <- base64enc::dataURI(file="www/UKwindfarm.png", mime="image/png")

# Define UI ####
ui <- fluidPage(
  titlePanel("title panel"),
  
  sidebarLayout(
  sidebarPanel("MySidebar",
                 h3("a button"),
                 actionButton(inputId="my_submitstatus",
                              label="Submit"),
                 radioButtons(inputId = "habitat_checkbox", 
                                    h3("Select a habitat"), 
                                    choices = list("Woodland" = 1, 
                                                   "Grassland" = 2, 
                                                   "Urban" = 3),
                                    selected = 1)
    ),  
  
  mainPanel(
    h1("Main heading"),
    h2("Subheading"),
    p("This will be to help planners assess potential windfarm", 
      "development areas in Cumbria, and achieve a ", strong("balance "),
      "between different", em("interest groups"), "and other users."),
    img(src=wfarm)
)
)
)
# Define server logic ####
server <- function(input, output) {
  
}

# Run the app ####
shinyApp(ui = ui, server = server)
