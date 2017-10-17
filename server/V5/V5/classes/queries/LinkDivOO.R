LinkDiv <- R6::R6Class(
  inherit = uiObject,
  "LinkDiv",
  public = list(
    listLinkEvents = list(),
    buttonLinkEventsObserver = NULL,
    searchPredicatesObserver = NULL,
    
    initialize = function(parentId, where){
      super$initialize(parentId, where)
      self$insertDivUI()
      self$insertHTMLdescription()
      self$addSearchPredicatesObserver()
      self$addButtonLinkEventsObserver()
    },
    
    insertDivUI = function(){
      jQuerySelector = paste0("#",self$parentId)
      insertUI(
        selector = jQuerySelector,
        where = "beforeEnd",
        ui = self$getUI()
      )
    },
    
    getUI = function(){
      ui <- div(id = self$getDivId(),
              self$getUIDescription(),
              self$getUILinkChoice()
          )
    },
    
    getUILinkChoice = function(){
      ui <- div(id = self$getUILinkChoiceId(),
                fluidRow(
                  h3 ("Links creation"),
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
                shiny::actionButton(inputId = self$getButtonLinkEventsId(),
                                    label = "Link Events"))
                #verbatimTextOutput(outputId = self$getResultsVerbatimId()))
      return(ui)
    },
    
    
    addButtonLinkEventsObserver = function(){
      self$buttonLinkEventsObserver <- observeEvent(input[[self$getButtonLinkEventsId()]],{
        staticLogger$user("LinkEvents clicked")
        self$addLinkEvents()
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
    
    
    getUIDescription = function(){
      ui <- shiny::uiOutput(outputId = self$getHTMLdescriptionId())
      return(ui)
    },
    
    insertHTMLdescription = function(){
      htmlDescription <- self$getHTMLdescription()
      if (is.null(htmlDescription)){
        htmlDescription <- shiny::tags$p("No link created between events")
      }
      output[[self$getHTMLdescriptionId()]] <- renderUI({
        shiny::tagList(
          h2("Links between events"),
          h3 ("Links description"),
          shiny::tags$ul(htmlDescription)
        )

      })
    },
    
    getDivId = function(){
      return(paste0("divLink",self$parentId))
    },
    
    getUILinkChoiceId = function(){
      return(paste0("LinkChoice",self$getDivId()))
    },
    
    getEvent1SelectizeId = function(){
      return(paste0("event1Choice",self$getUILinkChoiceId()))
    },
    
    getEvent2SelectizeId = function(){
      return(paste0("event2Choice",self$getUILinkChoiceId()))
    },
    
    getPredicate1SelectizeId = function(){
      return(paste0("predicate1Choice",self$getUILinkChoiceId()))
    },
    
    getPredicate2SelectizeId = function(){
      return(paste0("predicate2Choice",self$getUILinkChoiceId()))
    },
    
    getOperatorSelectizeId = function(){
      return(paste0("Operator",self$getUILinkChoiceId()))
    },
    
    getMaxInputId = function(){
      return(paste0("Max",self$getUILinkChoiceId()))
    },
    
    getMinInputId = function(){
      return(paste0("Min",self$getUILinkChoiceId()))
    },
    
    getButtonSearchPredicatesId = function(){
      return(paste0("SearchPredicates",self$getUILinkChoiceId()))
    },
    
    getButtonLinkEventsId = function(){
      return(paste0("ButtonLinkEvents",self$getUILinkChoiceId()))
    },
    
    getHTMLdescriptionId = function(){
      return(paste0("HTMLdescription",self$getDivId()))
    },
    
    getHTMLdescription = function(){
      ## loop to get all links description : 
      description <- list()
      for (linkEvents in self$listLinkEvents){
        description <- append(description, shiny::tagList(linkEvents$getDescription()))
      }
      if (length(description) == 0){
        return(NULL)
      }
      return(description)
    }, 
    
    
    addLinkEvents = function(){
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
      
      eventNumber1 <- private$getEventNumber(event1)
      eventNumber2 <- private$getEventNumber(event2)
      
      linkEvents <- LinkEvents$new(eventNumber1 = eventNumber1, 
                                   eventNumber2 = eventNumber2, 
                                   predicate1 = predicate1, 
                                   predicate2 = predicate2,
                                   operator = "diff", ## CAUTION : change diff with operator value
                                   minValue = minValue, 
                                   maxValue = maxValue)
      listLength <- length(self$listLinkEvents)
      self$listLinkEvents[[listLength+1]] <- linkEvents
      return(NULL)
    }
  ),
  private=list(
    eventsAvailable = "",
    
    getEventNumber = function(event){
      eventTabpanel <- GLOBALlistEventTabpanel$listEventTabpanel[[event]]
      eventNumber <- eventTabpanel$contextEnv$eventNumber
      return(eventNumber)
    }
  ))