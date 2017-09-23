InstanceSelectionEvent <- R6::R6Class(
  inherit = InstanceSelection,
  "InstanceSelectionEvent",
  
  public = list(
    buttonDescriptionObserver = NULL,
    buttonSearchEventsObserver = NULL,
    
    initialize = function(contextEnv, terminology, className, contextEvents, parentId, where){
      self$parentId <- parentId
      self$addUIselection()
      
      super$initialize(contextEnv, terminology, className, contextEvents, parentId, where)
      
      self$addButtonDescriptionObserver()
      self$addButtonSearchEventsObserver()

      staticLogger$info("new instanceSelectionEvent")
    },
    
    searchAndUpdate = function(){
      staticLogger$info("Searching new events...")
      
      staticLogger$info("\t getting predicatesNodes")
      query <- XMLSearchQuery$new()
      query$addContextNode(self$context)
      query$addEventNode(eventNumber = self$contextEnv$eventNumber,
                         terminologyName = self$terminology$terminologyName,
                         eventType = self$className)
      if (!length(self$listFilters) == 0){
        for (filter in self$listFilters){
          predicateNode <- filter$getXMLpredicateNode()
          if (is.null(predicateNode)){
            next
          }
          query$addPredicateNode2(eventNumber = self$contextEnv$eventNumber,predicateNode = predicateNode)
        }
      }
      
      ## updatingContextEvents 
      staticLogger$info("\t updating ContextEvents")
      self$contextEvents <- staticMakeQueries$getContextEventsQuery(query)
      
      ## updateFilter :
      self$updateFilters()
    },
    
    addUIselection = function(){
      ui <- div(id=self$getUISelectionId(),
                actionButton(inputId = self$getButtonDescriptionId(), 
                             label = "Description"),
                actionButton(inputId = self$getButtonSearchEventsId(), 
                             label = "Search"),
                verbatimTextOutput(outputId = self$getTextDescriptionId()),
                div(id=self$getDivFiltersId())
      )
      jQuerySelector = paste0("#", self$parentId)
      insertUI(selector = jQuerySelector,
               where = "afterBegin",
               ui = ui)
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
      return(paste0("SearchEvents",self$getUISelectionId()))
    },
    
    addButtonDescriptionObserver = function(){
      self$buttonDescriptionObserver <- observeEvent(input[[self$getButtonDescriptionId()]],{
        description <- self$getDescription()
        description <- paste(description, collapse="\n")
        Nevents <- length(unique(self$contextEvents$event))
        Ncontexts <- length(unique(self$contextEvents$context))
        text <- paste0(self$terminology$terminologyName, " : ", self$className, "\t",Nevents," instances",
                       "\t", Ncontexts, " graphes",
                       "\n",description)
        output[[self$getTextDescriptionId()]] <- shiny::renderText(text)
      })
    },
    
    getDivFiltersId = function(){
      return(paste0("UIdescription",self$getUISelectionId()))
    },
    
    getUISelectionId = function(){
      return(paste0("UIdescription",self$parentId))
    },
    
    getTextDescriptionId = function(){
      return(paste0("Text",self$getUISelectionId()))
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
    }
  )
)