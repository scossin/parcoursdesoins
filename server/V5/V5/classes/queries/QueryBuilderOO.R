QueryBuilder <- R6::R6Class(
  inherit = uiObject,
  "QueryBuilder",
  
  public = list(
    xmlSearchQuery = NULL,
    buttonSearchEventsObserver = NULL,
    buttonSetQueryObserver = NULL,
    buttonLinkEvents = NULL,
    linkDiv = NULL,
    eventDiv = NULL,
    
    initialize=function(parentId, where){
      staticLogger$info("New QueryBuilder")
      super$initialize(parentId, where)
      self$insertUIlink()
      self$addButtonSearchEventsObserver()
      self$addButtonSetQueryObserver()
      self$linkDiv <- LinkDiv$new(parentId = self$getDivLinksDescription(), 
                                  where = "beforeEnd")
      self$eventDiv <- EventDiv$new(parentId = self$getDivEventsDescription(),
                                    where = "beforeEnd")
    },
    
    insertUIlink = function(){
      ui <- self$getUI()
      jQuerySelector <- paste0("#",self$parentId)
      insertUI(
        selector = jQuerySelector,
        where = "beforeEnd",
        ui = ui,
        immediate = T
      )
    },
    
    destroy = function(){
      stop("why destroy this UI ?")
    },
    
    getDivEventsDescription = function(){
      return(paste0("eventsDescription",self$getDivId()))
    },
    
    getDivLinksDescription = function(){
      return(paste0("linksDescription",self$getDivId()))
    },
    
    getUI = function(){
      ui <- div(id = self$getDivId(),
                div(id = self$getDivEventsDescription()),
                div(id = self$getDivLinksDescription()),
        shiny::actionButton(inputId = self$getButtonSetQueryId(),
                            label = "Set Query"),
        shiny::actionButton(inputId = self$getButtonSearchEventsId(),
                            label = "Search events"),
        shiny::verbatimTextOutput(outputId = self$getResultsVerbatimId())
      )

    },
    
    setQueryDescription = function(){
      
    },
    
    searchEvents = function(){
      staticLogger$info("Searching events")
      self$setQuery()
      if (is.null(self$xmlSearchQuery)){
        staticLogger$info("xmlSearchQuery is null")
        text <- "Aucune requête"
      } else {
        staticLogger$info("\t Sending query")
        getTextResults_ <- function(results){
          Ncontexts <- length(unique(results$context))
          Nevents <- nrow(results)
          text <- paste0(Nevents, " couples d'", GLOBALevent, " - ", Ncontexts, " ", GLOBALparcours)
          return(text)
        }
        results <- GLOBALcon$sendQuery(self$xmlSearchQuery)
        text <- getTextResults_(results)
      }
      output[[self$getResultsVerbatimId()]] <- shiny::renderPrint(text)
    },
    
    setQuery = function(){
      staticLogger$info("setting Query")
      
      query <- XMLSearchQuery$new()
      
      staticLogger$info("\t adding eventNode to query")
      ## loop to get all events description in query : 
      
      for (eventTabpanel in GLOBALlistEventTabpanel$listEventTabpanel){
        if (!is.null(eventTabpanel$contextEnv$instanceSelection)){
          query <- eventTabpanel$contextEnv$instanceSelection$addEventNodeToQuery(query)
        }
      }
      
      ## no events selected
      if (length(query$listEventNodes) == 0){
        staticLogger$info("\t No events selected")
        self$xmlSearchQuery <- NULL
        return(NULL)
      }
      
      staticLogger$info("\t adding linkNode")
      ## loop to get all links in query : 
      for (linkEvents in self$listLinkEvents){
        query <- linkEvents$addLinkNode(query)
      }
      
      staticLogger$info("\t adding context to query")
      contextVector <- GLOBALcontextEnv$instanceSelection$context
      query$addContextNode(contextVector = contextVector)
      staticLogger$info("\t", length(contextVector), " contexts added")
      self$xmlSearchQuery <- query
    },
    
    addButtonSearchEventsObserver = function(){
      self$buttonSearchEventsObserver <- observeEvent(input[[self$getButtonSearchEventsId()]],{
        self$searchEvents()
      })
    },
    
    addButtonSetQueryObserver = function(){
      self$buttonSetQueryObserver <- observeEvent(input[[self$getButtonSetQueryId()]],{
        staticLogger$user("setQuery clicked")
        #self$setQuery()
        self$eventDiv$insertHTMLdescriptions()
      })
    },
    
    getDivId = function(){
      return(paste0("QueryBuilder",self$parentId))
    },
    
    getResultsVerbatimId = function(){
      return(paste0("VerbatimResults",self$getDivId()))
    },
    
    getButtonSetQueryId = function(){
      return(paste0("ButtonSetQuery",self$getDivId()))
    },
    
    getButtonSearchEventsId = function(){
      return(paste0("ButtonSearchEvents",self$getDivId()))
    }
  ),
  
  private=list(
    addEventNodeToQuery = function(event, query){
      eventTabpanel <- GLOBALlistEventTabpanel$listEventTabpanel[[event]]
      query <- eventTabpanel$contextEnv$instanceSelection$addEventNodeToQuery(query)
      return(query)
    }
  ))