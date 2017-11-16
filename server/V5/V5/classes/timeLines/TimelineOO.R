Timeline <- R6::R6Class(
  inherit = uiObject,
  "Timeline",
  public = list(
    context = character(),
    eventsSelected = data.frame(),
    timevisDf = character(),
    clickedEventObserver = NULL,
    terminology = NULL,
    descriptionTableEvent = data.frame(),
    observerContextTable = NULL,
    descriptionTableContext = data.frame(),
    observerEventTable = NULL,
    
    initialize = function(parentId, where, contextEvents){
      super$initialize(parentId, where)
      self$insertUItimeline()
      self$terminology <- staticTerminologyInstances$getTerminology(staticTerminologyInstances$terminology$Event$terminologyName)
      self$setContextEvents(contextEvents)
      self$addClickedEventObserver()
      
      self$addObserverContextTable()
      self$addObserverEventTable()
    },
    
    addObserverContextTable = function(){
      clickedInput <- paste0(self$getContextDescriptionId(),"_rows_selected")
      self$observerContextTable <- observeEvent(input[[clickedInput]],{
        print("clicked !!")
        rowClicked <- input[[clickedInput]]
        line <- self$descriptionTableContext[rowClicked,]
        instanceName <- line$valeur
        predicateLabel <- line$variable
        terminology <- staticTerminologyInstances$getTerminology("Graph")
        self$setVariableDescription(predicateLabel = predicateLabel,
                                    instanceName = instanceName,
                                    terminology = terminology)
      })
    },
    
    addObserverEventTable = function(){
      clickedInput <- paste0(self$getEventDescriptionId(),"_rows_selected")
      self$observerEventTable <- observeEvent(input[[clickedInput]],{
        print("clicked Event !!")
        rowClicked <- input[[clickedInput]]
        line <- self$descriptionTableEvent[rowClicked,]
        instanceName <- line$valeur
        predicateLabel <- line$variable
        self$setVariableDescription(predicateLabel = predicateLabel,
                                    instanceName = instanceName,
                                    terminology = self$terminology)
      })
    },
    
    setContextEvents = function(contextEvents){
      context <- unique(contextEvents$context)
      bool <- length(context) == 1
      if (!bool){
        stop("context must be length 1")
      }
      self$context <- context
      eventsSelected <- unique(as.character(contextEvents$event))
      self$eventsSelected <- data.frame(event = eventsSelected, 
                                        content = "")
      self$setTimevisDf()
      self$plotTimeline()  
      self$setEventDescription(eventName = NULL)
      self$setContextDescription(contextName = self$context)
    },
    
    getDescriptionTable = function(description, eventType, terminology){
      tryCatch(
        predicates <- terminology$getPredicatesOfEvent(eventType)
        , error = function(e){
          print("Error finding terminology")
          return(NULL)
        }
      )
      bool <- description$predicate %in% predicates
      description <- subset (description, bool)
      
      ## replace predicateName by predicate Label
      predicatesName <- description$predicate
      predicatesLabel <- sapply(predicatesName, function(x){
        terminology$getLabel(predicate = x)
      })
      predicatesLabel <- as.character(predicatesLabel)
      description$predicate <- predicatesLabel
      colnames(description) <- c(GLOBALvariable, GLOBALvalue)
      return(description)
      # return(eventDescription)
    },
    
    setEventDescription = function(eventName){
      if (is.null(eventName)){
        outputId <- self$getEventDescriptionId()
        descriptionTable <- data.frame(variable=character(), libelle = character())
        self$renderDT(outputId = outputId, 
                      data = descriptionTable)
        return(NULL)
      }
      content <- GLOBALcon$getEventDescriptionTimeline(eventName = eventName)
      eventDescription <- GLOBALcon$readContentStandard(content = content)
      eventDescription$object <- as.character(eventDescription$object)
      
      ## changing value (!hard coded) : 
      bool <- eventDescription$predicate == "hasBeginning"
      if (any(bool)){
        xsdDateTime <- eventDescription$object[bool]
        eventDescription$object[bool] <- self$changeDateFormat(xsdDateTime = xsdDateTime)
      }
      
      bool <- eventDescription$predicate == "hasEnd"
      if (any(bool)){
        eventDescription$object[bool] <- self$changeDateFormat(xsdDateTime = eventDescription$object[bool])
      }
      
      bool <- eventDescription$predicate == "hasDuration"
      if (any(bool)){
        nSeconds <- as.numeric(eventDescription$object[bool])
        eventDescription$object[bool] <- private$secondsToDayHourMinuteString(nSeconds = nSeconds)
      }
      bool <- eventDescription$predicate == "hasType"
      eventType <- as.character(eventDescription$object[bool])
      
      self$descriptionTableEvent <- self$getDescriptionTable(description = eventDescription, 
                                                   eventType = eventType, 
                                                   terminology = self$terminology)
      outputId <- self$getEventDescriptionId()
      self$renderDT(outputId = outputId, 
                    data = self$descriptionTableEvent)
    },
    
    setVariableDescription = function(predicateLabel,instanceName, terminology){
      # instanceName <- "06K04J"
      # predicateLabel <- "GHM"
      doNothing <- c("integer","dateTime","string")
      predicate <- terminology$getPredicate(predicateLabel)
      predicateDescription <- terminology$getPredicateDescription(predicate)
      expectedValue <- predicateDescription$value
      if (expectedValue %in% doNothing){
        return(NULL)
      }
      
      tryCatch(
        terminologyTarget <- staticTerminologyInstances$getTerminologyByClassName(expectedValue)
        , error = function(e){
          print("Error finding terminology")
          return(NULL)
        }
      )
      content <- GLOBALcon$getContextDescriptionTimeline(
        terminologyName = terminologyTarget$terminologyName,
        instanceName = instanceName)
      contextDescription <- GLOBALcon$readContentStandard(content = content)
      descriptionTable <- self$getDescriptionTable(contextDescription,
                          eventType = expectedValue,
                          terminology = terminologyTarget)
      if (is.null(descriptionTable)){
        return(NULL)
      }
      outputId <- self$getVariableDescriptionId()
      self$renderDT(outputId = outputId, 
                    data = descriptionTable)
    },

    setContextDescription = function(contextName){
      print(contextName)
      content <- GLOBALcon$getContextDescriptionTimeline(
        terminologyName = "Graph",
        instanceName = contextName)
      print(content)
      contextDescription <- GLOBALcon$readContentStandard(content = content)
      terminology <- staticTerminologyInstances$getTerminology(staticTerminologyInstances$terminology$Graph$terminologyName)
      self$descriptionTableContext <- self$getDescriptionTable(description = contextDescription, 
                                                   eventType = terminology$mainClassName, 
                                                   terminology = terminology)
      outputId <- self$getContextDescriptionId()
      self$renderDT(outputId = outputId, 
                    data = self$descriptionTableContext)

    },
    
    renderDT = function(outputId, data){
      output[[outputId]] <- DT::renderDataTable(
        DT::datatable(data, options = list(pageLength = 10),
                      selection = "single"),filter="none")
    },
    
    addClickedEventObserver = function(){
      inputName <- paste0(self$getTimelinePlotId(),"_selected")
      self$clickedEventObserver <- observeEvent(input[[inputName]],{
        eventName <- input[[inputName]]
        staticLogger$info("event",eventName, "was clicked on the timeline") 
        self$setEventDescription(eventName)
      })
    },
    
    setTimevisDf = function(){
      content <- GLOBALcon$getContextTimeline(contextName = self$context)
      timevisDf <- GLOBALcon$readContentStandard(content = content)
      
      ## date format : 
      timevisDf$beginningDate <- self$changeDateFormat(timevisDf$beginningDate)
      timevisDf$endingDate <-  self$changeDateFormat(timevisDf$endingDate)
      
      colnames(timevisDf) <- c("event","group","start","end")
      
      timevisDf$id <- timevisDf$event
      timevisDf$event <- NULL
      
      timevisDf$duration <- private$getTimeDiff(timevisDf$end, timevisDf$start)
      bool <- timevisDf$end == timevisDf$start
      ## event must not be first row
      timevisDf$end[bool] <- NA ## make time instant, not time interval of 0
      timevisDf$duration[bool] <- ""
      
      self$timevisDf <- timevisDf
      self$updateTimevisDf()
    },
    
    updateTimevisDf = function(){ ## if eventsSelect change => updateTimevisDf
      timevisDf <- self$timevisDf
      bool <- self$eventsSelected$event %in% timevisDf$id
      if (!all(bool)){
        staticLogger$info("eventsSelected not found in timeline of ", self$context,
                          " : ", self$eventsSelected[bool])
        stop("")
      }
      timevisDf <- merge (timevisDf, self$eventsSelected, by.x="id",by.y="event",all.x=T)
      bool <- is.na(timevisDf$content)
      timevisDf$content[bool] <- ""
      bool <- timevisDf$id %in% self$eventsSelected$event
      timevisDf$style <- "background-color: cyan"
      timevisDf$style[bool] <- "background-color: orange"
      self$timevisDf <- timevisDf
    },
    
    changeDateFormat = function(xsdDateTime){
      xsdDateTime <- gsub("T|Z"," ",xsdDateTime)
      xsdDateTime <- gsub("\\.[0-9]+ $","",xsdDateTime)
      return(xsdDateTime)
    },
    
    plotTimeline = function(){
      groups <- names(table(self$timevisDf$group))
      groupsTimevis <- data.frame(
        id = groups,
        content = groups
      )
      output[[self$getTimelinePlotId()]] <- timevis::renderTimevis(
        timevis(self$timevisDf,
                groupsTimevis,
                options = list(clickToUse=F, 
                               multiselect=F)))
    },
    
    getUI = function(){
      ui <- div(id = self$getDivId(),
                timevis::timevisOutput(self$getTimelinePlotId()),
                fluidRow(
                  column(4,
                         h3(GLOBALcontextDescription),
                         DT::dataTableOutput(outputId = self$getContextDescriptionId(),
                                             width = "100%")
                         ),
                  column(4,
                         h3(GLOBALeventDescription),
                         DT::dataTableOutput(outputId = self$getEventDescriptionId(),
                                             width = "100%")
                         ),
                  column(4,
                         h3("Variable description"),
                         DT::dataTableOutput(outputId = self$getVariableDescriptionId(),
                                             width = "100%")
                  )
                  
                )
      )
      return(ui)
    },
    
    insertUItimeline = function(){
      jQuerySelector = paste0("#",self$parentId)
      insertUI(selector = jQuerySelector,
               where = self$where,
               ui = self$getUI())
    },
    
    getDivId = function(){
      return(paste0("timelineInfoDiv",self$parentId))
    }, 
    
    getTimelinePlotId = function(){
      return(paste0("timelinePlotId",self$getDivId()))
    },
    
    getEventDescriptionId = function(){
      return(paste0("getEventDescription",self$getDivId()))
    },
    
    getContextDescriptionId = function(){
      return(paste0("getContextDescription",self$getDivId()))
    },
    
    getVariableDescriptionId = function(){
      return(paste0("getVariableDescription",self$getDivId()))
    }
  ),
  
  private = list(
    
    secondsToDayHourMinuteString = function(nSeconds){
      nDays <- nSeconds /(60 * 60 * 24)
      nDays <- round(nDays,0)
      nSeconds <- nSeconds - (nDays * 60 * 60 *24)
      
      nHours <- nSeconds / (60 * 60)
      nHours <- round(nHours,0)
      nSeconds <- nSeconds - (nHours * 60 * 60)
      
      nMinutes <- nSeconds / (60)
      nMinutes <- round(nMinutes,0)
      # nSeconds <- nSeconds - (nMinutes * 60)
      
      hourMinuteString <- paste0(nDays, " ", GLOBALdays, " - ",
                                 nHours, " ", GLOBALhours, " - ", 
                                 nMinutes, GLOBALminutes)
      return(hourMinuteString)
    },
    
    getTimeDiff = function(endDate, startDate){
      nSeconds <- as.numeric(difftime(endDate, startDate,units = c("secs")))
      hourMinuteString <- private$secondsToDayHourMinuteString(nSeconds)
      return(hourMinuteString)
    }
    
  )
)