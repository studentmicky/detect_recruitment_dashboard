
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
                  choices = c("Call Log", "Gift Card")),
      
      br(),
      
      dateRangeInput('date_range',
                     label = 'Select date range (inclusive): yyyy-mm-dd',
                     start = Sys.Date() - 30 , end = Sys.Date()
      ),
      
      br(),
      
      img(src = "dr_cannell_headshot.jpg", height = 250, width = 250), 
      
      h5("Principal Investigator", align = "center"),
      h5("Dr. M. Brad Cannell", align = "center")
      
        
      
    ),
    
    mainPanel(
      h3(textOutput("main_object")),
      br(),
      h3(textOutput("selected_dates")),
      br(),
      DT::dataTableOutput(outputId = "table"), style = "height:500px; overflow-y: scroll;overflow-x: scroll;"
                 
        
      )
      
    )
    
)

# Define server logic ----
server <- function(input, output) {
  
  output$main_object <- renderText({
    paste("You are viewing ", input$main_select)
  })
  
  output$selected_dates <- renderText({
    paste("You have selected the dates: ", as.character(input$date_range), collapse = " to ")
    })
  
  output$table <- DT::renderDataTable({
   if(input$main_select == "") { return() }
    
    call_log %>% 
           filter(call_date >= input$date_range[1],  call_date <= input$date_range[2])
    })


    
    
    
  
  
}

# Run the app ----
shinyApp(ui = ui, server = server)