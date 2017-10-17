EventDiv <- R6::R6Class(
  inherit = uiObject,
  "EventDiv",
  public = list(
    NdivEvents = numeric(),
    
    initialize = function(parentId, where){
      super$initialize(parentId, where)
      self$insertDivUI()
      self$NdivEvents <- 0
      self$updateHTMLdescription0()
    },
    
    insertDivUI = function(){
      ui <- div(id=self$getDivId(),
                h2("Events Description"),
                div(id = self$getDivEventNumberId(0), ## to append eventNumber1
                    shiny::uiOutput(outputId = self$getHTMLdescriptionEventId(
                      eventNumber = 0
                    ))
                    ) 
                )
      jQuerySelector = paste0("#",self$parentId)
      insertUI(
        selector = jQuerySelector,
        where = "beforeEnd",
        ui = ui
      )
    },
    
    getDivId = function(){
      return(paste0("eventDiv",self$parentId))
    },
    
    getHTMLdescriptionEventId = function(eventNumber){
      return(paste0("HTMLdescriptionEventId",eventNumber,self$parentId))
    },
    
    getButtonRemoveId = function(eventNumber){
      return(paste0("buttonRemoveEvent",eventNumber,self$getDivId()))
    },
    
    getDivEventNumberId = function(eventNumber){
      return(paste0("eventDescription",eventNumber,self$getDivId()))
    },
    
    insertNewDivEvent = function(){ ## called when new event is created - empty div
      self$NdivEvents <- self$NdivEvents + 1
      ui <- div(id = self$getDivEventNumberId(eventNumber = self$NdivEvents),
                div(
                  shiny::tags$span(paste0("event",self$NdivEvents), 
                                   class=GLOBALspanEventLabelClass),
                  shiny::actionButton(inputId = self$getButtonRemoveId(self$NdivEvents),
                                      label = "",
                                      icon = icon("remove"))
                ),
                shiny::uiOutput(outputId = self$getHTMLdescriptionEventId(
                  eventNumber = self$NdivEvents
                )))
      parentId <- self$getDivEventNumberId(self$NdivEvents - 1)
      jQuerySelector <- paste0("#",parentId)
      insertUI(
        selector = jQuerySelector,
        where = "afterEnd",
        ui  = ui
      )
      self$addButtonRemoveObserver(self$NdivEvents)
      self$updateHTMLdescription0()
      ## observer : 
    },
    
    emptyDiv = function(eventNumber){
      objectId <- self$getDivEventNumberId(eventNumber)
      session$sendCustomMessage(type = "empty",
                                message = list(objectId = objectId))
    },
    
    addButtonRemoveObserver = function(eventNumber){
      observeEvent(input[[self$getButtonRemoveId(eventNumber)]],{
        staticLogger$user("removeEventTabpanel")
        liText <- paste0("event",eventNumber)
        staticLogger$user(liText, " to remove")
        GLOBALlistEventTabpanel$removeEventTabpanel(liText = liText)
        self$emptyDiv(eventNumber)
        self$updateHTMLdescription0()
        GLOBALqueryBuilder$linkDiv$updateSelectionLink() ## remove event of linkEvent
      },once = T)
    },
    
    getEventDescription = function(eventTabpanel){
      if (!is.null(eventTabpanel$contextEnv$instanceSelection)){
        instanceSelection <- eventTabpanel$contextEnv$instanceSelection
        htmlDescription <- shiny::tagList(
          shiny::tags$p(paste0("type: ", instanceSelection$className)),
          instanceSelection$getHTMLdescription()
        )
      } else {
        htmlDescription <- shiny::tags$p("type: undefined")
      }
      return(htmlDescription)
    },
    
    updateHTMLdescription0 = function(){
      if (length(GLOBALlistEventTabpanel$listEventTabpanel) == 0){
        htmlDescription <- shiny::tags$p("No event selected")
        private$insertHTMLdescription(0,htmlDescription)
      } else {
        private$insertHTMLdescription(0,"")
      }
    },
    
    insertHTMLdescriptions = function(){
      for (eventTabpanel in GLOBALlistEventTabpanel$listEventTabpanel){
        eventNumber <- as.numeric(eventTabpanel$contextEnv$eventNumber)
        htmlDescription <- self$getEventDescription(eventTabpanel)
        private$insertHTMLdescription(eventNumber,htmlDescription)
      }
    }
    
),private=list(
  
  insertHTMLdescription = function(eventNumber, htmlDescription){
    staticLogger$info("Updating",self$getHTMLdescriptionEventId(eventNumber))
    class(htmlDescription) ### can't understand why this is necessary, if not a bug occured !
    ## the value has to be accessed or all events have the same htmlDescription
    output[[self$getHTMLdescriptionEventId(eventNumber)]] <- renderUI({
      htmlDescription
    })
  }
  
))