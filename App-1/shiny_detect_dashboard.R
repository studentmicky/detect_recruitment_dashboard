
library(shiny)
library(flexdashboard)
library(dplyr)
library(tidyr)
library(ggplot2)


ui <- fluidPage(
  
  titlePanel("DETECT Recruitment Dashboard"),
  
  navlistPanel(
    "Overview",
    
    tabPanel("The DETECT Project",
             h1("Introducing the DETECT project"),
             br(),
             p("The Principal Investigator for the DETECT project is Dr. M. Brad Cannell, Associate Professor of Epidemiology, Human Genetics & Environmental Sciences at the University of Texas School of Public Health."),
             img(src = "dr_cannell_headshot.jpg", height = 120, width = 100),
             br(),
             p("This website is designed to be an interactive dashboard for the DETECT project."),
             br(),
             p("For a look at the past dashboard please click ",
               a("here.", 
                 href = "https://brad-cannell.github.io/detect_recruitment_dashboard/#overview"))),
    
    tabPanel("Summary",
             h2("Here are some interactive elements that are possible:"),
             br(),
             h2("Follow-up Interviews"),
             p("Please select the appropriate date range below"),
             dateRangeInput("follow-up date", label = "Follow-Up Interview Date Range"),
             br(),
             h2("What are you interested in knowing?"),
             selectInput("Select", h3("Select Box"),
                         choices = list("Total Calls Made" = 1, "Average Number of Calls Per Day" = 2,
                                        "Total Follow-Up Interviews Scheduled" = 3, "Follow-Up Scheduling Rate" = 4,
                                        "Average Number of Calls Made to Each Patient" = 5))),
    
    "Call Details",
    
    tabPanel("Call Timing",
             h2("Here are some of the interactive elements that are possible:"),
             br(),
             h3("Follow-up interviews scheduled by day of the week"),
             checkboxGroupInput("FUI Day",
                                h4("Select Days"),
                                choices = list(
                                  "Sunday" = 1,
                                  "Monday" = 2,
                                  "Tuesday" = 3,
                                  "Wednesday" = 4,
                                  "Thursday" = 5,
                                  "Friday" = 6,
                                  "Saturday" = 7
                                )),
             br(),
             h3("Follow-up interviews scheduled by time of day"),
             sliderInput("FUI TOD", h3("Slide for Time of Day"),
                         min = 0, max = 24, value = 13)),
    
    tabPanel("Call Responses"),
    
    "Other",
    
    tabPanel("MOCA")
  )
  
    )
    




# Define server logic ----
server <- function(input, output) {
  
}

# Run the app ----
shinyApp(ui = ui, server = server)