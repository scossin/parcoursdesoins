LinkEvents <- R6::R6Class(
  inherit = uiObject,
  "LinkEvents",
  
  public = list(
    searchPredicatesObserver = NULL,
    buttonSearchEventsObserver = NULL,
    
    initialize=function(parentId, where){
      staticLogger$info("New linkEvents")
      super$initialize(parentId, where)
      self$insertUIlink()
      self$addSearchPredicatesObserver()
      self$addButtonSearchEventsObserver()
    },
    
    insertUIlink = function(){
      ui <- self$getUI()
      jQuerySelector <- paste0("#",self$parentId)
      insertUI(
        selector = jQuerySelector,
        where = "beforeEnd",
        ui = ui
      )
    },
    
    destroy = function(){
      stop("why destroyed this UI ?")
    },
    
    getUI = function(){
      ui <- div(id = self$getDivLinks(),
                fluidRow(
                  
                  column(width = 2,
                shiny::selectInput(inputId = self$getEvent1SelectizeId(),
                                   label="event1",
                                   choices = private$eventsAvailable,
                                   selected = private$eventsAvailable,
                                   multiple = F,
                                   selectize = F)),
                  column(width = 2,
                shiny::selectInput(inputId = self$getEvent2SelectizeId(),
                                   label="event2",
                                   choices = private$eventsAvailable,
                                   selected = private$eventsAvailable,
                                   multiple = F,
                                   selectize = F)),
                  column(width = 2,
                shiny::selectInput(inputId = self$getPredicate1SelectizeId(),
                                      label="attribut event1",
                                      choices = "",
                                      selected = NULL,
                                      multiple = F)),
                column(width = 2,
                       shiny::selectInput(inputId = self$getPredicate2SelectizeId(),
                                          label="attribut event2",
                                          choices = "",
                                          selected = NULL,
                                          multiple = F)),
                
                  column(width = 2,
                shiny::selectInput(inputId = self$getOperatorSelectizeId(),
                                      label="opérateur",
                                      choices = c("difference","egal"),
                                      selected = NULL,
                                      multiple = F)),
                column(width = 2,
                shiny::numericInput(inputId = self$getMinInputId(),
                                    label = "min",
                                    value = 0,
                                    step = 1)),
                column(width = 2,
                shiny::numericInput(inputId = self$getMaxInputId(),
                                    label = "max",
                                    value = 0,
                                    step = 1))),
                shiny::actionButton(inputId = self$getButtonSearchPredicatesId(),
                                    label = "Rechercher des attributs communs"),
                shiny::actionButton(inputId = self$getButtonSearchEventsId(),
                                    label = "Rechercher des évènements"),
                verbatimTextOutput(outputId = self$getResultsVerbatimId()))
      return(ui)
    },
    
    addButtonSearchEventsObserver = function(){
      self$buttonSearchEventsObserver <- observeEvent(input[[self$getButtonSearchEventsId()]],{
        staticLogger$user("linkEvent Search Events clicked")
        event1 <- input[[self$getEvent1SelectizeId()]]
        event2 <- input[[self$getEvent2SelectizeId()]]
        if (is.null(event1) || event1 == "" || is.null(event2) || event2 == ""){
          staticLogger$info("event1 or event2 not set")
          return(NULL)
        }
        
        predicate1 <- input[[self$getPredicate1SelectizeId()]]
        predicate2 <- input[[self$getPredicate2SelectizeId()]]
        if (is.null(predicate1) || predicate1 == "" || is.null(predicate2) || predicate2 == ""){
          staticLogger$info("predicate1 or predicate2 not set")
          return(NULL)
        }
        
        minValue <- as.numeric(input[[self$getMinInputId()]])
        if (is.na(minValue)){
          staticLogger$info("incorrect minValue")
          return(NULL)
        }
        
        maxValue <- as.numeric(input[[self$getMaxInputId()]])
        if (is.na(maxValue)){
          staticLogger$info("incorrect maxValue")
          return(NULL)
        }
        
        query <- XMLSearchQuery$new()
        
        addEventNodeToQuery_ = function(event,query){
          eventTabpanel <- GLOBALlistEventTabpanel$listEventTabpanel[[event]]
          query <- eventTabpanel$contextEnv$instanceSelection$addContextNodeToQuery(query)
          return(query)
        }
        
        staticLogger$info("\t adding eventNode to query")
        query <- addEventNodeToQuery_(event1, query)
        query <- addEventNodeToQuery_(event2, query)
        # query$saveQuery()
        
        staticLogger$info("\t adding context to query")
        contextVector <- GLOBALcontextEnv$instanceSelection$context
        staticLogger$info("\t", length(contextVector), " contexts added")
        query$addContextNode(contextVector = contextVector)
        # query$saveQuery()
        
        staticLogger$info("\t adding linkNode")
        
        getEventNumber_ = function(event){
          eventTabpanel <- GLOBALlistEventTabpanel$listEventTabpanel[[event]]
          eventNumber <- eventTabpanel$contextEnv$eventNumber
          return(eventNumber)
        }
        
        eventNumber1 <- getEventNumber_(event1)
        eventNumber2 <- getEventNumber_(event2)
        
        query$addLinkNode(eventNumber1 = eventNumber1,
                          eventNumber2 = eventNumber2,
                          predicate1 = predicate1,
                          predicate2 = predicate2,
                          operator = "diff", ## CAUTION : change diff with operator value
                          minValue = minValue,
                          maxValue = maxValue)
        #query$saveQuery()
        
        staticLogger$info("\t Sending query")
        
        getTextResults_ <- function(results){
          Ncontexts <- length(unique(results$context))
          Nevents <- nrow(results)
          text <- paste0(Nevents, " couples d'", GLOBALevent, " - ", Ncontexts, " ", GLOBALparcours)
          return(text)
        }
        
        results <- GLOBALcon$sendQuery(query)
        
        output[[self$getResultsVerbatimId()]] <- shiny::renderPrint(
          getTextResults_(results)
        )
        
        # save(results,file="results.rdata")
      })
    },
    
    updateEvent = function(eventSelectizeId){
      previousChoice <- input[[eventSelectizeId]]
      bool <- previousChoice %in% private$eventsAvailable
      currentChoice <- ifelse (bool, previousChoice, "")
      shiny::updateSelectInput(session = session,
                        inputId = eventSelectizeId,
                        choices = private$eventsAvailable,
                        selected = currentChoice)
    },
    
    updatePredicate = function(predicates, predicateSelectizeId){
      shiny::updateSelectInput(session = session,
                               inputId = predicateSelectizeId,
                               choices = predicates,
                               selected = predicates[1])
    },
    
    getPredicates = function(event){
      bool <- event %in% names(GLOBALlistEventTabpanel$listEventTabpanel)
      if (!bool){
        staticLogger$info(event, "not found in GLOBALlistEventTabpanel$listEventTabpanel !")
        return(NULL)
      }
      eventTabpanel <- GLOBALlistEventTabpanel$listEventTabpanel[[event]]
      if (is.null(eventTabpanel$contextEnv$instanceSelection)){
        staticLogger$info(event, "no selection made")
        return(NULL)
      }
      predicatesEvent <- names(eventTabpanel$contextEnv$instanceSelection$listButtonFilterObject)
      return(predicatesEvent)
    },
    
    addSearchPredicatesObserver = function(){
      staticLogger$user("LinkEvent : searching predicates ...")
      self$searchPredicatesObserver <- observeEvent(input[[self$getButtonSearchPredicatesId()]],{
        iter <- 0
        predicates <- NULL
        event1 <- input[[self$getEvent1SelectizeId()]]
        event2 <- input[[self$getEvent2SelectizeId()]]
        if (is.null(event1) || is.null(event2) || event1 == "" || event2 == ""){
          staticLogger$info("Unselected event1 or event2 !")
          return(NULL)
        }

        predicates1 <- self$getPredicates(event1)
        predicates2 <- self$getPredicates(event2)
        
        if (is.null(predicates1) || is.null(predicates2)){
          return(NULL)
        }
        
        self$updatePredicate(predicates1, self$getPredicate1SelectizeId())
        self$updatePredicate(predicates2, self$getPredicate2SelectizeId())

      })
    },
    
    updateSelectionLink = function(){
      staticLogger$info("Updating selection of link Events")
      events <- NULL
      for (eventTabpanel in GLOBALlistEventTabpanel$listEventTabpanel){
        event <- paste0("event",eventTabpanel$contextEnv$eventNumber)
        events <- c(events, event)
      }
      if (is.null(events)){
        events <- ""
      }
      private$eventsAvailable <- events
      self$updateEvent(self$getEvent1SelectizeId())
      self$updateEvent(self$getEvent2SelectizeId())
      return(NULL)
    },
    
    getDivLinks = function(){
      return(paste0("divlinkEvents",self$parentId))
    },
    
    getResultsVerbatimId = function(){
      return(paste0("VerbatimResults",self$getDivLinks()))
    },
    
    getEvent1SelectizeId = function(){
      return(paste0("event1Choice",self$getDivLinks()))
    },
    
    getEvent2SelectizeId = function(){
      return(paste0("event2Choice",self$getDivLinks()))
    },
    
    getPredicate1SelectizeId = function(){
      return(paste0("predicate1Choice",self$getDivLinks()))
    },
    
    getPredicate2SelectizeId = function(){
      return(paste0("predicate2Choice",self$getDivLinks()))
    },
    
    getOperatorSelectizeId = function(){
      return(paste0("Operator",self$getDivLinks()))
    },
    
    getMaxInputId = function(){
      return(paste0("Max",self$getDivLinks()))
    },
    
    getMinInputId = function(){
      return(paste0("Min",self$getDivLinks()))
    },
    
    getButtonSearchPredicatesId = function(){
      return(paste0("SearchPredicates",self$getDivLinks()))
    },
    
    getButtonSearchEventsId = function(){
      return(paste0("SearchEvents",self$getDivLinks()))
    }
  ),
  private=list(
    eventsAvailable = ""
  ))
