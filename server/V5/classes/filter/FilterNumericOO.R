FilterNumeric <- R6::R6Class(
  "FilterNumeric",
  inherit = Filter,
  
  public=list(
    observersList = list(),
    valueEnv = environment(),
    numericGraphics = NULL,
    
    initialize = function(contextEnv, predicateName, dataFrame, parentId, where){
      staticLogger$info("Creating a new FilterNumeric object")
      super$initialize(contextEnv, predicateName, dataFrame, parentId, where)
      self$valueEnv <- new.env()
      self$valueEnv$numericValue <- NumericValues$new(dataFrame$value)
      self$makeUI()
      self$addNumericInputObservers()
      self$addSliderObserver()
    },
    
    updateDataFrame = function(){
      staticLogger$info("updateDataFrame of FilterNumeric")
      eventType <- self$contextEnv$instanceSelection$className
      terminologyName <- self$contextEnv$instanceSelection$terminology$terminologyName
      predicateName <- self$predicateName
      contextEvents <- self$contextEnv$instanceSelection$getContextEvents()
      self$dataFrame <- staticFilterCreator$getDataFrame(terminologyName, eventType, contextEvents, predicateName)
      self$valueEnv$numericValue$setX(self$dataFrame$value)
      self$updateSliderInputValues()
      self$numericGraphics$remakePlot()
    },
    
    getXMLpredicateNode = function(){
      tempQuery <- XMLSearchQuery$new()
      predicateNode <- tempQuery$makePredicateNode(predicateClass = "numeric",
                                                   predicateType = self$predicateName,
                                                   minValue = self$valueEnv$numericValue$minChosen,
                                                   maxValue = self$valueEnv$numericValue$maxChosen)
      return(predicateNode)
    },
    
    makeUI = function(){
      jquerySelector <- private$getJquerySelector(self$parentId)
      insertUI(selector = jquerySelector, 
               where = self$where,
               ui = self$getUI(),
               immediate = T)
    },
    
    getDescription = function(){
      description <- paste0(self$predicateName,"\t minValue: ",self$valueEnv$numericValue$minChosen,
                            "\n\t maxValue: ", self$valueEnv$numericValue$maxChosen)
      return(description)
    },
    
    getUI = function(){
      ui <- div(id = self$getDivId(),
                div(id = self$getDivNumericFilterId(),
                    shiny::sliderInput(self$getSliderId(),
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
                
                div(id = self$getGraphicsId(), class = "NumericGraphics"),
                
                div(class="textOutputSelection",shiny::textOutput(self$getTextInfoId(),inline = T))
      )
      return(ui)
    }, 
    
    
    updateSliderInputValues = function(){
      staticLogger$info("Updating slider : ", self$getSliderId())
      isolate({
        shiny::updateSliderInput(session,
                                 self$getSliderId(),
                                 label = NULL, 
                                 min = self$valueEnv$numericValue$minFloor,
                                 max =  self$valueEnv$numericValue$maxCeiling,
                                 value = c(self$valueEnv$numericValue$minChosen,
                                           self$valueEnv$numericValue$maxChosen))
      })
    },
    
    updateNumericInputValues = function(){
      staticLogger$info("Updating NumericInputValues : ", self$getDivNumericFilterId())
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
      o <- observeEvent(input[[self$getSliderId()]],{
        if (private$bugSlider){ ## NumericGraphics created here !
          self$numericGraphics <- NumericGraphics$new(self$valueEnv, 
                                                      self$getGraphicsId(),
                                                      where="beforeEnd")
          self$renderTextInfo()
          private$bugSlider <- FALSE
          return(NULL)
        }
        staticLogger$user("slider", self$getSliderId(), "changed")
        numericValues <- input[[self$getSliderId()]]
        minValue <- numericValues[1]
        maxValue <- numericValues[2]
        self$valueEnv$numericValue$setMinMaxChosen(minValue,maxValue)
        self$updateNumericInputValues()
        self$numericGraphics$remakePlot()
        self$renderTextInfo()
        self$contextEnv$instanceSelection$printFunction()
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
            self$renderTextInfo()
            self$contextEnv$instanceSelection$printFunction()
      })
      lengthList <- length(self$observersList)
      self$observersList[[lengthList+1]] <- o
      return(NULL)
    },
    
    getEventsSelected = function(){
      x <- self$valueEnv$numericValue$x
      minimum <- self$valueEnv$numericValue$minChosen
      maximum <- self$valueEnv$numericValue$maxChosen
      bool <- x >= minimum &  x <= maximum & !is.na(x)
      eventsSelected <- self$dataFrame$event[bool]
      return(as.character(eventsSelected))
    },
    
    renderTextInfo = function(){
      output[[self$getTextInfoId()]] <- renderText({
        eventsSelected <- unique(self$getEventsSelected())
        totalEvents <- unique(self$dataFrame$event)
        return(paste0(length(eventsSelected), " values selected out of ", length(totalEvents)))
      })
    },
    
    removeUI = function(){
      jQuerySelector <- private$getJquerySelector(self$getDivId())
      removeUI(selector = jQuerySelector)
    },
    
    destroy = function(){
      staticLogger$info("Destroying FilterNumeric :", self$getObjectId())
      
      staticLogger$info("\t removing numericGraphics")
      if (!is.null(self$numericGraphics)){
        self$numericGraphics$destroy()
      }
      staticLogger$info("\t removing every observer")
      for (observer in self$observersList){
        staticLogger$info("\t \t done")
        observer$destroy()
      }
      self$observersList <- NULL
      staticLogger$info("\t removing UI")
      self$removeUI()
      staticLogger$info("End destroying FilterNumeric :", self$getObjectId())
    },
    
    getObjectId = function(){
      return(paste0("FilterNumeric-",self$parentId))
    },
    
    getDivId = function(){
      return(paste0("div",self$getObjectId()))
    },
    
    getTextInfoId = function(){
      return(paste0("TextInfo",self$getDivId()))
    },
    
    getSliderId = function(){
      return(paste0("Slider",self$getDivId()))
    },
    
    getGraphicsId = function(){
      return(paste0("Graphics",self$getDivId()))
    },
    
    getDivNumericFilterId = function(){
      return(paste0("divNumericFilter",self$getDivId()))
    },
    
    getNumericInputMaxId = function(){
      return(paste0("numericMax",self$getDivNumericFilterId()))
    },
    
    getNumericInputMinId = function(){
      return(paste0("numericMin",self$getDivNumericFilterId()))
    }
    
  ),
  
  private=list(
    bugSlider = T,
    bugNumericInput = T
  )
)

# test <- data.frame(context = "test", event = "test", value=c(1:1000))
# filterNumeric <- FilterNumeric$new(1, "inEtab",test)
# filterNumeric$dataFrame$value
# filterNumeric$getUI()

