HierarchicalSunburst <- R6::R6Class(
  "HierarchicalSunburst",
  inherit = Hierarchical,
  
  public = list(
    eventNumber = numeric(),
    hierarchicalData = data.frame(),
    choice = character(),
    parentId = character(),
    where = character(),
    context = character(),
    
    initialize = function(eventNumber, context, parentId, where){
      self$parentId <- parentId
      self$where <- where
      self$eventNumber <- eventNumber
      self$context <- context
    }, 
    
    setHierarchicalData = function(hierarchicalData){
      private$checkHierarchicalData(hierarchicalData)
      self$hierarchicalData <- hierarchicalData
    }, 
    
    getHierarchicalDataFromServer = function(){
      GLOBALcon <- Connection$new()
      query <- XMLCountquery$new()
      query$addContextNode(contextVector = self$context)
      query$listContextNode
      eventCount <- GLOBALcon$sendQuery(query)
      hierarchy <- GLOBALcon$getFile(GLOBALcon$fileEventHierarchy4Sunburst)
      hierarchicalData <- merge (hierarchy, eventCount, by="event", all.x=T)
      bool <- is.na(hierarchicalData$count)
      hierarchicalData$count[bool] <- 0
      colnames(hierarchicalData) <- c("event","hierarchy","size")
      hierarchicalData <- rbind(hierarchicalData, data.frame(event="Event",hierarchy="Event",size=0))
      self$setHierarchicalData(hierarchicalData)
    },
    
    getObjectId = function(){
      paste0("hierarchicalSunburst",self$parentId)
    },
    
    insertUIandMakePlot = function(){
      private$insertUI()
      private$makePlot()
    },
    

    
    finalize = function(){
      self$removeUI()
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
    },
    
    getUI = function(){
      return(sunburstOutput(self$getObjectId()))
    },
    
    insertUI = function(){
      insertUI(
        selector = private$getJquerySelector(self$parentId),
        where = self$where,
        ui = private$getUI(),
        immediate = T
      )
    },
    
    makePlot = function(){
      output[[self$getObjectId()]] <- renderSunburst({
        sunburstData <- private$getSunburstData()
        add_shiny(sunburst(sunburstData, count=T,legend = list(w=200)))
      })
    }
  ))

