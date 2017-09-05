FilterNumericDuration <- R6::R6Class(
  "FilterNumericDuration",
  inherit = FilterNumeric,
  
  public = list(
    initialize = function(eventNumber, predicateName, dataFrame, parentId, where){
      super$initialize(eventNumber,predicateName, dataFrame, parentId, where)
      staticLogger$info("Adding Observer Make UI")
      self$addObserverMakeUI()
      staticLogger$info("Creating a new FilterNumericDuration object")
      self$addDurationObserver()
    },
    
    insertDurationUI = function(){
      jQuerySelector = paste0("#",self$getGraphicsId())
      insertUI(selector = jQuerySelector,
               where = "afterBegin",
              ui = self$getDurationUI())
    },
    
    # getObjectId = function(){
    #   return(self$getDurationUIid())
    # },
    
    getDurationUI = function(){
      shinyWidgets::awesomeRadio(inputId = self$getDurationUIid(),
                                 label = "",
                                 choices=c(GLOBALminutes,GLOBALhours,GLOBALdays,GLOBALweeks,GLOBALmonths),
                                 selected = GLOBALdays,
                                 inline=T)
    },
    
    addObserverMakeUI = function(){
      staticLogger$info("Inserting duration UI")
      observeEvent(input[[self$getObjectId()]],{
        self$insertDurationUI()
        self$updateDuration(GLOBALdays)
      },once = T)
      
    },
    
    addDurationObserver = function(){
      o <- observeEvent(input[[self$getDurationUIid()]],{
        durationChoice <- input[[self$getDurationUIid()]]
        self$updateDuration(durationChoice)
      })
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
    updateX = function(durationChoice){
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
      
    }
  )
)
