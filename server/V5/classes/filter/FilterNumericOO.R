FilterNumeric <- R6::R6Class(
  "FilterNumeric",
  inherit = Filter,
  
  
  public=list(
    contextEnv = environment(),
    observersList = list(),
    
    initialize = function(contextEnv, predicateName, dataFrame, parentId, where){
      super$initialize(contextEnv$eventNumber, predicateName, dataFrame, parentId, where)
      self$contextEnv <- contextEnv
      private$toNumeric()
      self$makeUI()
      self$makePlot(minimum = private$getMin(), maximum = private$getMax())
      self$addPrivateObservers()
    },
    
    makeUI = function(){
      jquerySelector <- private$getJquerySelector(self$parentId)
      insertUI(selector = jquerySelector, 
               where = self$where,
               ui = self$getUI())
    },
    
    updateSliderInputValues = function(minValue, maxValue){
      isolate({
        if (any(is.na(as.numeric(minValue, maxValue)))){
          return(NULL)
        }
        
        if (maxValue < minValue){
          self$updateNumericInputValues(minValue = minValue, maxValue = minValue)
          return(NULL)
        }
        cat("updating slider value")
        shiny::updateSliderInput(session,
                                 self$getObjectId(),
                                 label = NULL, 
                                 min=private$getMin(), 
                                 max=private$getMax(),
                                 value = c(minValue,maxValue))
      })
    },
    
    updateNumericInputValues = function(minValue, maxValue){
      cat("updating numeric Input...")
      isolate({
        print("Slider get modified")
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
    
    addPrivateObservers = function(){
      ## a list of observeEvent
      self$observersList <- list(observeEvent(input[[self$getObjectId()]],{
        numericValues <- input[[self$getObjectId()]]
        minValue <- numericValues[1]
        maxValue <- numericValues[2]
        self$updateNumericInputValues(minValue,maxValue)
        self$makePlot(minValue,maxValue)
      }),
      
      observeEvent(c(input[[self$getNumericInputMinId()]],
                     input[[self$getNumericInputMaxId()]]),{
                       minValue <- input[[self$getNumericInputMinId()]]
                       maxValue <- input[[self$getNumericInputMaxId()]]
                       self$updateSliderInputValues(minValue, maxValue)
                       self$makePlot(minValue,maxValue)
      })
      )
    },
    

    
    finalize = function(){
      cat("finalizing", self$getObjectId(), "\n")
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
      
      div(id = self$getGraphicsId(), class = "NumericGraphics",
          shiny::plotOutput(outputId = self$getPlotId(),width = "80%", height="300px"))
      ) ## end second
      return(ui)
    }, 
    
    getDivId = function(){
      return(paste0("divGraphicsAndFilter", self$contextEnv$eventNumber, self$predicateName))
    },
    
    makePlot = function(minimum, maximum){
      output[[self$getPlotId()]] <- renderPlot({
        x <- self$dataFrame$value
        bool <- x >= minimum &  x <= maximum
        colors <- ifelse (bool, "blue","black")
        filling <- ifelse (bool, 19, 1)
        plot(x, col=colors, pch = filling)
        abline(h=minimum, col="blue")
        abline(h=maximum, col="blue")
      }, width="auto",height="auto")
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
    
    toNumeric = function(){
      self$dataFrame$value <- as.numeric(self$dataFrame$value)
      if (all(is.na(self$dataFrame$value))){
        stop("dataFrame for NumericFilter contains only NA value")
      }
    },
    
    getMin = function(){
      return(min(self$dataFrame$value, na.rm=T))
    },
    
    getMax = function(){
      return(max(self$dataFrame$value, na.rm=T))
    }
  )
)

# test <- data.frame(context = "test", event = "test", value=c(1:1000))
# filterNumeric <- FilterNumeric$new(1, "inEtab",test)
# filterNumeric$dataFrame$value
# filterNumeric$getUI()
