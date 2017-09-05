Filter <- R6::R6Class(
  "Filter",
  inherit=uiObject,
  
  public=list(
    eventNumber = numeric(),
    predicateName = character(),
    # domParentId = character(),
    dataFrame = data.frame(),
    
    initialize = function(eventNumber, predicateName, dataFrame, parentId, where){
      super$initialize(parentId = parentId, where = where)
      private$checkDataFrame(dataFrame)
      self$dataFrame <- dataFrame
      self$eventNumber <- eventNumber
      self$predicateName <- predicateName
      # self$domParentId <- domParentId
    },
    
    getChosenEvents = function(){
      stop("getChoosenEvents not implemented !")
    },
    
    setContext = function(){
      stop("setContext not implemented !")
    },
    destroy = function(){
      
    }
  ),
  

  
  private=list(
    checkDataFrame = function(dataFrame){
      #columns <- c("context","event","predicate","value")
      columns <- c("event","predicate","value")
      bool <-  columns %in%  colnames(dataFrame)
      if (!all(bool)){
        stop("Filter dataFrame must contain only : ", 
             paste(columns, collapse=" "), " \n not : ", paste(colnames(dataFrame), collapse=" "))
      }

    }
  )
)