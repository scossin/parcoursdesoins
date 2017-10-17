Filter <- R6::R6Class(
  "Filter",
  inherit=uiObject,
  
  public=list(
    contextEnv = environment(),
    predicateName = character(),
    # domParentId = character(),
    dataFrame = data.frame(),
    
    initialize = function(contextEnv, predicateName, dataFrame, parentId, where){
      super$initialize(parentId = parentId, where = where)
      private$checkDataFrame(dataFrame)
      self$contextEnv <- contextEnv
      self$dataFrame <- dataFrame
      self$predicateName <- predicateName
      # self$domParentId <- domParentId
    },
    
    getPredicateLabel = function(){
      label <- as.character(self$contextEnv$instanceSelection$terminology$getLabel(self$predicateName))
      return(label)
    },
    
    updateDataFrame = function(){
      stop("updateDataFrame not implemented !")
    },
    
    getEventsSelected = function(){
      stop("getEventsSelected not implemented !")
    },
    
    getXMLpredicateNode = function(){
      stop("getXMLpredicateNode not implemented !")
    }, 
    
    destroy = function(){
      stop("destroy not implemented ! ")
    },
    
    getDescription = function(){
      stop("getDescription not implemented ! ")
    }
  ),
  

  
  private=list(
    checkDataFrame = function(dataFrame){
      #columns <- c("context","event","predicate","value")
      # columns <- c("event","predicate","value")
      columns <- c("event","value")
      bool <-  columns %in%  colnames(dataFrame)
      if (!all(bool)){
        stop("Filter dataFrame must contain only : ", 
             paste(columns, collapse=" "), " \n not : ", paste(colnames(dataFrame), collapse=" "))
      }

    }
  )
)