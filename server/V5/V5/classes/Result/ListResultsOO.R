ListResults <- R6::R6Class(
  "ListResults",
  
  public = list(
    listResults = list(),
    
    addResult = function(result){
      bool <- inherits(result, "Result")
      if (!bool){
        stop("result must be instance of Result")
      }
      listLength <- length(self$listResults)
      self$listResults[[listLength+1]] <- result
    }
  )
  )