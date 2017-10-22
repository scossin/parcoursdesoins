SearchQueries <- R6::R6Class(
  inherit = uiObject,
  "SearchQueries",
  
  public = list(
    searchQueriesObserver = NULL,
    validateButtonId = character(),
    
    initialize = function(parentId, where, validateButtonId){
      super$initialize(parentId, where)
      self$validateButtonId <- validateButtonId
      self$insertUIsearchQueries()
      self$addSearchQueriesObserver()
      
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
                               label = GLOBALsearchQueries))
      return(ui)
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