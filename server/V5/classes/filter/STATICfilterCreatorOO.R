STATICfilterCreator <- R6::R6Class(
  "STATICfilterCreator",
  
  public = list(
    
    getDataFrame = function(terminologyName, eventType, contextEvents, predicateName){
      staticLogger$info("Getting dataFrame... ")
      staticLogger$info("\t eventType : ", eventType)
      staticLogger$info("\t contextEvents : ", nrow(contextEvents), "lines")
      staticLogger$info("\t predicateName : ", predicateName)
      staticLogger$info("\t terminologyName : ", terminologyName)
      if (nrow(contextEvents) == 0){
        dataFrame <- data.frame(event = character(), value=character())
        return(dataFrame)
      }
      
      
      # separating Event and others 
      if (terminologyName == staticTerminologyInstances$terminology$Event$terminologyName){
        dataFrame <- staticMakeQueries$getContextEventsPredicate(eventType = eventType,
                                                                 contextEvents = contextEvents,
                                                                 predicateName = predicateName,
                                                                 terminologyName = terminologyName)
        
        allEvents <- unique(contextEvents$event)
        dataFrame <- subset (dataFrame, select=c("event","value"))
        bool <- allEvents %in% dataFrame$event
        if (!all(bool)){
          missingEvents <- allEvents[!bool]
          staticLogger$info("Missing values of ", predicateName, "for events:", missingEvents)
          addingNA <- data.frame(event = missingEvents, value=NA)
          dataFrame <- rbind(dataFrame, addingNA)
        }
        return(dataFrame)
      } else {
        ### context is not need - so simply remove it
        tempContextEvents <- contextEvents
        tempContextEvents$context <- ""
        tempContextEvents <- unique(tempContextEvents)
        dataFrame <- staticMakeQueries$getContextEventsPredicate(eventType = eventType,
                                                                 contextEvents = tempContextEvents,
                                                                 predicateName = predicateName,
                                                                 terminologyName = terminologyName)
        dataFrame <- subset (dataFrame, select=c("event","value"))
        contextEvents <- data.frame(event = contextEvents$event)
        dataFrame <- merge (contextEvents, dataFrame, by="event", all.x=T)
        return(dataFrame)
      }
    },
    
    createFilterObject = function(contextEnv, eventType, contextEvents, 
                                  predicateName, terminology, parentId, where){
      
      filterType <- terminology$getPredicateDescription(predicateName)$category
      expectedValue <- terminology$getPredicateDescription(predicateName)$value
      terminologyName <- terminology$terminologyName
      
      staticLogger$info("\t Filter type : ",filterType)
      
      bool <- filterType %in% private$availableFilters
      if (!bool){
        stop("filterType of ",predicateName,"(",filterType,") not in : ",
             paste0(private$availableFilters, collapse = " "))
      }
      
      dataFrame <- self$getDataFrame(terminologyName, eventType, contextEvents, predicateName)
      
      filterType <- as.character(filterType)
      
      if (filterType == "NUMERIC"){
        filterNumeric <- FilterNumeric$new(contextEnv = contextEnv,
                                           predicateName = predicateName, 
                                           dataFrame = dataFrame,
                                           parentId = parentId, 
                                           where = where)
        
        
        return(filterNumeric)
      } else if (filterType == "DURATION"){
        filterNumericDuration <- FilterNumericDuration$new(contextEnv = contextEnv, 
                                                           predicateName = predicateName, 
                                                           dataFrame = dataFrame,
                                                           parentId = parentId, 
                                                           where = where)
        return(filterNumericDuration)
      } else if (filterType == "TERMINOLOGY"){
        ### dataframe :
        # dataFrame ## context? event predicate value
        # contextEvents ## context ? event 
        # contextEvents <- data.frame(value = dataFrame$value)
        # contextEvents$context <- ""
        colnames(dataFrame) <- c("context","event")
        contextEnv2 <- new.env()
        contextEnv2$eventNumber <- as.numeric(paste0(contextEnv$eventNumber),"11")## 111 111111 ...
        contextEnv2$eventType <- expectedValue
        terminology <- staticTerminologyInstances$getTerminology(as.character(expectedValue))
        contextEnv2$predicateName <- predicateName
        contextEnv2$instanceSelection <- InstanceSelection$new(contextEnv = contextEnv2, 
                                                               terminology = terminology, 
                                                               className = expectedValue, 
                                                               contextEvents = dataFrame, 
                                                               parentId = parentId, 
                                                               where = where)
        pointerEnv <- PointerEnv$new(contextEnvParent = contextEnv,
                                     contextEnv = contextEnv2)
        return(pointerEnv)
      } else if (filterType == "STRING"){
        filterCategorical <- FilterCategorical$new(contextEnv = contextEnv, 
                                                   predicateName = predicateName, 
                                                   dataFrame = dataFrame,
                                                   parentId = parentId, 
                                                   where = where)
        return(filterCategorical)
      } else if (filterType == "DATE"){
        filterDate <- FilterDate$new(contextEnv = contextEnv, 
                                                   predicateName = predicateName, 
                                                   dataFrame = dataFrame,
                                                   parentId = parentId, 
                                                   where = where)
        return(filterDate)
      } else if (filterType == "SPATIALPOINT"){
        #colnames(dataFrame) <- c("context","event")
        pointsCoordinate <- table(dataFrame$value)
        pointsCoordinate <- data.frame(event = names(pointsCoordinate), 
                                       N = as.numeric(pointsCoordinate))
        pointsCoordinate$context <- ""
        #pointsCoordinate <- data.frame(context="",event=unique(dataFrame$event))
        for (spatialPredicate in c("lat","long","label")){
          addColumn <- self$getDataFrame(terminologyName = terminologyName, 
                                        eventType = expectedValue, 
                                        contextEvents = pointsCoordinate, 
                                        predicateName = spatialPredicate)
          colnames(addColumn) <- c("event",spatialPredicate)
          pointsCoordinate <- merge (pointsCoordinate, addColumn, by="event")
        }
        filterSpatial <- FilterSpatialPoint$new(contextEnv = contextEnv, 
                                                predicateName = predicateName, 
                                                dataFrame = dataFrame, 
                                                parentId = parentId, 
                                                where = where,
                                                pointsCoordinate = pointsCoordinate)
        GLOBALmapObject$addSpatialFilter(filterSpatial)
        return(filterSpatial)
      } else if (filterType == "HIERARCHY"){
        terminology <- staticTerminologyInstances$getTerminology(as.character(expectedValue))
        filterHierarchical <- FilterHierarchical$new(contextEnv = contextEnv,
                                                     terminology = terminology,
                                                     predicateName = predicateName, 
                                                     dataFrame = dataFrame,
                                                     parentId = parentId, 
                                                     where = where)
        return(filterHierarchical)
      }
      return(NULL)
    },
    
    initialize = function(){
      cat("initializing STATICfilterCreator \n")
    }
  ),
  
  private = list(
    availableFilters = c("NUMERIC","DATE","HIERARCHY","STRING","DURATION", "TERMINOLOGY",
                         "SPATIALPOINT","SPATIALPOLYGON"),
    ## DEPRECATED
    checkEnvironment = function(contextEnv){
      objectsList <- ls(contextEnv)
      bool <- "instanceSelection" %in% objectsList
      if (!bool){
        stop("No instanceSelection found to add filterCreator")
      }
    },
    
    ## DEPRECATED
    checkEnvironmentGetContextEventsPredicate = function(contextEnv){
      if (!is.environment(contextEnv)){
        stop("contextEnv must be an environment")
      }
      envObjects <- ls(contextEnv)
      expectedObjects <- c("eventNumber", "context", "eventType", "contextEvents")
      bool <-  expectedObjects %in% envObjects
      if (!all(bool)){
        stop("Missing ", expectedObjects[bool], " in context environment for ButtonFilter to work")
      }
      return(NULL)
    }
  )
)
