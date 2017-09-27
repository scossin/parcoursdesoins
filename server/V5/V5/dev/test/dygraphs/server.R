
library(dygraphs)
library(datasets)

# class(hw)
# class(test)
shinyServer(function(input, output) {
  
  library(xts)
  dates <- seq(as.Date("2017-05-01", format="%Y-%m-%d"), as.Date("2017-07-01", format="%Y-%m-%d"),by = "day")
  dates2 <- sample(dates, size = 1000,replace = T)
  tab <- table(dates2)
  tab <- data.frame(date=as.Date(names(tab)), frequency = as.numeric(tab))
  xtsObject <- xts(x = tab, order.by = tab$date, frequency = tab$frequency)
  # predicted <- reactive({
  #   hw <- HoltWinters(ldeaths)
  #   test <- predict(hw, n.ahead = 10, 
  #           prediction.interval = F,
  #           level = as.numeric(0.8))
  # })
  
  output$dygraph <- renderDygraph({
    dygraph(data = xtsObject, main = "Predicted Deaths/Month") 
      # dySeries(c("lwr", "fit", "upr"), label = "Deaths") %>%
      # dyOptions(drawGrid = input$showgrid)
  })

    output$from <- renderText({
    strftime(req(input$dygraph_date_window[[1]]), "%d %b %Y")      
  })
  
  output$to <- renderText({
    strftime(req(input$dygraph_date_window[[2]]), "%d %b %Y")
  })
  
  output$clicked <- renderText({
    strftime(req(input$dygraph_click$x), "%d %b %Y")
  })
  
  observeEvent(input[["dateRange"]],{
    value <- input[["dateRange"]]
    if (is.null(value)){
      return(NULL)
    }
    print (value[[1]])
  })
  
  output$point <- renderText({
    paste0('X = ', strftime(req(input$dygraph_click$x_closest_point), "%d %b %Y"), 
           '; Y = ', req(input$dygraph_click$y_closest_point))
  })
})

