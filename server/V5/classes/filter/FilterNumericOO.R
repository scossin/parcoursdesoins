FilterNumeric <- R6::R6Class(
  "FilterNumeric",
  inherit = Filter,
  
  
  public=list(
    contextEnv = environment(),
    observersList = list(),
    x = numeric(),
    numericGraphics = NULL,
    
    initialize = function(contextEnv, predicateName, dataFrame, parentId, where){
      staticLogger$info("Creating a new FilterNumeric object")
      super$initialize(contextEnv$eventNumber, predicateName, dataFrame, parentId, where)
      self$contextEnv <- contextEnv
      private$toNumeric()
      self$x <- dataFrame$value
      self$addNumericInputObservers()
      self$addSliderObserver()
      self$makeUI()
      staticLogger$info("Trying to make plot")
     
      #self$makePlot(minimum = private$getMin(), maximum = private$getMax())
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
    
    updateSliderInputValues = function(minValue, maxValue){
      staticLogger$info("Updating slider")
      isolate({
        if (any(is.na(as.numeric(minValue, maxValue)))){
          staticLogger$info("minValue and maxValue Incorrect !")
          return(NULL)
        }
        
        if (maxValue < minValue){
          staticLogger$info("MaxValue less to minvalue !")
          staticLogger$info("Reseting NumericInputValues")
          self$updateNumericInputValues(minValue = minValue, maxValue = minValue)
          return(NULL)
        }
        shiny::updateSliderInput(session,
                                 self$getObjectId(),
                                 label = NULL, 
                                 min=private$getMin(), 
                                 max=private$getMax(),
                                 value = c(minValue,maxValue))
      })
    },
    
    updateNumericInputValues = function(minValue, maxValue){
      staticLogger$info("Updating NumericInputValues")
      isolate({
      shiny::updateNumericInput(session, 
                                inputId = self$getNumericInputMinId(),
                                label="min",
                                value=minValue,
                                min=private$getMin(),
                                max=private$getMax(),step = 1)
      
      shiny::updateNumericInput(session, 
                                inputId = self$getNumericInputMaxId(),
                                label="max",
                                value=maxValue,
                                min=private$getMin(),
                                max=private$getMax(),step = 1)
      })
    },
    
    
    addSliderObserver = function(){
      o <- observeEvent(input[[self$getObjectId()]],{
        if (private$bugSlider){
          self$numericGraphics <- NumericGraphics$new(self$x, self$getGraphicsId(),where="beforeEnd")
          private$bugSlider <- FALSE
          return(NULL)
        }
        staticLogger$user("slider", self$getObjectId(), "changed")
        numericValues <- input[[self$getObjectId()]]
        minValue <- numericValues[1]
        maxValue <- numericValues[2]
        self$updateNumericInputValues(minValue,maxValue)
        #self$makePlot(minValue,maxValue)
      })
      
      lengthList <- length(self$observersList)
      self$observersList[[lengthList+1]] <- o
      return(NULL)
    },
    
    addNumericInputObservers = function(){
      ## a list of observeEvent
      o <- observeEvent(c(input[[self$getNumericInputMinId()]],
                     input[[self$getNumericInputMaxId()]]),{
                       if (private$bugNumericInput){
                         private$bugNumericInput <- FALSE
                         return(NULL)
                       }            
                       staticLogger$user(self$getNumericInputMinId(), "or",
                                         self$getNumericInputMaxId(), "changed")
                       minValue <- input[[self$getNumericInputMinId()]]
                       maxValue <- input[[self$getNumericInputMaxId()]]
                       
                       ### updating
                       self$updateSliderInputValues(minValue, maxValue)
                       #self$makePlot(minValue,maxValue)
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
      ui <- div(id = self$getDivId(),
          div(id = private$getDivNumericFilterId(),
          shiny::sliderInput(self$getObjectId(),
                              label = NULL, 
                             min=private$getMin(), 
                             max=private$getMax(),
                             value = c(private$getMin(),private$getMax())),
          shiny::numericInput(self$getNumericInputMinId(),
                              label="min",
                              value=private$getMin(),
                              min=private$getMin(),
                              max=private$getMax(),step = 1,
                              width = "100px"),
          shiny::numericInput(self$getNumericInputMaxId(),
                              label="max",
                              value=private$getMax(),
                              min=private$getMin(),
                              max=private$getMax(),step = 1,
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
    
    # makePlot = function(minimum, maximum){
    #   staticLogger$info("Setting or reseting plot")
    #   output[[self$getPlotId()]] <- renderPlot({
    #     x <- self$x
    #     bool <- x >= minimum &  x <= maximum
    #     colors <- ifelse (bool, "blue","black")
    #     filling <- ifelse (bool, 19, 1)
    #     plot(x, col=colors, pch = filling)
    #     abline(h=minimum, col="blue")
    #     abline(h=maximum, col="blue")
    #   }, width="auto",height="auto")
    # },
    
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
    
    toNumeric = function(){
      staticLogger$info("Setting value to numeric for FilterNumeric")
      self$dataFrame$value <- as.numeric(self$dataFrame$value)
      bool <- is.na(self$dataFrame$value)
      if (all(bool)){
        stop("dataFrame for NumericFilter contains only NA value")
      }
      staticLogger$info(sum(bool), "NA value")
      return(NULL)
    },

    getMin = function(){
      return(floor(min(self$x, na.rm=T)))
    },
    
    getMax = function(){
      return(ceiling(max(self$x, na.rm=T)))
    },
    
    bugSlider = T,
    bugNumericInput = T
  )
)

# test <- data.frame(context = "test", event = "test", value=c(1:1000))
# filterNumeric <- FilterNumeric$new(1, "inEtab",test)
# filterNumeric$dataFrame$value
# filterNumeric$getUI()

