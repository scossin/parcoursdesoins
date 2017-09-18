STATICmakeQueries <- R6::R6Class(
  "STATICmakeQueries",
  
  public = list(
    initialize = function(){
      staticLogger$info("Initializing a new STATICmakeQueries")
    },
    
    getContextEvents = function(eventNumber, eventType, context){
      staticLogger$info("getting Events for",eventNumber, "of type : ", eventType)
      query <- XMLSearchQuery$new()
      query$addContextNode(context)
      query$addEventNode(eventNumber = eventNumber,
                         eventType = eventType,predicatesNodes = NULL)
      results <- self$getContextEventsQuery(query)
      # results <- GLOBALcon$sendQuery(query)
      # colnames(results) <- c("context","event")
      # staticLogger$info("Number of events : ",nrow(results))
      return(results)
    }, 
    
    getContextEventsQuery = function(query){
      results <- GLOBALcon$sendQuery(query)
      colnames(results) <- c("context","event")
      staticLogger$info("Number of events : ",nrow(results))
      return(results)
    },
    
    ### add a check contextEnv here
    getContextEventsPredicate = function(eventType, contextEvents, predicateName,terminologyName){
      staticLogger$info("getting values for a predicate",predicateName)
      staticLogger$info("eventType : ",eventType)
      staticLogger$info("Nevents : ",length(contextEvents$event))
      staticLogger$info("Looking into : ",terminologyName)
      context <- sort(contextEvents$context)
      contextList <- private$splitContext(context)
      results <- NULL
      shiny::withProgress(message = "Sending query", value = 0, {
        totalIter <- length(contextList)
        nIter <- 1
        for (context in contextList){
          bool <- contextEvents$context %in% context
          events <- contextEvents$event[bool]
          query <- private$getQuery(eventType, predicateName, events, context,terminologyName)
          timeMesure <- system.time(
            results <- rbind (results, GLOBALcon$sendQuery(query))
          )
          timeElapsed <- timeMesure["elapsed"]
          if (nIter != totalIter){
            remainingTime <- private$estimateRemainingTime(nIter, totalIter, timeElapsed)
            incProgress(nIter/totalIter, detail = paste("Remaining times : ", remainingTime, " seconds"))
          }
          nIter <- nIter + 1
        }
        return(results)
      })
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
    
    estimateRemainingTime = function(nIter, totalIter, timeElapsed){
      meanTime <- timeElapsed / nIter
      nIterRemain <- totalIter - nIter
      timeRemaining <- meanTime * nIterRemain
      timeRemaining <- ceiling(timeRemaining)
      return(timeRemaining)
    },
    
    getQuery = function(eventType, predicateName, events, context, terminologyName){
      if (terminologyName == GLOBALcon$terminology$Event){
        return(private$getQueryEvent(eventType, predicateName, events, context))
      } else {
        return(private$getQueryTerminology(eventType, predicateName, events, terminologyName))
      }

    },
    
    getQueryEvent = function(eventType, predicateName, events, context){
      query <- XMLDescribeQuery$new()
      ## the order for making this query is important !!
      query$addEventTypeNode(eventType)
      query$addPredicateTypeNode(predicateName)
      query$addEventInstances(events)
      query$addContextNode(context)
      return(query)
    },
    
    getQueryTerminology = function(eventType, predicateName, events, terminologyName){
      query <- XMLDescribeTerminologyQuery$new()
      query$addTerminologyName(terminologyName)
      query$addPredicateTypeNode(predicateName)
      query$addEventInstances(events)
      return(query)
    }
  )
)


