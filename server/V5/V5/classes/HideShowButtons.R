HideShowButton <- R6::R6Class(
  inherit = uiObject,
  "HideShowButton",
  
  public = list(
    hideShowObserver = NULL,
    divIdToHide = character(),
    currentHideShowLabel = GLOBALhide,
    
    initialize = function(parentId, where, divIdToHide, boolHideFirst = T){
      staticLogger$info("New HideShow button")
      super$initialize(parentId, where)
      self$divIdToHide <- divIdToHide
      self$insertButton()
      self$addHideShowObserver()
      if (boolHideFirst){
        private$hideHideShowButton() ## hide
        self$updateHideShowButton()
      }
    }, 
    
    insertButton = function(){
      ui <- shiny::actionButton(inputId = self$getHideShowId(),
                          label = self$currentHideShowLabel)
      jQuerySelector = paste0("#",self$parentId)
      insertUI(selector = jQuerySelector,
               where = self$where,
              ui = ui)
    },
    
    updateHideShowButton = function(){
      bool <- self$currentHideShowLabel == GLOBALshow
      if (bool){
        self$currentHideShowLabel <- GLOBALhide
      } else {
        self$currentHideShowLabel <- GLOBALshow
      }
      shiny::updateActionButton(session = session, 
                                inputId = self$getHideShowId(),
                                label = self$currentHideShowLabel)
    },
    
    getHideShowId = function(){
      return(paste0("HideShowButton-",self$parentId))
    },
    
    addHideShowObserver = function(){
      self$hideShowObserver <- observeEvent(input[[self$getHideShowId()]],{
        staticLogger$info("HideShow button clicked")
        if (self$currentHideShowLabel == GLOBALshow){
          private$showHideShowButton()
        } else {
          private$hideHideShowButton()
        }
        self$updateHideShowButton()
      },ignoreInit = T)
      return(NULL)
    }
    ),
  
  private = list(
    hideHideShowButton = function(){
      staticLogger$info("Sending Js function to hide a div")
      session$sendCustomMessage(type = "displayHideId",
                                message = list(objectId = self$divIdToHide))
    },
    showHideShowButton = function(){
      staticLogger$info("Sending Js function to show a div")
      session$sendCustomMessage(type = "displayShowId",
                                message = list(objectId = self$divIdToHide))
    }
  )
)

# rm(list=ls())
# load("tempQuery2.rdata")
# xmlSearchQuery$listEventNodes
