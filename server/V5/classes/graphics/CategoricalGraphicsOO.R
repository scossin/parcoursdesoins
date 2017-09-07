CategoricalGraphics <- R6::R6Class(
  "CategoricalGraphics",
  inherit = uiObject,
  
  public = list(
    lastChoice = character(),
    valueEnv = environment(),
    Nfirst = 10,
    changePlotObserver = NULL,
    pieObserver = NULL,
    selectizeObserver = NULL,
    
    initialize = function(valueEnv, parentId, where){
      staticLogger$info("Creating a new CategoricalGraphics ", where, parentId)
      super$initialize(parentId, where)
      self$valueEnv <- valueEnv
      self$lastChoice <- private$firstChoice
      
      self$insertSelectizeInput()
      
      self$insertUIandPlot()
      
      self$addChangePlotObserver()
      self$addObserverPiechart2()
      self$addSelectizeObserver()
      self$addNfirstObserver()
    },
    
    insertSelectizeInput = function(){
      ui <- shiny::selectizeInput(inputId = self$getSelectizeId(),
                                  label="",
                                  choices = NULL,
                                  selected = NULL,
                                  multiple = T,
                                  width = "100%",
                                  options = list(hideSelected = T,
                                                 plugins=list('remove_button')))
      jQuerySelector = paste0("#",self$parentId)
      insertUI(selector = jQuerySelector,
               where = self$where,
               ui = ui,immediate = T)
      self$updateSelection()
      return(NULL)
    },
    
    
    updateSelection = function(){
      staticLogger$info("Updating selection")
      updateSelectizeInput(session = session, 
                           inputId = self$getSelectizeId(),
                           label="",
                           choices = names(self$valueEnv$categoricalValues$tableX),
                           selected = self$valueEnv$categoricalValues$getChosenValues(),
                           server = TRUE)
      return(NULL)
    },
    
    insertUIandPlot = function(plotChoice = NULL){
      if (is.null(plotChoice)){
        plotChoice <- self$lastChoice
      }
      if (plotChoice == "BARPLOT"){
        self$insertUIplot(self$getUIbarplot())
        self$makePlotbarplot()
      } else if (plotChoice == "PIE"){
        self$insertUIplot(self$getUIpie())
        self$makePlotpiecharts()
      }
      self$lastChoice <- plotChoice
      return(NULL)
    },
    
    getUIbarplot = function(){
      uiPlot <- shiny::plotOutput(outputId = self$getPlotId(),width = "100%", height="400px")
      return(uiPlot)
    },
    
    getUIpie = function(){
      ## piechart1 : 
      uiPlot <- div(id=self$getPieChartsDivId(),
                    plotly::plotlyOutput(outputId = self$getPieChart1Id(),width = "40%"),
                    plotly::plotlyOutput(outputId = self$getPieChart2Id(),width = "40%")
      )
      return(uiPlot)
    },
    
    insertUIplot = function(uiPlot){
      #div(id = self$getGraphicsId(), class = "CategoricalGraphics")
      ui <- div(id=self$getDivId(),
                uiPlot,
                shiny::actionButton(inputId = self$getButtonId(), label="",
                                    icon = icon("refresh")),
                shiny::numericInput(inputId = self$getNfirstId(), label="",min=1, value=10, max=20,step=1)
      )
      jQuerySelector = paste0("#",self$parentId)
      insertUI(selector = jQuerySelector,
               where = self$where,
               ui = ui)
    },
    
    addNfirstObserver = function(){
      observeEvent(input[[self$getNfirstId()]], {
        staticLogger$info("Changer Nfirst ")
        newFirst <- input[[self$getNfirstId()]]
        newFirst <- as.numeric(newFirst)
        if (is.na(newFirst)){
          staticLogger$info("wrong value of Nfirst ")
          return(NULL)
        }
        self$Nfirst <- newFirst
        plotChoice <- self$lastChoice
        if (plotChoice == "BARPLOT"){
          self$makePlotbarplot()
        } else if (plotChoice == "PIE"){
          self$makePlotpiecharts()
        }
      })
    },
    
    getNfirstId = function(){
      return(paste0("NfirstId",self$parentId))
    },
    
    makePlotbarplot = function(){
      output[[self$getPlotId()]] <- renderPlot({
        barplot(self$valueEnv$categoricalValues$tableX)
      })
    },
    
    makePlotpiecharts = function(){
      self$makePlotpiechart1()
      self$makePlotpiechart2()
    },
    
    makePlotpiechart1 = function(){
      output[[self$getPieChart1Id()]] <- plotly::renderPlotly({
        tab <- self$valueEnv$categoricalValues$tableChosenValues
        if (length(tab) == 0){
          df <- data.frame(labels = "empty", values = 1)
        } else {
          Nfirst <- self$Nfirst
          if (Nfirst > length(tab)){
            Nfirst <- length(tab)
          }
          tabFirst <- tab[1:Nfirst]
          others <- NULL
          if (Nfirst < length(tab)){
            tabOthers <- tab[(Nfirst+1):length(tab)]
            others <- data.frame(labels = "others", values = sum(tabOthers))
          }
          df <- data.frame(labels = names(tabFirst), values = as.numeric(tabFirst))
          df <- subset (df, values != 0)
          df <- rbind (df, others)
        }
        plotly::plot_ly(df, labels = ~labels, values = ~values, type = 'pie') %>%
          layout(title = GLOBALselectedPieChart, showlegend = FALSE,
                 xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                 yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
      })
    },
    
    makePlotpiechart2 = function(){
      output[[self$getPieChart2Id()]] <- plotly::renderPlotly({
        tab <- self$valueEnv$categoricalValues$tableX
        if (length(tab) == 0){
          df <- data.frame(labels = "empty", values = 1)
        } else {
          Nfirst <- self$Nfirst
          if (Nfirst > length(tab)){
            Nfirst <- length(tab)
          }
          tabFirst <- tab[1:Nfirst]
          others <- NULL
          if (Nfirst < length(tab)){
            tabOthers <- tab[(Nfirst+1):length(tab)]
            others <- data.frame(labels = "others",values = sum(tabOthers))
          }
          df <- data.frame(labels = names(tabFirst), values = as.numeric(tabFirst))
          df <- subset (df, values != 0)
          df <- rbind (df, others)
        }
        plotly::plot_ly(df, labels = ~labels, values = ~values, type = 'pie',source=self$getPieChart2Id()) %>%
          layout(title = GLOBALselectedPieChart, showlegend = FALSE,
                 xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                 yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
      })
    },
    
    addSelectizeObserver = function(){
      self$selectizeObserver <- observeEvent(input[[self$getSelectizeId()]],{
        staticLogger$info("New choice in selectize ... ")
        chosenValues <- input[[self$getSelectizeId()]]
        ## if it's added by the plot, categoricalValues is already updated
        if (length(names(self$valueEnv$categoricalValues$tableChosenValues)) == length(chosenValues)){
          staticLogger$info("\t it was an update of plot")
          return(NULL)
        }
        staticLogger$info("\t updating plot and categoricalValues")
        self$valueEnv$categoricalValues$setTableChosenValuesSelectize(chosenValues)
        self$remakePlot()
      })
    },
    
    addObserverPiechart2 = function(){
      self$pieObserver <- observe({
        click <- plotly::event_data(event = "plotly_click",source = self$getPieChart2Id())
        clickNumber <- click$pointNumber+1 ## javascript is 0 indexed
        staticLogger$info("clickNumber :", clickNumber)
        if (is.null(clickNumber) || length(clickNumber) == 0){
          return(NULL)
        }
        if (clickNumber > self$Nfirst){
          staticLogger$info("Others clicked !")
          return(NULL)
        }
        staticLogger$info("Piechart2 clicked !", self$getPieChart2Id())
        chosenValue <- self$valueEnv$categoricalValues$getValueWithPosition(clickNumber)
        if (chosenValue %in% names(self$valueEnv$categoricalValues$tableChosenValues)){
          staticLogger$info("Already selected ", chosenValue)
          return(NULL)
        } else {
          staticLogger$info("Adding ", chosenValue)
          self$valueEnv$categoricalValues$setTableChosenValues(chosenValue)
          self$updateSelection()
          self$remakePlot()
        }
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
      if (plotChoice == "BARPLOT"){
        print("do something for god sake")
      } else if (plotChoice == "PIE"){
        self$makePlotpiechart1()
      }
    },
    
    getObjectId = function(){
      return(paste0("CategoricalGraphics-", self$parentId))
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
    
    getSelectizeId = function(){
      return(paste0("selectize",self$parentId))
    },
    
    getPieChartsDivId = function(){
      return(paste0("divpiechartCategorical",self$getDivId()))
    },
    
    getPieChart1Id = function(){
      return(paste0("piechartCategorical1",self$getPieChartsDivId()))
    },
    
    getPieChart2Id = function(){
      return(paste0("piechartCategorical2",self$getPieChartsDivId()))
    },
    
    removeUI = function(){
      jQuerySelector = paste0("#",self$getDivId())
      removeUI(selector = jQuerySelector)
    },
    
    destroy = function(){
      staticLogger$info("Destroying CategoricalGraphics ", self$getDivId())
      staticLogger$info("\t Removing changePlotObserver, pieObserver and selectizeObserver ")
      if (!is.null(self$changePlotObserver)){
        self$changePlotObserver$destroy()
        staticLogger$info("\t \t done")
      }
      if (!is.null(self$pieObserver)){
        self$pieObserver$destroy()
        staticLogger$info("\t \t done")
      }
      if (!is.null(self$selectizeObserver)){
        self$selectizeObserver$destroy()
        staticLogger$info("\t \t done")
      }
      staticLogger$info("\t Removing UI ")
      self$removeUI()
      staticLogger$info("End Destroying CategoricalGraphics ", self$getDivId())
    }

  ),
  
  private = list (
    plotList = c("BARPLOT","PIE"),
    firstChoice = c("PIE")
  )
)