NumericGraphics <- R6::R6Class(
  "NumericGraphics",
  inherit = uiObject,
 
  
  public = list(
    x = numeric(),
    lastChoice = character(),
    
    initialize = function(x, parentId, where){
      staticLogger$user("Creating a new NumericGraphics ", where, parentId)
      super$initialize(parentId, where)
      self$x <- x
      self$insertUIandPlot(private$firstChoice)
      self$observerButton()
    },
  
    insertUIandPlot = function(plotChoice){
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
    
  scatterplotInsertUI = function(){
    ui <- shiny::plotOutput(outputId = self$getPlotId(),width = "80%", height="300px")
    jQuerySelector = paste0("#",self$parentId)
    insertUI(selector = jQuerySelector,
            where = self$where,
            ui = self$getUI(ui))
  },
  
  scatterplotMakePlot = function(){
    output[[self$getPlotId()]] <- renderPlot({
      plot(self$x)
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
      boxplot(self$x)
    })
  },
  
  getUI = function(uiPlot){
    div(id=self$getDivId(),
        shiny::actionButton(inputId = self$getButtonId(), label="Change"),
        uiPlot
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