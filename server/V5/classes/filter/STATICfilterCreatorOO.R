STATICfilterCreator <- R6::R6Class(
  "STATICfilterCreator",
  
  public = list(
    
    createFilterObject = function(contextEnv, eventType, contextEvents, 
                                  filterType, predicateName, expectedValue, 
                                  terminologyName, parentId, where){
      
      staticLogger$info("\t Filter type : ",filterType)
      
      bool <- filterType %in% private$availableFilters
      if (!bool){
        stop("filterType of ",predicateName,"(",filterType,") not in : ",
             paste0(private$availableFilters, collapse = " "))
      }
      
      filterType <- as.character(filterType)
      
      #if (filterType != "TERMINOLOGY"){
      if (terminologyName == GLOBALterminologyDescription$Event$terminologyName){
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
      }


      #}
      
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
        contextEnv2$instanceSelection <- InstanceSelection$new(contextEnv = contextEnv2, 
                                                               terminologyName = expectedValue, 
                                                               className = expectedValue, 
                                                               contextEvents = dataFrame, 
                                                               parentId = parentId, 
                                                               where = where)
        pointerEnv <- PointerEnv$new(contextEnv2)
        return(pointerEnv)
      } else if (filterType == "FACTOR"){
        filterCategorical <- FilterCategorical$new(contextEnv = contextEnv, 
                                                   predicateName = predicateName, 
                                                   dataFrame = dataFrame,
                                                   parentId = parentId, 
                                                   where = where)
        return(filterCategorical)
      }
      return(NULL)
    },
    
    initialize = function(){
      cat("initializing STATICfilterCreator \n")
    }
  ),
  
  private = list(
    availableFilters = c("NUMERIC","DATE","HIERARCHICAL","FACTOR","DURATION", "TERMINOLOGY"),
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
