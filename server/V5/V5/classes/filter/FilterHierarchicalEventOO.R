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
      return(paste0("Validate",self$getDivId()))
    },
    
    insertValidateButton = function(){
      ui <- shiny::actionButton(inputId = self$getButtonValidateId(), 
                                    label = GLOBALvalidate)
      selector = paste0("#",self$getDivId())
      insertUI(selector = selector,
               where ="afterBegin",
               ui = ui)
    },

    updateDataFrame = function(){
      stop("not supposed to be used as a Filter !")
    },
    
    getEventChoice = function(){
      if (length(private$eventChoice) == 0){
        return(GLOBALnoselected)
      }
      if (length(private$eventChoice) > 1){
        return(GLOBALmanyselected)
      }
      return(as.character(private$eventChoice))
    },
    
    getEventTypeSunburst = function(sunburstChoice){
      # sunburstChoice is a vector with length the depth of the node in the hierarchy
      staticLogger$info("Getting event from choice : ", sunburstChoice)
      sunburstChoice <- paste(sunburstChoice, collapse="-")
      # bool <- grepl(pattern = sunburstChoice,self$hierarchicalData$hierarch, fixed = T)
      bool <- self$hierarchy$tree %in% sunburstChoice 
      if (!any(bool)){
        stop(sunburstChoice, " : not found in hierarchicalData")
      }
      if (sum(bool) != 1){
        stop(sunburstChoice, " : many possibilities in hierarchicalData")
      }
      eventType <- as.character(self$hierarchy$label[bool])
      staticLogger$info("eventType found : ", eventType)
      return(eventType)
    }, 
    
    ### Override : don't send filterHasChanged
    printChoice = function(){
      output[[self$getChoiceVerbatimId()]] <- shiny::renderPrint(
        self$getEventChoice()
      )
      #self$contextEnv$instanceSelection$filterHasChanged()
      return(NULL)
    }
  )
)

