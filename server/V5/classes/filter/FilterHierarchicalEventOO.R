FilterHierarchicalEvent <- R6::R6Class(
  "FilterHierarchicalEvent",
  inherit = FilterHierarchical,
  
  public = list(
    initialize = function(contextEnv, terminology, predicateName, dataFrame, parentId, where){
      super$initialize(contextEnv, terminology, predicateName, dataFrame, parentId, where)
      self$insertValidateButton()
    }, 
    
    getEventCount = function(){
      terminologyName <- self$terminology$terminologyName
      eventType <- self$terminology$mainClassName
      contextVector = self$contextEnv$context
      eventCount <- staticMakeQueries$getEventCount(terminologyName = terminologyName,
                                      eventType = eventType, 
                                      predicateName = self$predicateName,
                                      contextVector = contextVector)
      return(eventCount)
    },
    
    getButtonValidateId = function(){
      return(paste0("Validate",self$getObjectId()))
    },
    
    insertValidateButton = function(){
      ui <- shiny::actionButton(inputId = self$getButtonValidateId(), 
                                    label="Validate")
      selector = paste0("#",self$getObjectId())
      insertUI(selector = selector,
               where ="afterBegin",
               ui = ui)
    },

    updateDataFrame = function(){
      stop("not supposed to be used as a Filter !")
    },
    
    getEventChoice = function(){
      if (length(private$eventChoice) == 0){
        return("please, select one class")
      }
      if (length(private$eventChoice) > 1){
        return("please, select only one class")
      }
      return(as.character(private$eventChoice))
    }
  )
)

