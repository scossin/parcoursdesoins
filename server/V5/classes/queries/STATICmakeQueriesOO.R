STATICmakeQueries <- R6::R6Class(
  "STATICmakeQueries",
  
  public = list(
    initialize = function(){
      staticLogger$info("Initializing a new STATICmakeQueries")
    },
    
    setContextEvents = function(contextEnv){
      staticLogger$info("getting Events for",contextEnv$eventNumber, "of type : ", contextEnv$eventType)
      query <- XMLSearchQuery$new()
      query$addContextNode(contextEnv$context)
      query$addEventNode(eventNumber = contextEnv$eventNumber,
                         eventType = contextEnv$eventType,predicatesNodes = NULL)
      results <- GLOBALcon$sendQuery(query)
      colnames(results) <- c("context","event")
      staticLogger$info("Number of events : ",nrow(results))
      contextEnv$contextEvents <- results
      if (contextEnv$context == ""){
        contextEnv$context <- unique(contextEnv$contextEvents$context)
      }
      return(NULL)
    }, 
    
    ### add a check contextEnv here
    getContextEventsPredicate = function(contextEnv, predicateName){
      staticLogger$info("getting values for a predicate",predicateName)
      staticLogger$info("eventType : ",contextEnv$eventType)
      staticLogger$info("Nevents : ",length(contextEnv$contextEvents$event))
      private$checkEnvironmentGetContextEventsPredicate(contextEnv)
      context <- sort(contextEnv$context)
      contextList <- private$splitContext(context)
      results <- NULL
      for (context in contextList){
        bool <- contextEnv$contextEvents$context %in% context
        events <- contextEnv$contextEvents$event[bool]
        query <- private$getQuery(contextEnv$eventType, predicateName, events, context)
        results <- rbind (results, GLOBALcon$sendQuery(query))
      }
      return(results)
    }
  ),
  
  private = list(
    splitContext = function(context){
      chunk <- 100
      n <- length(context)
      r <- rep(1:ceiling(n/chunk),each=chunk)[1:n]
      d <- split(context, r)
      return(d)
    },
    
    getQuery = function(eventType, predicateName, events, context){
      query <- XMLDescribeQuery$new()
      ## the order for making this query is important !!
      query$addEventTypeNode(eventType)
      query$addPredicateTypeNode(predicateName)
      query$addEventInstances(events)
      query$addContextNode(context)
      return(query)
    },
    
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


