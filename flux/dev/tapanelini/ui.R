library(shiny)
library(DT)

ui <- shinyUI(fluidPage(
  
  # Important! : JavaScript functionality to add the Tabs
  tags$head(tags$script(src = "js/addTabToTabset.js")),
  
  # pour retirer le tabset et le boutton permet de le retirer !
  tags$head(tags$script(src = "js/removeTabToTabset.js")),
  
  
  # End Important
  
  tabsetPanel(id = "mainTabset", 
              tabPanel("InitialPanel1", "Some Text here to show this is InitialPanel1", 
                       actionButton("goCreate", "Go create a new Tab!"),
                       textOutput("creationInfo")
              ),
              tabPanel("InitialPanel2", "Some Text here to show this is InitialPanel2 and not some other Panel")
  ),
  
  # Important! : 'Freshly baked' tabs first enter here.
  uiOutput("creationPool", style = "display: none;")
  # End Important
  ))
