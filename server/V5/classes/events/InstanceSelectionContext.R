InstanceSelectionContext <- R6::R6Class(
  inherit = InstanceSelection,
  "InstanceSelectionContext",
  
  public = list(
    buttonDescriptionObserver = NULL,
    buttonSearchContextsObserver = NULL,
    
    initialize = function(contextEnv, terminologyName, className, contextEvents, parentId, where){
      self$contextEnv <- contextEnv
      self$terminologyName <- as.character(terminologyName)
      self$className <- className
      self$contextEvents <- contextEvents
      self$context <- unique(contextEvents$context)
      self$terminologyDescription <- GLOBALterminologyDescription[[self$terminologyName]]
      self$parentId <- parentId
      self$addUIselection()
      self$addButtonDescriptionObserver()
      self$addButtonSearchContextsObserver()
      self$addUpdateContextsObserver()
      self$setButtonFilter(self$getDivFiltersId(), where)
      staticLogger$info("new instanceSelectionContext")
    },
    
    updateContextTabPanel = function(){
      GLOBALlistEventTabpanel$updateContext(self$context)
    },
    
    searchAndUpdate = function(){
      staticLogger$info("Searching new contexts...")
      
      staticLogger$info("\t getting predicatesNodes")
      query <- XMLSearchQueryTerminology$new()
      query$addEventNode(eventNumber = self$contextEnv$eventNumber,
                         terminologyName = self$terminologyName,
                         eventType = self$className)
      if (!length(self$listFilters) == 0){
        for (filter in self$listFilters){
          predicateNode <- filter$getXMLpredicateNode()
          query$addPredicateNode2(eventNumber = self$contextEnv$eventNumber,predicateNode = predicateNode)
        }
      }
      ## updatingContextEvents 
      staticLogger$info("\t updating ContextEvents")
      self$contextEvents <- staticMakeQueries$getContext(query)
      self$context <- unique(self$contextEvents$context)
      ## updateFilter :
      self$updateFilters()
    },
    
    addUIselection = function(){
      ui <- div(id=self$getUISelectionId(),
                actionButton(inputId = self$getButtonDescriptionId(), 
                             label = "Description"),
                actionButton(inputId = self$getButtonSearchContextsId(), 
                             label = "Search"),
                actionButton(inputId = self$getButtonUpdateContextsId(), 
                             label = "Update Context"),
                verbatimTextOutput(outputId = self$getTextDescriptionId()),
                div(id=self$getDivFiltersId())
      )
      jQuerySelector = paste0("#", self$parentId)
      insertUI(selector = jQuerySelector,
               where = "afterBegin",
               ui = ui)
    },
    
    getButtonUpdateContextsId = function(){
      return(paste0("UpdateContexts",self$getUISelectionId()))
    },
    
    addUpdateContextsObserver = function(){
      observeEvent(input[[self$getButtonUpdateContextsId()]],{
        GLOBALlistEventTabpanel$updateContext(self$context)
      })
    },
    
    removeUIselection = function(){
      jQuerySelector = paste0("#", self$getUISelectionId())
      removeUI(selector = jQuerySelector)
    },
    
    addButtonSearchContextsObserver = function(){
      self$buttonSearchContextsObserver <- observeEvent(input[[self$getButtonSearchContextsId()]], {
        staticLogger$info("Search Contexts clicked !")
        self$searchAndUpdate()
        return(NULL)
      })
    },
    
    getButtonSearchContextsId = function(){
      return(paste0("SearchContexts",self$getUISelectionId()))
    },
    
    addButtonDescriptionObserver = function(){
      self$buttonDescriptionObserver <- observeEvent(input[[self$getButtonDescriptionId()]],{
        description <- self$getDescription()
        description <- paste(description, collapse="\n")
        Nevents <- length(unique(self$contextEvents$event))
        Ncontexts <- length(unique(self$contextEvents$context))
        text <- paste0(self$terminologyName, " : ", self$className, "\t",Nevents," instances",
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
      
      staticLogger$info("\t Destroying buttonSearchContextsObserver")
      if (!is.null(self$buttonSearchContextsObserver )){
        self$buttonSearchContextsObserver$destroy()
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
  )
)