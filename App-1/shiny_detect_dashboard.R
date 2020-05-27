
#Packages ----
library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(DT)

#Datasets ----
gift_card <- read.csv("data/Gift Card.csv")
call_log <- read.csv("data/Participant Call Log.csv")

call_log <- call_log %>% 
  mutate(
    # Change classes
    call_date            = as.Date(CallDate, "%m/%d/%Y")
  )

#Define User Interface ----
ui <- fluidPage(
  
  titlePanel("DETECT Recruitment Dashboard"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      selectInput("main_select", 
                  label = "What would you like to see?",
                  choices = list("Call Log" = 1)),
      
      br(),
      
      dateRangeInput('date_range',
                     label = 'Select date range (inclusive): yyyy-mm-dd',
                     start = min(call_log$call_date), end = Sys.Date()
      )
      
      
    ),
    
    mainPanel(
      
      "Table",
                 br(),
                 textOutput("selected_dates"),
                 br(),
                 tableOutput("table"))
        
      )
      
    )
    
  
  

  


# Define server logic ----
server <- function(input, output) {
  
  call_log_reactive <- reactive({
    call_log %>% 
      filter(call_date >= input$date_range[1] & call_date <= input$date_range[2])
  })
  
  output$selected_dates <- renderText({
    paste(as.character(input$selected_dates), collapse = " to ")
    })
  
  output$table <- DT::renderDataTable(
    call_log_reactive()
  )
  
}

# Run the app ----
shinyApp(ui = ui, server = server)