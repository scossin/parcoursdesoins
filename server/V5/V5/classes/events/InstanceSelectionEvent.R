InstanceSelectionEvent <- R6::R6Class(
  inherit = InstanceSelection,
  "InstanceSelectionEvent",
  
  public = list(
    buttonDescriptionObserver = NULL,
    buttonSearchEventsObserver = NULL,
    
    initialize = function(contextEnv, terminology, className, contextEvents, parentId, where){
      self$parentId <- parentId
      self$addUIselection() ### add UI first because buttonFilter depends on it
      
      super$initialize(contextEnv, terminology, className, contextEvents, parentId, where)
      
      self$addButtonDescriptionObserver()
      self$addButtonSearchEventsObserver()
      
      self$addUIdonut()
      self$filterHasChanged()
      staticLogger$info("new instanceSelectionEvent")
    },
    
    addEventNodeToQuery = function(query, boolGetXMLpredicateNode = T){
      query$addEventNode(eventNumber = self$contextEnv$eventNumber,
                         terminologyName = self$terminology$terminologyName,
                         eventType = self$className)
      if (!length(self$listFilters) == 0 && boolGetXMLpredicateNode){
        for (filter in self$listFilters){
          predicateNode <- filter$getXMLpredicateNode()
          if (is.null(predicateNode)){
            next
          }
          query$addPredicateNode2(eventNumber = self$contextEnv$eventNumber,predicateNode = predicateNode)
        }
      }
      return(query)
    },
    
    searchEvents = function(boolGetXMLpredicateNode = T){
      staticLogger$info("Searching new events...")
      
      staticLogger$info("\t getting predicatesNodes")
      query <- XMLSearchQuery$new()
      query <- self$addEventNodeToQuery(query, boolGetXMLpredicateNode)
      query$addContextNode(self$context)
      
      ## updatingContextEvents 
      staticLogger$info("\t updating ContextEvents")
      self$contextEvents <- staticMakeQueries$getContextEventsQuery(query)
    },
    
    searchAndUpdate = function(boolGetXMLpredicateNode = T){
      self$searchEvents(boolGetXMLpredicateNode)
      self$updateFilters()
    },
    
    filterHasChanged = function(){
      self$getDescription()
      self$makeDescription()
      return(NULL)
    },
    
    getUIdonutId = function(){
      return(paste0("donut",self$getUISelectionId()))
    },
    
    makeDonut = function(){
      output[[self$getUIdonutId()]] <- plotly::renderPlotly({
        events <- self$getEventsSelected()
        events <- as.character(events)
        bool <- self$contextEvents$event %in% events
        df <- data.frame(labels=c("unselected","selected"),
                         values=c(sum(!bool),sum(bool)))
        colors <- c('rgb(0,0,0)','rgb(255,215,0)')
        plotly::plot_ly(data = df, labels = ~labels, values = ~values,
                marker = list(colors=colors)) %>%
          add_pie(hole = 0.6) %>%
          layout(title = "",  showlegend = F,
                 xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                 yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
      })
    },
    
    addUIdonut = function(){
      ui <- plotly::plotlyOutput(outputId = self$getUIdonutId())
      jQuerySelector <- paste0("#",self$getDivDonutId())
      insertUI(selector = jQuerySelector,
               where = "beforeEnd",
               ui = ui)
    },
    
    getDivDonutId = function(){
      return(paste0("divDonut", self$getUISelectionId()))
    },
    
    getDonutId = function(){
      return(paste0("Donut", self$getDivDonutId()))
    },
    
    addUIselection = function(){
      ui <- div(id=self$getUISelectionId(),
                fluidPage(
                  sidebarLayout(
                    sidebarPanel(
                      # actionButton(inputId = self$getButtonDescriptionId(), 
                      #              label = "Description"),
                      shiny::uiOutput(outputId = self$getHTMLdescriptionId()),
                      actionButton(inputId = self$getButtonSearchEventsId(), 
                                   label = private$labelSearchButton)
                    ),
                  mainPanel(
                    div (id=self$getDivDonutId())
                  ))),
                div(id=self$getDivFiltersId())
      )
      jQuerySelector = paste0("#", self$parentId)
      insertUI(selector = jQuerySelector,
               where = "afterBegin",
               ui = ui,
               immediate = T
              )
    },
    
    removeUIselection = function(){
      jQuerySelector = paste0("#", self$getUISelectionId())
      removeUI(selector = jQuerySelector)
    },
    
    addButtonSearchEventsObserver = function(){
      self$buttonSearchEventsObserver <- observeEvent(input[[self$getButtonSearchEventsId()]], {
        staticLogger$info("Search Events clicked !")
        self$searchAndUpdate()
        return(NULL)
      })
    },
    
    getButtonSearchEventsId = function(){
      return(paste0("SearchEvents",self$getUISelectionId(), self$parentId))
    },
    
    getHTMLdescription = function(){
      description <- self$getDescription()
      Nevents <- length(unique(self$contextEvents$event))
      Ncontexts <- length(unique(self$contextEvents$context))
      textType <- paste0("Type:", self$className)
      textNevents <- paste0(Nevents, " ", GLOBALevent, " ", GLOBALselected)
      textNcontexts <- paste0(Ncontexts, " ", GLOBALparcours, " ", GLOBALselected)
      ulDescrition <- shiny::tags$ul(
        shiny::tags$p(textType), 
        shiny::tags$p(textNevents),
        shiny::tags$p(textNcontexts),
        description)
      return(ulDescrition)
    },
    
    makeDescription = function(){
      output[[self$getHTMLdescriptionId()]] <- shiny::renderUI(self$getHTMLdescription())
      self$makeDonut()
    },
    
    addButtonDescriptionObserver = function(){
      self$buttonDescriptionObserver <- observeEvent(input[[self$getButtonDescriptionId()]],{
        self$makeDescription()
      })
    },
    
    getDivFiltersId = function(){
      return(paste0("UIdescription",self$getUISelectionId()))
    },
    
    getUISelectionId = function(){
      return(paste0("UIdescription",self$parentId))
    },
    
    getHTMLdescriptionId = function(){
      return(paste0("html",self$getUISelectionId()))
    },
    
    getButtonDescriptionId = function(){
      return(paste0("ButtonDescription",self$getUISelectionId()))
    },
    
    destroy = function(){
      staticLogger$info("Destroying InstanceSelectionEvent")
      super$destroy()
      
      staticLogger$info("\t Destroying buttonSearchEventsObserver")
      if (!is.null(self$buttonSearchEventsObserver )){
        self$buttonSearchEventsObserver$destroy()
        staticLogger$info("\t  \t done")
      }
      staticLogger$info("\t Destroying buttonDescriptionObserver")
      if (!is.null(self$buttonDescriptionObserver)){
        self$buttonDescriptionObserver$destroy()
        staticLogger$info("\t  \t done")
      }
      
      staticLogger$info("\t Removing UI selection")
      self$removeUIselection()
      
      staticLogger$info("End Destroying InstanceSelectionEvent")
    }
  ),
  
  private = list(
    getButtonFilterParentId = function(){
      return(self$getDivFiltersId())
    },
    labelSearchButton = GLOBALsearchEvents
  )
)