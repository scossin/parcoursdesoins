FilterNumericDuration <- R6::R6Class(
  "FilterNumericDuration",
  inherit = FilterNumeric,
  
  
  public = list(
    durationObserver = NULL,
    
    initialize = function(contextEnv, predicateName, dataFrame, parentId, where){
      super$initialize(contextEnv,predicateName, dataFrame, parentId, where)
      self$addObserverMakeUI()
      self$addDurationObserver()
      staticLogger$info("Creating new FilterNumericDuration object : ", self$getObjectId())
    },
    
    updateDataFrame = function(){
      super$updateDataFrame()
      self$updateDuration(private$durationChoice)
    },

    getXMLpredicateNode = function(){
      tempQuery <- XMLSearchQuery$new()
      predicateNode <- tempQuery$makePredicateNode(predicateClass = "numeric",
                                                   predicateType = self$predicateName,
                                                   minValue = private$toSeconds(self$valueEnv$numericValue$minChosen),
                                                   maxValue = private$toSeconds(self$valueEnv$numericValue$maxChosen))
      return(predicateNode)
    },
    
    insertDurationUI = function(){
      jQuerySelector = paste0("#",self$getGraphicsId())
      insertUI(selector = jQuerySelector,
               where = "afterBegin",
              ui = self$getDurationUI())
    },
    
    getDescription = function(){
      durationChoice <- input[[self$getDurationUIid()]]
      description <- paste0(self$predicateName,
                            "\t minValue: ",self$valueEnv$numericValue$minChosen, " ", durationChoice,
                            "\n\t maxValue: ", self$valueEnv$numericValue$maxChosen, " ", durationChoice)
      return(description)
    },
    
    getObjectId = function(){
      return(paste0("FilterNumericDuration-",self$parentId))
    },
    
    getDurationUI = function(){
      shinyWidgets::awesomeRadio(inputId = self$getDurationUIid(),
                                 label = "",
                                 choices=c(GLOBALminutes,GLOBALhours,GLOBALdays,GLOBALweeks,GLOBALmonths),
                                 selected = private$durationChoice,
                                 inline=T)
    },
    
    addObserverMakeUI = function(){
      observeEvent(input[[self$getSliderId()]],{
        self$insertDurationUI()
        self$updateDuration(GLOBALdays)
      },once = T)
      
    },
    
    addDurationObserver = function(){
      self$durationObserver <- observeEvent(input[[self$getDurationUIid()]],{
        durationChoice <- input[[self$getDurationUIid()]]
        self$updateDuration(durationChoice)
      })
    },
    
    destroy = function(){
      staticLogger$info("Destroying FilterNumericDuration object : ", self$getObjectId())
      staticLogger$info("\t Removing duration observer ... ")
      if (!is.null(self$durationObserver)){
        self$durationObserver$destroy()
        staticLogger$info("\t \t done")
      }
      super$destroy()
      staticLogger$info("End destroying FilterNumericDuration object : ", self$getObjectId())
    },
    
    updateDuration = function(durationChoice){
      private$updateX(durationChoice)
      self$updateNumericInputValues()
      self$updateSliderInputValues()
      self$numericGraphics$remakePlot()
    },
    
    getDurationUIid = function(){
      paste0("Duration", self$getObjectId())
    }
  ),
  
  private = list(
    durationChoice = GLOBALdays,
    
    updateX = function(durationChoice){
      private$durationChoice <- durationChoice
      
      x <- self$dataFrame$value
      if (durationChoice == GLOBALminutes){
        x <- x / 60
        self$valueEnv$numericValue$setX(x) 
        return(NULL)
      }
      
      if (durationChoice == GLOBALhours){
        x <- x / (60*60)
        self$valueEnv$numericValue$setX(x) 
        return(NULL)
      }
      
      if (durationChoice == GLOBALdays){
        x <- x / (60*60*24)
        self$valueEnv$numericValue$setX(x) 
        return(NULL)
      }
      
      if (durationChoice == GLOBALweeks){
        x <- x / (60*60*24*7)
        self$valueEnv$numericValue$setX(x) 
        return(NULL)
      }
      
      if (durationChoice == GLOBALmonths){
        x <- x / (60*60*24*30.42)
        self$valueEnv$numericValue$setX(x)
        return(NULL)
      }
      
    },
    
    toSeconds = function(x){
      durationChoice <- private$durationChoice
      if (durationChoice == GLOBALminutes){
        x <- x * 60
        return(x)
      }
      
      if (durationChoice == GLOBALhours){
        x <- x * (60*60)
        return(x)
      }
      
      if (durationChoice == GLOBALdays){
        x <- x * (60*60*24)
        return(x)
      }
      
      if (durationChoice == GLOBALweeks){
        x <- x * (60*60*24*7)
        return(x)
      }
      
      if (durationChoice == GLOBALmonths){
        x <- x * (60*60*24*30.42)
        return(x)
      }
    }
  )
)
