STATICmakeQueries <- R6::R6Class(
  "STATICmakeQueries",
  
  public = list(
    initialize = function(){
    },
    
    
    
    setContextEvents = function(contextEnv){
      ls(contextEnv)
      query <- XMLSearchQuery$new()
      query$addContextNode(contextEnv$context)
      query$addEventNode(eventNumber = contextEnv$eventNumber,
                         eventType = contextEnv$eventType,predicatesNodes = NULL)
      results <- GLOBALcon$sendQuery(query)
      colnames(results) <- c("context","event")
      contextEnv$contextEvents <- results
      return(NULL)
    }, 
    
    ### add a check contextEnv here
    getContextEventsPredicate = function(contextEnv, predicateName){
      private$checkEnvironmentGetContextEventsPredicate(contextEnv)
      query <- XMLDescribeQuery$new()
      ## the order for making this query is important !!
      query$addEventTypeNode(contextEnv$eventType)
      query$addPredicateTypeNode(predicateName)
      query$addEventInstances(contextEnv$contextEvents$event)
      query$addContextNode(contextEnv$context)
      results <- GLOBALcon$sendQuery(query)
      return(results)
    }
  ),
  
  private = list(
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
