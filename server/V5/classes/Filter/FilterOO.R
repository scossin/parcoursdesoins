Filter <- R6::R6Class(
  "Filter",
  public=list(
    eventNumber = numeric(),
    predicateName = character(),
    # domParentId = character(),
    dataFrame = data.frame(),
    
    initialize = function(eventNumber, predicateName, dataFrame){
      private$checkDataFrame(dataFrame)
      self$dataFrame <- dataFrame
      self$eventNumber <- eventNumber
      self$predicateName <- predicateName
      # self$domParentId <- domParentId
    },
    
    getUI = function(){
      stop("getUI not implemented !")
    },
    
    getChoosenEvents = function(){
      stop("getChoosenEvents not implemented !")
    },
    
    setContext = function(){
      stop("setContext not implemented !")
    }
    
  ),
  
  private=list(
    checkDataFrame = function(dataFrame){
      columns <- c("context","event","value")
      bool <- colnames(dataFrame) %in% columns
      if (!all(bool)){
        stop("Filter dataFrame must contain only : ", 
             paste(columns, collapse=" "), " \n not : ", paste(colnames(dataFrame), collapse=" "))
      }

    }
  )
)