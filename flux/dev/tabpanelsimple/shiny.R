library(shiny)
runApp(list(
  ui = pageWithSidebar(
    headerPanel('Dynamic Tabs'),
    sidebarPanel(
      numericInput("nTabs", 'No. of Tabs', 5)
    ),
    mainPanel(
      uiOutput('mytabs')  
    )
  ),
  server = function(input, output, session){
    output$mytabs = renderUI({
      nTabs = input$nTabs
      myTabs = lapply(paste('Tab', 1: nTabs), tabPanel)
      do.call(tabsetPanel, myTabs)
    })
  }
))