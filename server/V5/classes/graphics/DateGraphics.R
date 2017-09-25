DateGraphics <- R6::R6Class(
  "DateGraphics",
  inherit = uiObject,
  
  public = list(
    contextEnv = NULL,
    lastChoice = character(),
    dateValues = NULL,
    changePlotObserver = NULL,
    dygraphObserver = NULL,
    dateRangeObserver = NULL,
    
    initialize = function(contextEnv,dateValues, parentId, where){
      self$contextEnv <- contextEnv
      staticLogger$info("Creating a new DateGraphics ", where, parentId)
      super$initialize(parentId, where)
      self$dateValues <- dateValues
      self$insertDateRangeInput()
      self$lastChoice <- private$firstChoice
      self$insertUIandPlot()
      self$addChangePlotObserver()
      self$addDygraphObserver()
      self$addDateRangeObserver()
    },
    
    insertDateRangeInput = function(){
      ui <- dateRangeInput(self$getDateRangeId(), "from", start = self$dateValues$getMinDate(), 
                           end = self$dateValues$getMaxDate(), min = NULL,
                     max = NULL, format = "yyyy-mm-dd", startview = "month", weekstart = 0,
                     language = GLOBALlang, separator = " to ", width = NULL)
      jQuerySelector = paste0("#",self$parentId)
      insertUI(selector = jQuerySelector,
               where = self$where,
               ui = ui,immediate = T)
      return(NULL)
    },
    
    getDateRangeId = function(){
      return(paste0("dateRange",self$parentId))
    },
    
    updateDateRange = function(){
      staticLogger$info("Updating DateRange", self$getDateRangeId())
      shiny::updateDateRangeInput(session = session, 
                           inputId = self$getDateRangeId(),
                           start = self$dateValues$getMinDate(), 
                           end = self$dateValues$getMaxDate())
      self$contextEnv$instanceSelection$filterHasChanged()
      return(NULL)
    },
    
    insertUIandPlot = function(plotChoice = NULL){
      if (is.null(plotChoice)){
        plotChoice <- self$lastChoice
      }
      if (plotChoice == "DYGRAPH"){
        self$insertUIplot(self$getDygraphUI())
        self$dygraphPlot()
      } else { ## something else ?
        return(NULL)
      }
      self$lastChoice <- plotChoice
      return(NULL)
    },
    
    getDygraphUI = function(){
      uiPlot <- dygraphs::dygraphOutput(self$getDygraphId())
      return(uiPlot)
    },
    
    getDygraphId = function(){
      return(paste0("dygraph",self$getDivId()))
    },
    
    insertUIplot = function(uiPlot){
      #div(id = self$getGraphicsId(), class = "DateGraphics")
      ui <- div(id=self$getDivId(),
                uiPlot,
                shiny::actionButton(inputId = self$getButtonId(), label="",
                                    icon = icon("refresh"))
      )
      jQuerySelector = paste0("#",self$parentId)
      insertUI(selector = jQuerySelector,
               where = self$where,
               ui = ui)
    },
    
    dygraphPlot = function(){
      output[[self$getDygraphId()]] <- renderDygraph({
        staticLogger$info("plotting dygraphPlot")
        dygraphs::dygraph(data = self$dateValues$xtsObjectSelection, main = "") 
      })
    },
    
    addDygraphObserver = function(){
      dateWindowInput <- paste0(self$getDygraphId(),"_date_window")
      self$dygraphObserver <- observeEvent(input[[dateWindowInput]],{
        staticLogger$info("date_window changed ! ")
        chosen <- input[[dateWindowInput]]
        minDate <- as.character(strftime(req(chosen[[1]]), "%Y-%m-%d"))
        maxDate <- as.character(strftime(req(chosen[[2]]), "%Y-%m-%d"))
        staticLogger$info("minDate : ", minDate, "maxDate : ", maxDate)
        self$dateValues$setXTSobjectSelection(minDate, maxDate)
        self$updateDateRange()
      })
      return(NULL)
    },
    
    addDateRangeObserver = function(){
      self$dateRangeObserver <- observeEvent(input[[self$getDateRangeId()]],{
        staticLogger$info("dateRange selection")
        values <- input[[self$getDateRangeId()]]
        if (is.null(values) || length(values) == 0){
          staticLogger$info("\t it was null dateRange")
          return(NULL)
        }
        minDate <- as.character(values[[1]])
        maxDate <- as.character(values[[2]])
        if (minDate == self$dateValues$getMinDate() & maxDate == self$dateValues$getMaxDate()){
          staticLogger$info("\t it was an update")
          return(NULL)
        }
        staticLogger$info("minDate : ", minDate , "maxDate : ", maxDate)
        self$dateValues$setXTSobjectSelection(minDate, maxDate)
        self$remakePlot()
        self$contextEnv$instanceSelection$filterHasChanged()
      })
    },

    addChangePlotObserver = function(){
      self$changePlotObserver <- observeEvent(input[[self$getButtonId()]],{
        position <- which(private$plotList == self$lastChoice)
        doubleplotList <- rep(private$plotList,2)
        nextChoice <- doubleplotList[position+1]
        self$removeUI()
        self$insertUIandPlot(nextChoice)
      })
    },

    remakePlot = function(){
      plotChoice <- self$lastChoice
      if (plotChoice == "DYGRAPH"){
        self$dygraphPlot()
      } else {
        return(NULL)
      }
    },
    
    getObjectId = function(){
      return(paste0("DateGraphics-", self$parentId))
    },
    
    getDivId = function(){
      return(paste0("div", self$getObjectId()))
    },
    
    getButtonId = function(){
      return(paste0("button",self$getDivId()))
    },
    
    getPlotId = function(){
      return(paste0("plot",self$getDivId()))
    },
    
    removeUI = function(){
      jQuerySelector = paste0("#",self$getDivId())
      removeUI(selector = jQuerySelector)
    },
    
    destroy = function(){
      staticLogger$info("Destroying DateGraphics ", self$getDivId())
      staticLogger$info("\t Removing changePlotObserver, dygraphObserver and dateRangeObserver ")
      if (!is.null(self$changePlotObserver)){
        self$changePlotObserver$destroy()
        staticLogger$info("\t \t done")
      }
      if (!is.null(self$dygraphObserver)){
        self$dygraphObserver$destroy()
        staticLogger$info("\t \t done")
      }
      if (!is.null(self$dateRangeObserver)){
        self$dateRangeObserver$destroy()
        staticLogger$info("\t \t done")
      }
      staticLogger$info("\t Removing UI ")
      self$removeUI()
      staticLogger$info("End Destroying DateGraphics ", self$getDivId())
    }
  ),
  
  private = list (
    plotList = c("DYGRAPH"),
    firstChoice = c("DYGRAPH")
  )
)