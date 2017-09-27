require(treemap)
require(dplyr)
require(shiny)
require(gridBase)
require(RColorBrewer)
require(plotly)



shinyServer <- function(session,input,output){

  output[["pieChart1"]] <- plotly::renderPlotly({
    tab <- table(LETTERS[1:10])
    df <- data.frame(labels = names(tab), values = as.numeric(tab))
    plotly::plot_ly(df, labels = ~labels, values = ~values, type = 'pie', source="pieChart1")
    # plotly::plot_ly(x = 1:10, y=1:10, type = 'scatter',
    #                mode="markers",source="pieChart1") 
    
  })
  
  output$selection <- renderPrint({
    s <- event_data("plotly_click",source = "pieChart1")
    if (length(s) == 0) {
      "Click on a cell in the heatmap to display a scatterplot"
    } else {
      cat(LETTERS[s$pointNumber+1])
    }
  })
  
  # observe({
  #   s <- event_data("plotly_click",source = "pieChart1")
  #   if (length(s) == 0) {
  #     "Click on a cell in the heatmap to display a scatterplot"
  #   } else {
  #     cat(LETTERS[s$pointNumber+1])
  #   }
  # })
  test <- Test$new()
}


