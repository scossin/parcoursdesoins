STATICfilterCreator <- R6::R6Class(
  "STATICfilterCreator",
  
  public = list(
    
    createFilterObject = function(eventNumber, eventType, contextEvents, 
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
      dataFrame <- staticMakeQueries$getContextEventsPredicate(eventType = eventType,
                                                               contextEvents = contextEvents,
                                                               predicateName = predicateName,
                                                               terminologyName = terminologyName)
      #}
      
      if (filterType == "NUMERIC"){
        filterNumeric <- FilterNumeric$new(eventNumber = eventNumber, 
                                           predicateName = predicateName, 
                                           dataFrame = dataFrame,
                                           parentId = parentId, 
                                           where = where)
        
        
        return(filterNumeric)
      } else if (filterType == "DURATION"){
        filterNumericDuration <- FilterNumericDuration$new(eventNumber = eventNumber, 
                                                           predicateName = predicateName, 
                                                           dataFrame = dataFrame,
                                                           parentId = parentId, 
                                                           where = where)
        return(filterNumericDuration)
      } else if (filterType == "TERMINOLOGY"){
        ### dataframe :
        contextEvents <- data.frame(value = dataFrame$value)
        contextEvents$context <- ""
        contextEnv <- new.env()
        contextEnv$eventNumber <- 12245
        contextEnv$eventType <- expectedValue
        contextEnv$instanceSelection <- InstanceSelection$new(contextEnv = contextEnv, 
                              terminologyName = expectedValue, 
                              className = expectedValue, 
                              contextEvents = contextEvents, 
                              parentId = parentId, 
                              where = where)
        pointerEnv <- PointerEnv$new(contextEnv)
        return(pointerEnv)
      } else if (filterType == "FACTOR"){
        pointerEnv <- PointerEnv$new(new.env())
        return(pointerEnv)
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


