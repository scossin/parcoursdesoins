Result <- R6::R6Class(
  "Result",
  
  public=list(
    XMLsearchQuery = NULL,
    resultDf = data.frame(),
    
    initialize = function(XMLsearchQuery){
      self$XMLsearchQuery <- XMLsearchQuery
      self$resultDf <- GLOBALcon$sendQuery(self$XMLsearchQuery)
    }
  ),
  private=list(
    
  )
)