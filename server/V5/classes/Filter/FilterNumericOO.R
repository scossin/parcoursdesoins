FilterNumeric <- R6::R6Class(
  "FilterNumeric",
  inherit = Filter,
  
  public=list(
    initialize = function(eventNumber, predicateName, dataFrame){
      super$initialize(eventNumber, predicateName, dataFrame)
      private$toNumeric()
    },
    
    
    addPrivateObservers = function(){
      ## a list of observeEvent
      list(observeEvent(input[[self$getObjectId()]],{
        numericValues <- input[[self$getObjectId()]]
        minValue <- numericValues[1]
        maxValue <- numericValues[2]
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

        # shiny::updateNumericInput()
      }),
      
      observeEvent(c(input[[self$getNumericInputMinId()]],
                     input[[self$getNumericInputMaxId()]]),{
        isolate({
          minValue <- input[[self$getNumericInputMinId()]]
          maxValue <- input[[self$getNumericInputMaxId()]]
          
          if (any(is.na(as.numeric(minValue, maxValue)))){
            return(NULL)
          }
          
          if (maxValue < minValue){
            shiny::updateNumericInput(session, 
                                      inputId = self$getNumericInputMaxId(),
                                      label="max",
                                      value=minValue,
                                      min=private$getMin(),
                                      max=private$getMax(),step = 1)
            return(NULL)
          }
          print("Numeric input get modified")
          shiny::updateSliderInput(session,
                                   self$getObjectId(),
                                   label = NULL, 
                                   min=private$getMin(), 
                                   max=private$getMax(),
                                   value = c(minValue,maxValue))
                                   
        })
      }
      ))
    },
    
    getUI = function(){
      div(id = private$getDivId(),
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
                              
      )
    }, 
    
    getNumericInputMaxId = function(){
      return(paste0("numericMax",self$eventNumber, self$predicateName))
    },
    
    getNumericInputMinId = function(){
      return(paste0("numericMin",self$eventNumber, self$predicateName))
    },
    
    getObjectId = function(){
      return(paste0("slider",self$eventNumber, self$predicateName))
    },
    
    makeUI = function(){
      
    },
    
    getChoosenEvents = function(){
      stop("setContext not implemented !")
    },

    setContext = function(){
      stop("setContext not implemented !")
    }
  ),
  
  private=list(
    getDivId = function(){
      filterId <- self$getObjectId()
      return(paste0("div",filterId))
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

test <- data.frame(context = "test", event = "test", value=c(1:1000))
filterNumeric <- FilterNumeric$new(1, "inEtab",test)
filterNumeric$dataFrame$value
filterNumeric$getUI()
