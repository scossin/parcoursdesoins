HierarchicalSunburst <- R6::R6Class(
  "HierarchicalSunburst",
  inherit = Hierarchical,
  
  public = list(
    eventNumber = numeric(),
    hierarchicalData = data.frame(),
    choice = character(),
    
    initialize = function(eventNumber, hierarchicalData){
      self$eventNumber = eventNumber
      private$checkHierarchicalData(hierarchicalData)
      self$hierarchicalData = hierarchicalData
    }, 
    
    getObjectId = function(){
      paste0("hierarchical",self$eventNumber)
    },
    
    getUI = function(){
      return(sunburstOutput(self$getObjectId()))
    },
    
    sendPrivate = function(){
      trailId <- paste0(self$getObjectId(),"-trail")
      session$sendCustomMessage(type = "removeSunburstTrail",
                                message = list(id = trailId))
    },
    
    makeUI = function(){
      output[[self$getObjectId()]] <- renderSunburst({
        sunburstData <- private$getSunburstData()
        add_shiny(sunburst(sunburstData, count=T,legend = list(w=200)))
      })
    },
    
    setUI = function(){
      output[[self$getObjectId()]] <- renderSunburst({
        sunburstData <- private$getSunburstData()
        sunburstData$size <- 1:nrow(sunburstData)
        add_shiny(sunburst(sunburstData, count=T,legend = list(w=200)))
      })
    },
    
    getEvent = function(hierarchicalChoice){
      # hierarchicalChoice is a vector with length the depth of the node in the hierarchy
      hierarchicalChoice <- paste(hierarchicalChoice, collapse="-")
      bool <- self$hierarchicalData$hierarchy %in% hierarchicalChoice  
      if (!any(bool)){
        stop(hierarchicalChoice, " : not found in hierarchicalData")
      }
      if (sum(bool) != 1){
        stop(hierarchicalChoice, " : many possibilities in hierarchicalData")
      }
      return(self$hierarchicalData$event[bool])
    }, 
  
    getInputObserver = function(){
      return(paste0(self$getObjectId(), "_click"))
    }
    
  ),
  
  private = list(
    checkHierarchicalData = function(hierarchicalData){
      columnsNames <- c("event","hierarchy","size")
      bool <- colnames(hierarchicalData) %in% columnsNames
      if (!all(bool)){
        stop("hierarchicalData must be a data.frame containing 3 columns", columnsNames)
      }
    },
    
    getSunburstData = function(){
      return(subset(self$hierarchicalData, select=c("hierarchy","size")))
    }
  ))