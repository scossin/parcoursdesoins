Timeline <- R6::R6Class(
  inherit = uiObject,
  "Timeline",
  public = list(
    context = character(),
    eventsSelected = data.frame(),
    timevisDf = character(),
    clickedEventObserver = NULL,
    terminology = NULL,
    
    initialize = function(parentId, where, contextEvents){
      super$initialize(parentId, where)
      self$insertUItimeline()
      self$terminology <- staticTerminologyInstances$getTerminology(staticTerminologyInstances$terminology$Event$terminologyName)
      self$setContextEvents(contextEvents)
      self$addClickedEventObserver()
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
      predicates <- terminology$getPredicatesOfEvent(eventType)
      bool <- description$predicate %in% predicates
      description <- subset (description, bool)
      
      ## replace predicateName by predicate Label
      predicatesName <- description$predicate
      predicatesLabel <- sapply(predicatesName, function(x){
        terminology$getLabel(predicateName = x)
      })
      predicatesLabel <- as.character(predicatesLabel)
      description$predicate <- predicatesLabel
      colnames(description) <- c(GLOBALvariable, GLOBALvalue)
      return(description)
      return(eventDescription)
    },
    
    setEventDescription = function(eventName){
      if (is.null(eventName)){
        output[[self$getEventDescriptionId()]] <- shiny::renderTable(
          data.frame())
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
      
      descriptionTable <- self$getDescriptionTable(description = eventDescription, 
                                                   eventType = eventType, 
                                                   terminology = self$terminology)
      output[[self$getEventDescriptionId()]] <- shiny::renderTable(descriptionTable)
    },
    
    setContextDescription = function(contextName){
      print(contextName)
      content <- GLOBALcon$getContextDescriptionTimeline(contextName = contextName)
      print(content)
      contextDescription <- GLOBALcon$readContentStandard(content = content)
      terminology <- staticTerminologyInstances$getTerminology(staticTerminologyInstances$terminology$Graph$terminologyName)
      descriptionTable <- self$getDescriptionTable(description = contextDescription, 
                                                   eventType = terminology$mainClassName, 
                                                   terminology = terminology)
      output[[self$getContextDescriptionId()]] <- shiny::renderTable(descriptionTable)

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
                  column(6,
                         h3(GLOBALcontextDescription),
                         shiny::tableOutput(outputId = self$getContextDescriptionId())
                         ),
                  column(6,
                         h3(GLOBALeventDescription),
                         shiny::tableOutput(outputId = self$getEventDescriptionId())
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
      
      hourMinuteString <- paste0(nDays, "days - ", nHours, "hours - ", nMinutes, "minutes")
      return(hourMinuteString)
    },
    
    getTimeDiff = function(endDate, startDate){
      nSeconds <- as.numeric(difftime(endDate, startDate,units = c("secs")))
      hourMinuteString <- private$secondsToDayHourMinuteString(nSeconds)
      return(hourMinuteString)
    }
    
  )
)