Survie <- R6::R6Class(
  "Survie",
  inherit=uiObject,
  
  public=list(
    searchQueries = NULL,
    result = NULL,
    chooseEventObserver = NULL, 
    validateObserver = NULL, 
    
    initialize = function(parentId, where){
      super$initialize(parentId = parentId, where = where)
      self$searchQueries <- SearchQueries$new(parentId = GLOBALsurvieDiv, 
                                              where = "beforeEnd",
                                              validateButtonId = self$getValidateButtonId())
      self$insertUIsurvie()
      self$addChooseEventsObserver()
      self$addValidateObserver()
    },
    
    getUI = function(){
      ui <- div(
        id = self$getDivId(),
        shiny::fluidRow(
          column(width = 2,
                 shiny::selectInput(inputId = self$getEvent1SelectizeId(),
                                    label="event1",
                                    choices = private$eventsAvailable,
                                    selected = private$eventsAvailable,
                                    multiple = F,
                                    selectize = F)),
          column(width = 2,
                 shiny::selectInput(inputId = self$getEvent2SelectizeId(),
                                    label="event2",
                                    choices = private$eventsAvailable,
                                    selected = private$eventsAvailable,
                                    multiple = F,
                                    selectize = F))),
         shiny::actionButton(inputId = self$getMakeCurveButtonId(),
                             label = GLOBALmakeSurvivalCurve),
         shiny::verbatimTextOutput(outputId = self$getVerbatimInfoId()),
         shiny::plotOutput(outputId = self$getPlotId())
        )
    },
    
    sendInfo = function(message){
      output[[self$getVerbatimInfoId()]] <- shiny::renderPrint(message)
    },
    
    getDivId = function(){
      return(paste0("divSurvie",self$parentId))
    },
    
    getVerbatimInfoId = function(){
      return(paste0("divSurvie",self$getDivId()))
    },
    
    getControlDivId = function(){
      return(paste0("controlDivId",self$getDivId()))
    },
    
    getValidateButtonId = function(){
      return(paste0("buttonValidateResult-",self$getDivId()))
    },
    
    getEvent1SelectizeId = function(){
      return(paste0("event1Choice",self$getControlDivId()))
    },
    
    getEvent2SelectizeId = function(){
      return(paste0("event2Choice",self$getControlDivId()))
    },
    
    getMakeCurveButtonId = function(){
      return(paste0("validateEvent",self$getControlDivId()))
    },
    
    getPlotId = function(){
      return(paste0("plot",self$getDivId()))
    },
    
    insertUIsurvie = function(){
      jQuerySelector = paste0("#",self$parentId)
      ui <- self$getUI()
      insertUI(selector = jQuerySelector,
               where = self$where,
               ui = ui,
               immediate=T)
    },
    
    # chooseEventObserver
    # validateObserver
    addChooseEventsObserver = function(){
      self$chooseEventObserver <- observeEvent(input[[self$getMakeCurveButtonId()]],{
        event1 <- input[[self$getEvent1SelectizeId()]]
        event2 <- input[[self$getEvent2SelectizeId()]]
        if (event1 == "" || event2 == ""){
          message <- "Please, select a query and choose events first"
          self$sendInfo(message)
          return(NULL)
        }
        bool <- event1 %in% colnames(self$result$resultDf) & event2 %in% colnames(self$result$resultDf)
        if (!bool){
          message <- paste0(event1, " or ", event2, " not found in results")
          self$sendInfo(message)
          return(NULL)
        }
        if (event1 == event2){
          message <- paste0("Same event selected. Events must be different")
          self$sendInfo(message)
          return(NULL)
        }
        
        ## choisir date de fin ou de début !
        
        selectedColumns <- c(event1,event2,"context")
        result <- self$result$resultDf
        resultats <- save (result, file="results.rdata")
        load("results.rdata")
        contextEvents <- subset(self$result$resultDf, select=selectedColumns)
        
        addValue_ <- function(contextEvents, colNum){
          contextEvents1 <- contextEvents[,c(3,colNum)]
          ### get HasBeginning
          terminologyName <- "Event"
          eventType <- "Event"
          predicateName <- "hasBeginning"
          print(contextEvents1)
          event1Value <- staticFilterCreator$getDataFrame(terminologyName, eventType, 
                                                          contextEvents1, predicateName)
          orderNum <- match(contextEvents[,colNum],event1Value$event)
          event1Value <- event1Value[orderNum,]
          event1Value$value <-  private$valueToDate(event1Value$value)
          contextEvents$value <- event1Value$value
          colnames(contextEvents)[length(contextEvents)] <- paste0("event", colNum,"value")
          return(contextEvents)
        }
        contextEvents <- addValue_(contextEvents,1)
        contextEvents <- addValue_(contextEvents,2)
        
        df <- contextEvents
        df$event <- 1
        save(df,file="df.rdata")
        rm(list=ls())
        load("df.rdata")
        plot <- self$getPlot(df)
        output[[self$getPlotId()]] <- renderPlot({
          ggpar(plot,font.legend = c("12","plain","black"))
        })
        self$sendInfo("Kaplan-meier curve ploted")
        return(NULL)
      })
    },
    

    getPlot = function(df){
      df$diffEvent2Event1 <- as.numeric(difftime(df$event2value,df$event1value,units = "days"))
      my.fit <- do.call(survfit, 
                        list(formula =  Surv(diffEvent2Event1, df$event) ~ 1, data=df))
      plot <- ggsurvplot(my.fit, data = df,
                         risk.table = T,
                         conf.int = T,
                         tables.height = 0.2,
                         risk.table.y.text = FALSE,
                         xlab="Time (days)")
      return(plot)
    },
    
    addValidateObserver = function(){
      self$validateObserver <- observeEvent(input[[self$getValidateButtonId()]],{
        staticLogger$user("Validate Button Survie clicked ")
        
        if (is.null(self$searchQueries$xmlSearchQuery)){
          staticLogger$info("HandleTimeline : no query selected")
          return(NULL)
        }
        self$searchQueries$result <-  Result$new(self$searchQueries$xmlSearchQuery)
        
        self$result <- self$searchQueries$result
        self$setEventChoices()
      })
    },
    
    setEventChoices = function(){
      bool <- grepl(pattern = "event",colnames(self$result$resultDf))
      private$eventsAvailable <- colnames(self$result$resultDf)[bool]
      self$updateEvent(self$getEvent1SelectizeId())
      self$updateEvent(self$getEvent2SelectizeId())
    },
    
    ## for UILinkChoice
    updateEvent = function(eventSelectizeId){
      shiny::updateSelectInput(session = session,
                               inputId = eventSelectizeId,
                               choices = private$eventsAvailable,
                               selected = NULL)
    }
  ),
  
  private=list(
    eventsAvailable = "",
    valueToDate = function(x){
      ## date format : 
      x <- gsub("T|Z"," ",x )
      x <- gsub("\\.[0-9]+ $","",x)
      x <- as.Date(x)  
      return(x)
    }
  )
)
