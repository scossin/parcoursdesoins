FilterDate <- R6::R6Class(
  "FilterDate",
  inherit = Filter,
  
  public = list(
    observersList = list(),
    valueEnv = environment(),
    dateGraphics = NULL,
    
    initialize = function(contextEnv, predicateName, dataFrame, parentId, where){
      staticLogger$info("Creating a new FilterDate object")
      super$initialize(contextEnv, predicateName, dataFrame, parentId, where)
      dateValues <- DateValues$new(dataFrame$value)
      self$makeUI()
      self$dateGraphics <- DateGraphics$new(dateValues, 
                                            self$getDivFilterId(),
                                            where="beforeEnd")
    },
    
    getDescription = function(){
      description <- paste0(self$predicateName,"\t minDate: ",self$dateGraphics$dateValues$getMinDate(),
                            "\n\t maxDate: ", self$dateGraphics$dateValues$getMinDate())
      return(description)
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
      return(paste0("FilterDate-",self$parentId))
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
      staticLogger$info("Destroying FilterDate :", self$getObjectId())
      
      staticLogger$info("\t removing dateGraphics")
      if (!is.null(self$dateGraphics)){
        self$dateGraphics$destroy()
      }
      staticLogger$info("\t removing every observer")
      for (observer in self$observersList){
        staticLogger$info("\t \t done")
        observer$destroy()
      }
      self$observersList <- NULL
      
      staticLogger$info("\t removing UI")
      self$removeUI()
      staticLogger$info("End destroying FilterDate :", self$getObjectId())
    }
    
  ),
  
  private = list(
    
  )
)
