getPieChart2Id = function(){
  return("pieChart1")
}

Test <- R6::R6Class(
  "Test",
  
  
  public = list(
    observer = NULL, 
    value = character(),
    initialize = function(){
      self$addObserver()
    },
    
    showValue = function(){
      print(self$value)
    },
    
    addObserver = function(){
      self$observer <- observe({
        s <- event_data("plotly_click",source = "pieChart1")
        if (length(s) == 0) {
          "Click on a cell in the heatmap to display a scatterplot"
        } else {
          self$value <- LETTERS[s$pointNumber+1]
          self$showValue()
          if (!is.null(self$observer)){
            self$observer$destroy()
          }
        }
      })
    }
  )
)

