InstanceSelectionContext <- R6::R6Class(
  inherit = InstanceSelectionEvent,
  "InstanceSelectionContext",
  
  public = list(
    initialize = function(contextEnv, terminology, className, contextEvents, parentId, where){
      super$initialize(contextEnv, terminology, className, contextEvents, parentId, where)
      self$addButtonUpdate()
      self$addUpdateContextsObserver()
    },
    
    updateContextTabPanel = function(){
      GLOBALlistEventTabpanel$updateContext(self$context)
    },
    
    searchEvents = function(boolGetXMLpredicateNode = T){
      staticLogger$info("Searching new contexts...")
      
      staticLogger$info("\t getting predicatesNodes")
      query <- XMLSearchQueryTerminology$new()
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
      ## updatingContextEvents 
      staticLogger$info("\t updating ContextEvents")
      self$contextEvents <- staticMakeQueries$getContext(query)
      self$context <- unique(self$contextEvents$context)
    },
    
    addButtonUpdate = function(){
      ui <- actionButton(inputId = self$getButtonUpdateContextsId(), 
                         label = GLOBALupdateContext)
      jQuerySelector = paste0("#", self$getButtonSearchEventsId())
      insertUI(selector = jQuerySelector,
               where = "afterEnd",
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
    
    getHTMLdescription = function(){
      description <- self$getDescription()
      Ncontexts <- length(unique(self$contextEvents$context))
      text <- paste0(Ncontexts, " ", GLOBALparcours, " ", GLOBALselected)
      ulDescrition <- shiny::tags$ul(text, description)
      return(ulDescrition)
    }
    
  ), 
  private = list(
    labelSearchButton = GLOBALsearchContexts
  )
)