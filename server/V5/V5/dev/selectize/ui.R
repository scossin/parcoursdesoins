library(shiny)
library(shinydashboard)
library(plotly)

fluidPage(
  
  shiny::fluidRow(
    plotly::plotlyOutput(outputId = "pieChart1",width = "40%"),verbatimTextOutput("selection")
  )
)