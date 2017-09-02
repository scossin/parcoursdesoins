FilterNumeric <- R6::R6Class(
  "FilterNumeric",
  inherit = Filter,
  
  
  public=list(
    contextEnv = environment(),
    observersList = list(),
    valueEnv = environment(),
    numericGraphics = NULL,
    
    initialize = function(contextEnv, predicateName, dataFrame, parentId, where){
      staticLogger$info("Creating a new FilterNumeric object")
      super$initialize(contextEnv$eventNumber, predicateName, dataFrame, parentId, where)
      self$contextEnv <- contextEnv
      
      self$valueEnv <- new.env()
      self$valueEnv$numericValue <- NumericValues$new(dataFrame$value)
      
      self$makeUI()
      self$addNumericInputObservers()
      self$addSliderObserver()
      staticLogger$info("Trying to make plot")
    },
    
    makeUI = function(){
      staticLogger$info("Inserting FilterNumeric")
      jquerySelector <- private$getJquerySelector(self$parentId)
      insertUI(selector = jquerySelector, 
               where = self$where,
               ui = self$getUI(),
               immediate = T)
      staticLogger$info("End inserting")
    },
    
    updateSliderInputValues = function(){
      staticLogger$info("Updating slider")
      isolate({
        shiny::updateSliderInput(session,
                                 self$getObjectId(),
                                 label = NULL, 
                                 min = self$valueEnv$numericValue$minFloor,
                                 max =  self$valueEnv$numericValue$maxCeiling,
                                 value = c(self$valueEnv$numericValue$minChosen,
                                           self$valueEnv$numericValue$maxChosen))
      })
    },
    
    updateNumericInputValues = function(){
      staticLogger$info("Updating NumericInputValues")
      isolate({
      shiny::updateNumericInput(session, 
                                inputId = self$getNumericInputMinId(),
                                label="min",
                                value = self$valueEnv$numericValue$minChosen,
                                min = self$valueEnv$numericValue$minFloor,
                                max =  self$valueEnv$numericValue$maxCeiling,step = 1)
      
      shiny::updateNumericInput(session, 
                                inputId = self$getNumericInputMaxId(),
                                label="max",
                                value = self$valueEnv$numericValue$maxChosen,
                                min = self$valueEnv$numericValue$min,
                                max =  self$valueEnv$numericValue$max,step = 1)
      })
    },
    
    
    addSliderObserver = function(){
      o <- observeEvent(input[[self$getObjectId()]],{
        if (private$bugSlider){
          self$numericGraphics <- NumericGraphics$new(self$valueEnv, self$getGraphicsId(),where="beforeEnd")
          private$bugSlider <- FALSE
          return(NULL)
        }
        staticLogger$user("slider", self$getObjectId(), "changed")
        numericValues <- input[[self$getObjectId()]]
        minValue <- numericValues[1]
        maxValue <- numericValues[2]
        self$valueEnv$numericValue$setMinMaxChosen(minValue,maxValue)
        self$updateNumericInputValues()
        self$numericGraphics$remakePlot()
      })
      
      lengthList <- length(self$observersList)
      self$observersList[[lengthList+1]] <- o
      return(NULL)
    },
    
    addNumericInputObservers = function(){
      ## a list of observeEvent
      o <- observeEvent(
        c(input[[self$getNumericInputMinId()]],
          input[[self$getNumericInputMaxId()]]),{
            if (private$bugNumericInput){
              private$bugNumericInput <- FALSE
              return(NULL)
            }
            minValue <- input[[self$getNumericInputMinId()]]
            maxValue <- input[[self$getNumericInputMaxId()]]
            staticLogger$user(self$getNumericInputMinId(), "or",
                              self$getNumericInputMaxId(), "changed")
            self$valueEnv$numericValue$setMinMaxChosen(minValue,maxValue)
            
            ### updating
            self$updateSliderInputValues()
            self$numericGraphics$remakePlot()
      })
      lengthList <- length(self$observersList)
      self$observersList[[lengthList+1]] <- o
      return(NULL)
    },
    
    destroy = function(){
      cat("destroying", self$getObjectId(), "\n")
      for (observer in self$observersList){
        observer$destroy()
      }
      self$observersList <- NULL
      jQuerySelector <- private$getJquerySelector(self$getDivId())
      try(removeUI(selector = jQuerySelector))
      removeUI(selector = paste0("#testplot"))
      # session$sendCustomMessage(type = "removeId", 
      #                           message = list(objectId = private$getDivId()))
    },

    getUI = function(){
      self$valueEnv$numericValue$describe()
      ui <- div(id = self$getDivId(),
          div(id = private$getDivNumericFilterId(),
          shiny::sliderInput(self$getObjectId(),
                             label = NULL, 
                             min = self$valueEnv$numericValue$minFloor, 
                             max = self$valueEnv$numericValue$maxCeiling,
                             value = c(self$valueEnv$numericValue$minFloor,
                                       self$valueEnv$numericValue$maxCeiling)),
          shiny::numericInput(self$getNumericInputMinId(),
                              label="min",
                              value = self$valueEnv$numericValue$minFloor,
                              min = self$valueEnv$numericValue$minFloor,
                              max = self$valueEnv$numericValue$maxCeiling,step = 1,
                              width = "100px"),
          shiny::numericInput(self$getNumericInputMaxId(),
                              label="max",
                              value = self$valueEnv$numericValue$maxCeiling,
                              min = self$valueEnv$numericValue$minFloor,
                              max = self$valueEnv$numericValue$maxCeiling,step = 1,
                              width = "100px")
      ), ## end first div, 
      
      div(id = self$getGraphicsId(), class = "NumericGraphics")
          #shiny::plotOutput(outputId = self$getPlotId(),width = "80%", height="300px"))
      ) ## end second
      return(ui)
    }, 
    
    getDivId = function(){
      return(paste0("divGraphicsAndFilter", self$contextEnv$eventNumber, self$predicateName))
    },
    
    getGraphicsId = function(){
      return(paste0("Graphics",self$contextEnv$eventNumber, self$predicateName))
    },
    
    getPlotId = function(){
      return(paste0("Plot",self$contextEnv$eventNumber, self$predicateName))
    },
    
    getNumericInputMaxId = function(){
      return(paste0("numericMax",self$contextEnv$eventNumber, self$predicateName))
    },
    
    getNumericInputMinId = function(){
      return(paste0("numericMin",self$contextEnv$eventNumber, self$predicateName))
    },
    
    getObjectId = function(){
      return(paste0("slider",self$contextEnv$eventNumber, self$predicateName))
    },
    
    getChoosenEvents = function(){
      stop("setContext not implemented !")
    },

    setContext = function(){
      stop("setContext not implemented !")
    }
  ),
  
  private=list(
    getDivNumericFilterId = function(){
      filterId <- self$getObjectId()
      return(paste0("divNumericFilter",filterId))
    },
    
    bugSlider = T,
    bugNumericInput = T
  )
)

# test <- data.frame(context = "test", event = "test", value=c(1:1000))
# filterNumeric <- FilterNumeric$new(1, "inEtab",test)
# filterNumeric$dataFrame$value
# filterNumeric$getUI()

