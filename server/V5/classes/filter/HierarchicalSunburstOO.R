HierarchicalSunburst <- R6::R6Class(
  "HierarchicalSunburst",
  inherit = Hierarchical,
  
  public = list(
    contextEnv = environment(),
    hierarchicalData = data.frame(),
    choice = character(),
    parentId = character(),
    where = character(),
    
    initialize = function(contextEnv, parentId, where){
      staticLogger$info("initiliazing a new HierarchicalSunburst")
      self$contextEnv <- contextEnv
      self$parentId <- parentId
      self$where <- where
    }, 
    
    setHierarchicalData = function(hierarchicalData){
      private$checkHierarchicalData(hierarchicalData)
      self$hierarchicalData <- hierarchicalData
    }, 
    
    getHierarchicalDataFromServer = function(){
      staticLogger$info("Trying to getHierarchicalDataFromServer")
      ## count
      GLOBALcon <- Connection$new()
      query <- XMLCountquery$new()
      query$addContextNode(contextVector = self$contextEnv$context)
      staticLogger$info("Sending", query$fileName, "...")
      eventCount <- GLOBALcon$sendQuery(query)
      print(eventCount)
      ## hierarchy
      content <- GLOBALcon$getContent(terminologyName = GLOBALcon$terminology$Event,
                                      information = GLOBALcon$information$hierarchy)
      staticLogger$info("Content received, reading content ...")
      hierarchy <- GLOBALcon$readContentStandard(content)
      print(hierarchy)
      staticLogger$info("merging hierarchy and eventCount ...")
      hierarchicalData <- merge (hierarchy, eventCount, by.x="event", by.y="className",all.x=T)
      bool <- is.na(hierarchicalData$count)
      staticLogger$info(sum(bool),"have 0 count in the hierarchy")
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
    
    removeUI = function(){
      session$sendCustomMessage(type = "removeId",
                                message = list(objectId = self$getObjectId()))
    },
    
    destroy = function(){
      staticLogger$info("Finalizing",self$getObjectId())
      self$removeUI()
    },
    
    getEventType = function(observerInput){
      # hierarchicalChoice is a vector with length the depth of the node in the hierarchy
      staticLogger$info("Getting event from choice : ", observerInput)
      hierarchicalChoice <- observerInput
      hierarchicalChoice <- paste(hierarchicalChoice, collapse="-")
      bool <- self$hierarchicalData$hierarchy %in% hierarchicalChoice  
      if (!any(bool)){
        stop(hierarchicalChoice, " : not found in hierarchicalData")
      }
      if (sum(bool) != 1){
        stop(hierarchicalChoice, " : many possibilities in hierarchicalData")
      }
      eventType <- as.character(self$hierarchicalData$event[bool])
      staticLogger$info("eventType found : ", eventType)
      return(eventType)
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
      staticLogger$info("getSunburstData for HierarchicalSunburst")
      return(subset(self$hierarchicalData, select=c("hierarchy","size")))
    },
    
    insertUI = function(){
      staticLogger$info("inserting HierarchicalSunburst", self$getObjectId(),self$where,self$parentId)
      ui <- sunburstOutput(self$getObjectId())
      insertUI(
        selector = private$getJquerySelector(self$parentId),
        where = self$where,
        ui = ui,
        immediate = T
      )
    },
    
    makePlot = function(){
      staticLogger$info("Plotting", self$getObjectId())
      output[[self$getObjectId()]] <- renderSunburst({
        sunburstData <- private$getSunburstData()
        add_shiny(sunburst(sunburstData, count=T,legend = list(w=200)))
      })
    }
  ))

