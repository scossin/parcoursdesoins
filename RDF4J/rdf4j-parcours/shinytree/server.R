library(shiny)
library(shinyTree)

#' Define server logic required to generate a simple tree
#' @author Jeff Allen \email{jeff@@trestletech.com}
#' 
library(RJSONIO)
RJSONIO::fromJSON("../file1.json")
liste <- jsonlite::fromJSON("../file1.json",simplifyDataFrame = F)
shinyServer(function(input, output, session) {
  output$tree <- renderTree({
    liste
  })
})