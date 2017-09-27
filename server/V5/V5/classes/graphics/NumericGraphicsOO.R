NumericGraphics <- R6::R6Class(
  "NumericGraphics",
  inherit = uiObject,
  
  public = list(
    lastChoice = character(),
    valueEnv = environment(),
    changePlotObserver = NULL,
    
    initialize = function(valueEnv, parentId, where){
      staticLogger$user("Creating a new NumericGraphics ", where, parentId)
      super$initialize(parentId, where)
      self$valueEnv <- valueEnv
      self$lastChoice <- private$firstChoice
      self$insertUIandPlot()
      self$addChangePlotObserver()
    },
    
    insertUIandPlot = function(plotChoice = NULL){
      if (is.null(plotChoice)){
        plotChoice <- self$lastChoice
      }
      
      self$insertUIplot()
      if (plotChoice == "SCATTERPLOT"){
        self$scatterplotMakePlot()
      } else if (plotChoice == "BOXPLOT"){
        self$boxplotMakePlot()
      }
      self$lastChoice <- plotChoice
      return(NULL)
    },
    
    remakePlot = function(){
      plotChoice <- self$lastChoice
      if (plotChoice == "SCATTERPLOT"){
        self$scatterplotMakePlot()
      } else if (plotChoice == "BOXPLOT"){
        self$boxplotMakePlot()
      }
    },
    
    insertUIplot = function(){
      ui <- shiny::plotOutput(outputId = self$getPlotId(),width = "100%", height="400px")
      jQuerySelector = paste0("#",self$parentId)
      insertUI(selector = jQuerySelector,
               where = self$where,
               ui = self$getUI(ui))
    },
    
    scatterplotMakePlot = function(){
      output[[self$getPlotId()]] <- renderPlot({
        staticLogger$info("Plotting a scatter plot in ", self$getDivId())
        output[[self$getPlotId()]] <- renderPlot({
          x <- self$valueEnv$numericValue$x
          minimum <- self$valueEnv$numericValue$minChosen
          maximum <- self$valueEnv$numericValue$maxChosen
          bool <- x >= minimum &  x <= maximum
          colors <- ifelse (bool, "blue","black")
          filling <- ifelse (bool, 19, 1)
          plot(x, col=colors, pch = filling, xlab="",ylab="")
          abline(h=minimum, col="blue")
          abline(h=maximum, col="blue")
        }, width="auto",height="auto")
      })
    },
    
    boxplotMakePlot = function(){
      output[[self$getPlotId()]] <- renderPlot({
        staticLogger$info("Plotting a boxplot in ", self$getDivId())
        x <- self$valueEnv$numericValue$x
        minimum <- self$valueEnv$numericValue$minChosen
        maximum <- self$valueEnv$numericValue$maxChosen
        bool <- x >= minimum &  x <= maximum
        selectedX <- x[bool]
        bplt <- boxplot(x, selectedX,col = c("grey","blue"), na.action = NULL, xlab="")
        axis(side=1, at=c(1,2), labels=c(GLOBALinitialBoxplot,GLOBALselectedBoxplot))
        text(x=1.5, y=fivenum(x), labels=as.character(round(fivenum(x),1)), col="grey")
        text(x=2.5, y=fivenum(selectedX), labels=as.character(round(fivenum(selectedX),1)), col="blue")
      })
    },
    
    getUI = function(uiPlot){
      div(id=self$getDivId(),
          uiPlot,
          shiny::actionButton(inputId = self$getButtonId(), label="",
                              icon = icon("refresh"))
      )
    },
    
    addChangePlotObserver = function(){
      self$changePlotObserver <- observeEvent(input[[self$getButtonId()]],{
        self$removeUI()
        position <- which(private$plotList == self$lastChoice)
        doubleplotList <- rep(private$plotList,2)
        nextChoice <- doubleplotList[position+1]
        self$insertUIandPlot(nextChoice)
      })
    },
    
    getObjectId = function(){
      return(paste0("NumericGraphics-", self$parentId))
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
      staticLogger$info("Destroying NumericGraphics ", self$getDivId())
      staticLogger$info("\t Removing changePlotObserver ")
      if (!is.null(self$changePlotObserver)){
        self$changePlotObserver$destroy()
        staticLogger$info("\t \t done")
      }
      staticLogger$info("\t Removing UI ")
      self$removeUI()
      staticLogger$info("End Destroying NumericGraphics ", self$getDivId())
    }

  ),
  
  private = list (
    plotList = c("SCATTERPLOT","BOXPLOT"),
    firstChoice = c("SCATTERPLOT")
  )
)
