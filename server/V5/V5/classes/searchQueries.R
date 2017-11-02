SearchQueries <- R6::R6Class(
  inherit = uiObject,
  "SearchQueries",
  
  public = list(
    searchQueriesObserver = NULL,
    validateButtonId = character(),
    queryViz = NULL,
    
    initialize = function(parentId, where, validateButtonId){
      super$initialize(parentId, where)
      self$validateButtonId <- validateButtonId
      self$insertUIsearchQueries()
      self$addSearchQueriesObserver()
      self$addSelectizeResultObserver()
    },
    
    insertUIsearchQueries = function(){
      jQuerySelector = paste0("#",self$parentId)
      ui <- self$getUI()
      insertUI(selector = jQuerySelector,
               where = "beforeEnd",
               ui = ui,
               immediate=T)
    },
    
    addSearchQueriesObserver = function(){
      self$searchQueriesObserver <- observeEvent(input[[self$getSearchQueriesButtonId()]],{
        self$updateSelectizeResult()
      })
    },
    
    addSelectizeResultObserver = function(){
      observeEvent(input[[self$getSelectizeResultId()]],{
        queryChoice <- input[[self$getSelectizeResultId()]]
        self$makeQueryViz(queryChoice)
      })
    },
    
    makeQueryViz = function(queryChoice){
      if (is.null(queryChoice) || queryChoice == ""){
        staticLogger$info("No query selected")
        return(NULL)
      }
      
      staticLogger$info("Timeline : ", queryChoice, "selected")
      queryChoice <- gsub(GLOBALquery,"",queryChoice)
      queryChoice <- as.numeric(queryChoice)
      lengthListResults <- length(GLOBALlistResults$listResults)
      bool <- queryChoice > lengthListResults
      if (bool){
        stop("queryChoice number not found in GLOBALlistResults ")
      }
      result <- GLOBALlistResults$listResults[[queryChoice]]
      self$queryViz <- QueryViz$new(result$XMLsearchQuery)
      output[[self$getQueryVizId()]] <- self$queryViz$getOutput()
    },
    
    getUI = function(){
      ui <- div (id = self$getDivQueriesId(),
           shiny::selectInput(inputId = self$getSelectizeResultId(),
                              label = GLOBALchooseQuery,
                              choices = NULL,
                              selected = NULL,
                              multiple = F),
           shiny::actionButton(inputId = self$getValidateButtonId(),
                               label = GLOBALvalidate),
           shiny::actionButton(inputId = self$getSearchQueriesButtonId(),
                               label = GLOBALsearchQueries),
      div(id = "visuXML",
          visNetwork::visNetworkOutput(outputId = self$getQueryVizId()))
        )
      return(ui)
    },
    
    getQueryVizId = function(){
      return(paste0("queryViz-",self$getDivQueriesId()))
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
    
    getDivQueriesId = function(){
      return(paste0("DivQueries",self$parentId))
    },
    
    getSelectizeResultId = function(){
      return(paste0("selectizeResultId-",self$getDivQueriesId()))
    },
    
    getValidateButtonId = function(){
      return(self$validateButtonId)
    },
    
    getSearchQueriesButtonId = function(){
      return(paste0("searchQueriesButtonId-",self$getDivQueriesId()))
    }
  )
)