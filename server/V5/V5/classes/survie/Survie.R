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
         shiny::actionButton(inputId = self$getValidateEventChoiceId(),label = GLOBALmakeSurvivalCurve),
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
    
    getValidateEventChoiceId = function(){
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
      self$chooseEventObserver <- observeEvent(input[[self$getValidateEventChoiceId()]],{
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
        bool <- colnames(self$result$resultDf) %in% c("context",event1)
        contextEvents1 <- self$result$resultDf[,bool]
        ### get HasBeginning
        terminologyName <- "Event"
        eventType <- "Event"
        predicateName <- "hasBeginning"
        event1Value <- staticFilterCreator$getDataFrame(terminologyName, eventType, contextEvents1, predicateName)
        event1Value$value <-  private$valueToDate(event1Value$value)
        colnames(event1Value) <- c(event1,paste0(event1,"value"))
        
        bool <- colnames(self$result$resultDf) %in% c("context",event2)
        contextEvents2 <- self$result$resultDf[,bool]
        event2Value <- staticFilterCreator$getDataFrame(terminologyName, eventType, contextEvents2, predicateName)
        event2Value$value <-  valueToDate(event2Value$value)
        colnames(event2Value) <- c(event2,paste0(event2,"value"))
        
        df <- cbind(event1Value, event2Value)
        df$event <- 1
        diffEvent2Event1 <- as.numeric(difftime(df$event2value,df$event1value,units = "days"))
        surv_objet <- Surv(as.numeric(diffEvent2Event1), event=df$event)
        my.fit <- survfit(surv_objet~1)
        plot <- ggsurvplot(my.fit, data = df,
                           risk.table = T,
                           conf.int = T,
                           tables.height = 0.2,
                           risk.table.y.text = FALSE,
                           xlab="Time (days)")
        output[[self$getPlotId()]] <- renderPlot({
          ggpar(plot,font.legend = c("12","plain","black"))
        })
        self$sendInfo("Kaplan-meier curve ploted")
        return(NULL)
      })
    },
    
    addValidateObserver = function(){
      self$validateObserver <- observeEvent(input[[self$getValidateButtonId()]],{
        staticLogger$user("Validate Button Survie clicked ")
        
        queryChoice <- input[[self$searchQueries$getSelectizeResultId()]]
        
        if (is.null(queryChoice) || queryChoice == ""){
          staticLogger$info("No query selected")
          return(NULL)
        }
        
        staticLogger$info("Survie : ", queryChoice, "selected")
        
        queryChoice <- gsub(GLOBALquery,"",queryChoice)
        queryChoice <- as.numeric(queryChoice)
        lengthListResults <- length(GLOBALlistResults$listResults)
        bool <- queryChoice > lengthListResults
        if (bool){
          stop("queryChoice number not found in GLOBALlistResults ")
        }
        self$result <- GLOBALlistResults$listResults[[queryChoice]]
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