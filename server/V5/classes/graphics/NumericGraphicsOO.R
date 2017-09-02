NumericGraphics <- R6::R6Class(
  "NumericGraphics",
  inherit = uiObject,
 
  
  public = list(
    lastChoice = character(),
    valueEnv = environment(),
    
    initialize = function(valueEnv, parentId, where){
      staticLogger$user("Creating a new NumericGraphics ", where, parentId)
      super$initialize(parentId, where)
      self$valueEnv <- valueEnv
      self$lastChoice <- private$firstChoice
      self$insertUIandPlot()
      self$observerButton()
      
    },
  
    insertUIandPlot = function(plotChoice = NULL){
      if (is.null(plotChoice)){
        plotChoice <- self$lastChoice
      }
      if (plotChoice == "SCATTERPLOT"){
        self$scatterplotInsertUI()
        self$scatterplotMakePlot()
      } else if (plotChoice == "BOXPLOT"){
        self$boxplotInsertUI()
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
    
      
  scatterplotInsertUI = function(){
    ui <- shiny::plotOutput(outputId = self$getPlotId(),width = "80%", height="300px")
    jQuerySelector = paste0("#",self$parentId)
    insertUI(selector = jQuerySelector,
            where = self$where,
            ui = self$getUI(ui))
  },
  
  scatterplotMakePlot = function(){
    output[[self$getPlotId()]] <- renderPlot({
        staticLogger$info("Setting or reseting plot")
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
  
  boxplotInsertUI = function(){
    ui <- shiny::plotOutput(outputId = self$getPlotId(),width = "80%", height="300px")
    jQuerySelector = paste0("#",self$parentId)
    insertUI(selector = jQuerySelector,
             where = self$where,
             ui = self$getUI(ui))
  },
  
  boxplotMakePlot = function(){
    output[[self$getPlotId()]] <- renderPlot({
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
  
  observerButton = function(){
    observeEvent(input[[self$getButtonId()]],{
      self$removeDiv()
      position <- which(private$plotList == self$lastChoice)
      doubleplotList <- rep(private$plotList,2)
      nextChoice <- doubleplotList[position+1]
      self$insertUIandPlot(nextChoice)
    })
  },
  
  getButtonId = function(){
    return(paste0(self$getDivId(), "button"))
  },
  
  getDivId = function(){
    return("divIdNumericGraphics")
  },
  
  getPlotId = function(){
    return(paste0("Plot1"))
  },
  
  removeDiv = function(){
    jQuerySelector = paste0("#",self$getDivId())
    removeUI(selector = jQuerySelector)
  }
  
  ),
  
  private = list (
    plotList = c("SCATTERPLOT","BOXPLOT"),
    firstChoice = c("SCATTERPLOT")
)
)
