FilterCategorical <- R6::R6Class(
  "FilterCategorical",
  inherit = Filter,
  
  public = list(
    observersList = list(),
    valueEnv = environment(),
    categoricalGraphics = NULL,
    
    initialize = function(contextEnv, predicateName, dataFrame, parentId, where){
      staticLogger$info("Creating a new FilterCategorical object")
      super$initialize(contextEnv, predicateName, dataFrame, parentId, where)
      self$valueEnv <- new.env()
      self$valueEnv$categoricalValues <- CategoricalValues$new(dataFrame$value)
      self$makeUI()
      self$categoricalGraphics <- CategoricalGraphics$new(self$valueEnv, 
                                                  self$getDivFilterId(),
                                                  where="beforeEnd")
    },
    
    makeUI = function(){
      jquerySelector <- private$getJquerySelector(self$parentId)
      insertUI(selector = jquerySelector, 
               where = self$where,
               ui = self$getUI(),
               immediate = T)
    },
    
    getUI = function(){
      ui <- div(id = self$getDivId(),
                div(id = self$getDivFilterId()), ## end first div, 
                div(class="textOutputSelection",shiny::textOutput(self$getTextInfoId(),inline = T))
      )
      return(ui)
    }, 
    
    getObjectId = function(){
      return(paste0("FilterCategorical-",self$parentId))
    },
    
    getDivId = function(){
      return(paste0("div",self$getObjectId()))
    },
    
    getDivFilterId = function(){
      return(paste0("divFilter",self$getDivId()))
    },
    
    getGraphicsId = function(){
      return(paste0("Graphics",self$getDivId()))
    },
    
    getTextInfoId = function(){
      return(paste0("TextInfo",self$getDivId()))
    },
    
    removeUI = function(){
      jQuerySelector <- private$getJquerySelector(self$getDivId())
      removeUI(selector = jQuerySelector)
    },
    
    destroy = function(){
      staticLogger$info("Destroying FilterCategorical :", self$getObjectId())
      
      staticLogger$info("\t removing categoricalGraphics")
      if (!is.null(self$categoricalGraphics)){
        self$categoricalGraphics$destroy()
      }
      staticLogger$info("\t removing every observer")
      for (observer in self$observersList){
        staticLogger$info("\t \t done")
        observer$destroy()
      }
      self$observersList <- NULL
      
      staticLogger$info("\t removing environment")
      self$valueEnv <- NULL
      
      staticLogger$info("\t removing UI")
      self$removeUI()
      staticLogger$info("End destroying FilterCategorical :", self$getObjectId())
    }
    
  ),
  
  private = list(
    
  )
)