STATICmakeQueries <- R6::R6Class(
  "STATICmakeQueries",
  
  public = list(
    initialize = function(){
      staticLogger$info("Initializing a new STATICmakeQueries")
    },
    
    getContext = function(query){
      results <- GLOBALcon$sendQuery(query)
      colnames(results) <- c("context")
      if (nrow(results)!=0){
        results$event <- results$context
      } else {
        results <- data.frame(context=character(), event=character())
      }
      staticLogger$info("Number of context : ",nrow(results))
      return(results)
    },
    
    getContextEvents = function(eventNumber, terminologyName, eventType, context){
      staticLogger$info("getting Events for",eventNumber, "of type : ", eventType)
      query <- XMLSearchQuery$new()
      query$addContextNode(context)
      query$addEventNode(eventNumber = eventNumber,
                         terminologyName = terminologyName,
                         eventType = eventType,
                         predicatesNodes = NULL)
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
      # context <- sort(contextEvents$context)
      # contextList <- private$splitContext(context)
      events <- unique(contextEvents$event)
      eventsList <- private$splitEvents(events)
      results <- NULL
      shiny::withProgress(message = "Sending query", value = 0, {
        totalIter <- length(eventsList)
        nIter <- 1
        for (events in eventsList){
          bool <- contextEvents$event %in% events
          context <- contextEvents$context[bool]
          query <- private$getQuery(eventType, predicateName, events, context,terminologyName)
          timeMesure <- system.time(
            results <- rbind (results, GLOBALcon$sendQuery(query))
          )
          timeElapsed <- timeMesure["elapsed"]
          staticLogger$info("\t timeElapsed : ",timeElapsed)
          if (nIter != totalIter){
            remainingTime <- private$estimateRemainingTime(nIter, totalIter, timeElapsed)
            incProgress(nIter/totalIter, detail = paste("Remaining times : ", remainingTime, " seconds"))
          }
          nIter <- nIter + 1
        }
        return(results)
      })
    },
    
    getEventCount = function(contextVector){
      staticLogger$info("Counting events of ", length(contextVector), "contexts")
      query <- XMLCountquery$new()
      query$addContextNode(contextVector = self$contextEnv$context)
      eventCount <- GLOBALcon$sendQuery(query)
      bool <- colnames(eventCount) %in% c("className","count")
      if (!all(bool)){
        staticLogger$error("Unexpected columns :", colnames(eventCount))
        stop("Unexpected columns :", colnames(eventCount))
      }
      return(eventCount)
    }
  ),
  
  
  private = list(
    # splitContext = function(context){
    #   chunk <- 500
    #   n <- length(context)
    #   r <- rep(1:ceiling(n/chunk),each=chunk)[1:n]
    #   d <- split(context, r)
    #   return(d)
    # },
    
    splitEvents = function(events){
      chunk <- 500
      n <- length(events)
      r <- rep(1:ceiling(n/chunk),each=chunk)[1:n]
      d <- split(events, r)
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
        return(private$getQueryEvent(eventType, predicateName, events,terminologyName, context))
      } else {
        return(private$getQueryTerminology(eventType, predicateName, events, terminologyName))
      }

    },
    
    getQueryEvent = function(eventType, predicateName, events, terminologyName, context){
      query <- XMLDescribeQuery$new()
      ## the order for making this query is important !!
      query$addEventTypeNode(eventType, terminologyName)
      query$addPredicateTypeNode(predicateName)
      query$addEventInstances(events)
      query$addContextNode(context)
      return(query)
    },
    
    getQueryTerminology = function(eventType, predicateName, events, terminologyName){
      query <- XMLDescribeTerminologyQuery$new()
      query$addTerminologyName(eventType, terminologyName)
      query$addPredicateTypeNode(predicateName)
      query$addEventInstances(events)
      return(query)
    }
  )
)


