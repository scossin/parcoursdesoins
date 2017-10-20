Sankey <- R6::R6Class(
  "Sankey",
  inherit=uiObject,
  
  public = list(
    result = NULL,
    searchQueriesObserver = NULL,
    validateObserver = NULL,
    
    initialize = function(parentId, where){
      staticLogger$info("New Sankey")
      super$initialize(parentId, where)
      self$insertSankeyUI()
      self$addSearchQueriesObserver()
      self$addValidateObserver()
      self$addMakeSankeyObserver()
    },
    
    insertSankeyUI = function(){
      jQuerySelector = paste0("#",self$parentId)
      insertUI(
        selector = jQuerySelector, 
        where = self$where,
        ui = self$getUI(),
        immediate = F)
    },
    
    getUI = function(){
      ui <- div(id = self$getDivId(),
                shiny::selectInput(inputId = self$getSelectizeResultId(),
                                   label = GLOBALchooseQuery,
                                   choices = NULL,
                                   selected = NULL,
                                   multiple = F),
                shiny::actionButton(inputId = self$getValidateButtonId(),
                                    label = GLOBALvalidate),
                shiny::actionButton(inputId = self$getSearchQueriesButtonId(),
                                    label = GLOBALsearchQueries),
                shiny::actionButton(inputId = self$getButtonMakeSankeyId(),
                                    label = "MakeSankey")
      )
    },
    
    addValidateObserver = function(){
      self$validateObserver <- observeEvent(input[[self$getValidateButtonId()]],{
        staticLogger$user("Validate Button Sankey clicked ")
        
        queryChoice <- input[[self$getSelectizeResultId()]]

        if (is.null(queryChoice) || queryChoice == ""){
          staticLogger$info("No query selected")
          return(NULL)
        }
        
        staticLogger$info("Sankey : ", queryChoice, "selected")
        
        queryChoice <- gsub(GLOBALquery,"",queryChoice)
        queryChoice <- as.numeric(queryChoice)
        lengthListResults <- length(GLOBALlistResults$listResults)
        bool <- queryChoice > lengthListResults
        if (bool){
          stop("queryChoice number not found in GLOBALlistResults ")
        }
        self$result <- GLOBALlistResults$listResults[[queryChoice]]
        self$setEventTabpanel()
      })
    },
    
    setEventTabpanel = function(){
      getContextEvents_ = function(resultDf,eventNumber){
        print(nrow(resultDf))
        event <- paste0("event",eventNumber)
        bool <- event %in% colnames(resultDf)
        if (!bool){
          stop(event, "unfound in resultDf colnames : ", colnames(resultDf))
        }
        bool <- colnames(resultDf) %in% c("context",event)
        if (sum(bool)!=2){
          stop("context unfound in resultDf colnames : ", colnames(resultDf))
        }
        contextEvents <- resultDf[,bool]
        return(contextEvents)
      }
      
      staticLogger$info("setEventTabpanel of Sankey")
      xmlSearchQuery <- self$result$XMLsearchQuery
      Nevents <- length(xmlSearchQuery$listEventNodes)
      context <- self$result$resultDf$context
      GLOBALSankeylistEventTabpanel$emptyTabpanel() ## empty before adding new
      for (eventNode in xmlSearchQuery$listEventNodes){
        eventNumber <- xmlSearchQuery$getEventNumber(eventNode)
        eventType <- xmlSearchQuery$getEventTypeByEventNode(eventNode)
        eventTabpanel <- EventTabpanel$new(eventNumber = eventNumber,
                                           context = context,
                                           tabsetPanelId = GLOBALeventTabSetPanelSankey)
        contextEvents <- getContextEvents_(resultDf = self$result$resultDf,
                                           eventNumber = eventNumber)
        eventTabpanel$createInstanceSelectionEvent(contextEvents = contextEvents, 
                                                   eventType = eventType)
        GLOBALSankeylistEventTabpanel$addEventTabpanel(eventTabpanel)
      }

    },

    
    updateSelectizeResult = function(){
      choices <- NULL
      iter <- 1
      for (result in GLOBALlistResults$listResults){
        choices <- append (choices, paste0(GLOBALquery, iter))
        iter <- iter + 1
      }
      updateSelectInput(session,
                        inputId = self$getSelectizeResultId(),
                        label = GLOBALchooseQuery,
                        choices = choices)
    },
    
    getDivId = function(){
      return(paste0("divSankey-",self$parentId))
    },
    
    getSelectizeResultId = function(){
      return(paste0("selectizeResultId-",self$getDivId()))
    },
    
    getValidateButtonId = function(){
      return(paste0("buttonValidateResult-",self$getDivId()))
    },
    
    getSearchQueriesButtonId = function(){
      return(paste0("searchQueriesButtonId-",self$getDivId()))
    },
    
    getButtonMakeSankeyId = function(){
      return(paste0("MakeSankeyId-",self$getDivId()))
    },
    
    
    addMakeSankeyObserver = function(){
      observeEvent(input[[self$getButtonMakeSankeyId()]],{
        for (eventTabpanel in GLOBALSankeylistEventTabpanel$listEventTabpanel){
          instanceSelection <- eventTabpanel$contextEnv$instanceSelection
          value <- instanceSelection$getValue4Sankey()
          print(value)
          break
        }
      })
    },
    
    addSearchQueriesObserver = function(){
      self$searchQueriesObserver <- observeEvent(input[[self$getSearchQueriesButtonId()]],{
        self$updateSelectizeResult()
      })
    },
    
    addResult = function(result){
      bool <- inherits(result, "Result")
      if (!bool){
        stop("result must be instance of Result")
      }
      listLength <- length(self$listResults)
      self$listResults[[listLength+1]] <- eventTabpanel
    }
  )
)