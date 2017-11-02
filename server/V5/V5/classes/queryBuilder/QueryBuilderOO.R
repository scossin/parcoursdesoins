QueryBuilder <- R6::R6Class(
  inherit = uiObject,
  "QueryBuilder",
  
  public = list(
    xmlSearchQuery = NULL,
    buttonSearchEventsObserver = NULL,
    buttonSetQueryObserver = NULL,
    buttonLinkEvents = NULL,
    linkDescription = NULL,
    eventDescription = NULL,
    contextDescription = NULL,
    hideShowObserver = NULL,
    queryViz = NULL,
    currentHideShowLabel = GLOBALshow,
    
    initialize = function(parentId, where){
      staticLogger$info("New QueryBuilder")
      super$initialize(parentId, where)
      self$insertUIlink()
      self$addButtonSearchEventsObserver()
      self$addButtonSetQueryObserver()
      self$addHideShowObserver()
      self$linkDescription <- LinkDescription$new(parentId = self$getDivLinksDescription(), 
                                  where = "beforeEnd")
      self$eventDescription <- EventDescription$new(parentId = self$getDivEventsDescription(),
                                    where = "beforeEnd")
      self$contextDescription <- ContextDescription$new(parentId = self$getDivContextDescription(),
                             where = "beforeEnd")
      private$hideHideShowButton()
    },
    
    addHideShowObserver = function(){
      self$hideShowObserver <- observeEvent(input[[self$getHideShowId2()]],{
        staticLogger$info("HideShow button clicked QueryBuilder")
        
        if (self$currentHideShowLabel == GLOBALshow){
          private$showHideShowButton()
        } else {
          private$hideHideShowButton()
        }
        self$updateHideShowButton()
      },ignoreInit = T)
      return(NULL)
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
    
    getDivContextDescription = function(){
      return(paste0("ContextDescription",self$getDivId()))
    },
    
    getDivEventsDescription = function(){
      return(paste0("eventsDescription",self$getDivId()))
    },
    
    getDivLinksDescription = function(){
      return(paste0("linksDescription",self$getDivId()))
    },
    
    getHideShowId2 = function(){
      return(paste0("HideShowButtonQueryBuilder-",self$getDivId()))
    },
    
    updateHideShowButton = function(){
      bool <- self$currentHideShowLabel == GLOBALshow
      if (bool){
        self$currentHideShowLabel <- GLOBALhide
      } else {
        self$currentHideShowLabel <- GLOBALshow
      }
      shiny::updateActionButton(session = session, 
                                inputId = self$getHideShowId2(),
                                label = self$currentHideShowLabel)
    },
    
    getUI = function(){
      ui <- div(
        div(
          h1(GLOBALqueryBuilder),
          shiny::actionButton(inputId = self$getHideShowId2(),
                              label = self$currentHideShowLabel)
          # shinyWidgets::radioGroupButtons(inputId = self$getHideShowId2(),
          #                                 label ="",choices = c(GLOBALshow, GLOBALhide),
          #                                 selected = GLOBALshow)
        ),
        div(id = self$getDivId(),
                div(id = self$getDivContextDescription()),
            shiny::tags$hr(style="border-top: dotted 1px;"),
                div(id = self$getDivEventsDescription()),
            shiny::tags$hr(style="border-top: dotted 1px;"),
                div(id = self$getDivLinksDescription()),
            shiny::tags$hr(style="border-top: dotted 1px;"),
        shiny::verbatimTextOutput(outputId = self$getResultsVerbatimId())
      )
      # div(id = "visuXML",
      #     visNetwork::visNetworkOutput(outputId = self$getQueryVizId())
      #   )
      )
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
        xmlSearchQuery <- self$xmlSearchQuery
        save(xmlSearchQuery, file="tempQuery2.rdata")
        results <- GLOBALcon$sendQuery(self$xmlSearchQuery)
        if (nrow(results) != 0){ ## add results to be further analyzed
          result <- Result$new(self$xmlSearchQuery)
          GLOBALlistResults$addResult(result)
        }
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
      for (linkEvents in self$linkDescription$listLinkEvents){
        query <- linkEvents$addLinkNode(query)
      }
      
      staticLogger$info("\t adding context to query")
      contextVector <- GLOBALcontextEnv$instanceSelection$context
      query$addContextNode(contextVector = contextVector)
      staticLogger$info("\t", length(contextVector), " contexts added")
      self$xmlSearchQuery <- query
      self$makeQueryViz()
    },
    
    makeQueryViz = function(){
      self$queryViz <- QueryViz$new(self$xmlSearchQuery)
      output[[self$getQueryVizId()]] <- self$queryViz$getOutput()
    },
    
    addButtonSearchEventsObserver = function(){
      self$buttonSearchEventsObserver <- observeEvent(input[[self$getButtonSearchEventsId()]],{
        self$searchEvents()
      })
    },
    
    addButtonSetQueryObserver = function(){
      self$buttonSetQueryObserver <- observeEvent(input[[self$getButtonSetQueryId()]],{
        staticLogger$user("setQuery clicked")
        self$eventDescription$insertHTMLdescriptions()
        self$contextDescription$insertHTMLdescription()
        self$linkDescription$insertHTMLdescription()
        self$setQuery()
      })
    },
    
    getDivId = function(){
      return(paste0("QueryBuilder",self$parentId))
    },
    
    getQueryVizId = function(){
      return(paste0("queryViz-",self$getDivId()))
    },
    
    getResultsVerbatimId = function(){
      return(paste0("VerbatimResults",self$getDivId()))
    },
    
    getButtonSetQueryId = function(){
      return(GLOBALsetQuery)
    },
    
    getButtonSearchEventsId = function(){
      return(GLOBALsearchEvents)
    }
  ),
  
  private=list(
    addEventNodeToQuery = function(event, query){
      eventTabpanel <- GLOBALlistEventTabpanel$listEventTabpanel[[event]]
      query <- eventTabpanel$contextEnv$instanceSelection$addEventNodeToQuery(query)
      return(query)
    },
    
    hideHideShowButton = function(){
      staticLogger$info("Sending Js function to hide QueryBuilder")
      session$sendCustomMessage(type = "displayHideId",
                                message = list(objectId = self$getDivId()))
    },
    showHideShowButton = function(){
      staticLogger$info("Sending Js function to show QueryBuilder")
      session$sendCustomMessage(type = "displayShowId",
                                message = list(objectId = self$getDivId()))
    }
  ))