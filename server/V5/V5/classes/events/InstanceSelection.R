InstanceSelection <- R6::R6Class(
  "InstanceSelection",
  
  public = list(
    contextEnvParent = NULL,
    contextEnv = environment(),
    terminology = NULL,
    className = character(),
    contextEvents = list(),
    context = "",
    parentId = character(),
    listButtonFilterObject = list(),
    listFilters = list(),
    
    initialize = function(contextEnv, terminology, className, contextEvents, parentId, where,contextEnvParent=NULL){
      if (!is.null(contextEnvParent)){
        self$contextEnvParent <- contextEnvParent
      }
      self$contextEnv <- contextEnv
      self$terminology <- terminology
      self$className <- className
      self$contextEvents <- contextEvents
      self$context <- unique(contextEvents$context)
      self$parentId <- parentId
      
      staticLogger$info("new instanceSelection terminology : ", self$terminology$terminologyName,
                        "location : ", parentId)
      self$setButtonFilter(private$getButtonFilterParentId(), where)
    },
    
    updateFilters = function(){
      ## updateFilter :
      staticLogger$info("\t updating Filter with new events")
      for (filter in self$listFilters){
        filter$updateDataFrame()
      }
      self$filterHasChanged()
    },
    
    getDescription = function(){
      if (length(self$listFilters) == 0){
        return(NULL)
      }
      description <- list()
      for (filter in self$listFilters){
        description <- append(description,shiny::tagList(filter$getDescription()))
      }
      if (length(description) == 0){
        return(NULL)
      }
      liDescription <- shiny::tagList(description)
      return(liDescription)
    }, 
    
    getValue4Sankey = function(){
      if (length(self$listFilters) == 0){
        return(NULL)
      }
      filter <- self$listFilters[[1]]
      return(filter$getDataFrame())
    },
    
    getEventsSelected = function(){
      if (length(self$listFilters) == 0){
        return(self$contextEvents$event)
      }
      iter <- 1
      events <- NULL
      for (filter in self$listFilters){
        if (iter == 1){
          events <- filter$getEventsSelected()
        } else {
          events <- base::intersect(events, filter$getEventsSelected())
        }
        iter <- iter + 1
      }
      return(events)
    }, 
    
    getContextsSelected = function(){
      eventsSelected <- self$getEventsSelected()
      bool <- self$contextEvents$event %in% eventsSelected
      contextsSelected <- unique(as.character(self$contextEvents$context[bool]))
      return(contextsSelected)
    },
    
    getContextEvents = function(){
      return(self$contextEvents)
    },
    
    addFilter = function(filter, predicateName){
      predicateName <- as.character(predicateName)
      staticLogger$info("\t Adding filter ", predicateName, "to instanceSelection",
                        "located in ", self$parentId)
      lengthList <- length(self$listFilters)
      namesList <- names(self$listFilters)
      self$listFilters[[lengthList+1]] <- filter
      names(self$listFilters) <- append(namesList,predicateName)
      return(NULL)
    },
    
    removeFilter = function(predicateName){
      predicateName <- as.character(predicateName)
      staticLogger$info("\t Trying to remove filter", predicateName, "of instanceSelection",
                        "located in ", self$parentId)
      if (length(self$listFilters) == 0){
        return(NULL)
      }
      namesList <- names(self$listFilters)
      if (predicateName %in% namesList){
        filter <- self$listFilters[[predicateName]]
        filter$destroy()
        self$listFilters[[predicateName]] <- NULL
        staticLogger$info("\t \t", predicateName, "removed")
      } else {
        staticLogger$info("\t" , predicateName, "not found in ", namesList)
      }
      self$filterHasChanged()
      return(NULL)
    },
    
    filterHasChanged = function(){
      staticLogger$info("instanceSelection filterHasChanged")
      if (!is.null(self$contextEnvParent)){
        staticLogger$info("\t passing information to contextEnvParent")
        self$contextEnvParent$instanceSelection$filterHasChanged()
      } else {
        staticLogger$info("\t no contextEnvParent found")
      }
      return(NULL)
    },
    
    setButtonFilter = function(parentId, where){
      staticLogger$info("\t setting Button filter in ", parentId, "...")
      ### insert new predicate
      staticLogger$info("\t \t getting predicatesDescription of ", self$className)
      predicateDescriptionOfEvent <- self$terminology$getPredicateDescriptionOfEvent(eventType = self$className)
      namesList <- NULL
      staticLogger$info("\t creating a list of ButtonFilter...")
      for (row in 1:nrow(predicateDescriptionOfEvent)){
        predicateName <- predicateDescriptionOfEvent$predicate[row]
        predicateLabel <- predicateDescriptionOfEvent$label[row]
        predicateComment <- predicateDescriptionOfEvent$comment[row]
        buttonFilter <- ButtonFilter$new(contextEnv = self$contextEnv,
                                         predicateName = predicateName,
                                         predicateLabel = predicateLabel,
                                         predicateComment = predicateComment,
                                         parentId = parentId, 
                                         where = where)
        ## add buttonFilter to the list
        nObject <- length(self$listButtonFilterObject)
        self$listButtonFilterObject[[nObject+1]] <- buttonFilter
        # namesList <- c(namesList, paste0(buttonFilter$getObjectId()))
        namesList <- c(namesList, as.character(predicateName))
      }
      names(self$listButtonFilterObject) <- namesList
    },
    
    destroy = function(){
      staticLogger$info("Destroying instanceSelection located in : ", self$parentId)
      staticLogger$info("\t Removing every ButtonFilterObject")
      
      staticLogger$info("\t Removing every Filters")
      for (filter in self$listFilters){
        filter$destroy()
      }
      self$listFilters <- NULL
      
      for (button in self$listButtonFilterObject){
        button$destroy()
      }
      self$listButtonFilterObject <- NULL
      return(NULL)
    }
  ),
  private = list(
    getButtonFilterParentId = function(){
      return(self$parentId)
    }
  )
)


PointerEnv <- R6::R6Class(
  "PointerEnv",
  
  public=list(
    contextEnv = environment(),
    predicateName = character(),
    
    initialize=function(contextEnv, predicateName){
      self$contextEnv <- contextEnv
      self$predicateName <- predicateName
    },
    
    destroy = function(){
      self$contextEnv$instanceSelection$destroy()
      self$contextEnv <- NULL
      return(NULL)
    },
    
    getDataFrame = function(){
      dataFrame <- self$contextEnv$instanceSelection$getValue4Sankey()
      if (is.null(dataFrame)){
        return(NULL)
      }
      contextEvents <- self$contextEnv$instanceSelection$contextEvents
      joint <- merge (contextEvents, dataFrame, by="event") ## event => Etablissement31017 for example
      joint <- subset (joint, select=c("context","value"))
      colnames(joint) <- c("event","value")
      return(joint)
    },
    
    updateDataFrame = function(){
      staticLogger$info("Updating Filter PointEnv")
      staticLogger$info("\t getting new contextEvents from instanceSelection Parent")
      
      staticLogger$info("\t setting new contextEvents for instanceSelection")
      contextEvents <- self$contextEnv$instanceSelection$contextEnvParent$instanceSelection$getContextEvents()
      eventType <- self$contextEnv$instanceSelection$contextEnvParent$instanceSelection$className
      staticLogger$info("\t eventType : ", eventType)
      terminologyName <- self$contextEnv$instanceSelection$contextEnvParent$instanceSelection$terminology$terminologyName
      staticLogger$info("\t terminologyName : ", terminologyName)
      predicateName <- self$predicateName
      staticLogger$info("\t previous contextEvents : ", nrow(self$contextEnv$instanceSelection$contextEvents), "lines")
      self$contextEnv$instanceSelection$contextEvents <- staticFilterCreator$getDataFrame(terminologyName, 
                                                                                          eventType, 
                                                                                          contextEvents, 
                                                                                          predicateName)
      colnames(self$contextEnv$instanceSelection$contextEvents) <- c("context","event")
      staticLogger$info("\t new contextEvents : ", nrow(self$contextEnv$instanceSelection$contextEvents), "lines")
      staticLogger$info("\t updating each Filter for FilterPointEnv")
      self$contextEnv$instanceSelection$updateFilters()
      staticLogger$info("End Updating Filter PointEnv")
    },
    
    getXMLpredicateNode = function(){
      tempQuery <- XMLSearchQuery$new()
      chosenValues <- self$contextEnv$instanceSelection$getEventsSelected()
      chosenValues <- unique(chosenValues)
      predicateName <- self$predicateName
      staticLogger$info("PointerEnv chosenValues : ",chosenValues)
      predicateNode <- tempQuery$makePredicateNode(predicateClass = "factor",
                                                   predicateType = predicateName,
                                                   values = chosenValues)
      return(predicateNode)
    },
    
    
    getEventsSelected = function(){
      self$contextEnv$instanceSelection$getContextsSelected() ### context corresponds to events
    },
    
    getDescription = function(){
      subDescription <- self$contextEnv$instanceSelection$getDescription()
      if (!is.null(subDescription)){
        label <- self$getPredicateLabel()
        subDescription <- shiny::tagList(subDescription)
        subDescription <- shiny::tags$li(label, 
                       shiny::tags$ul(subDescription, style = "margin-left:20px"))
      }
      return(subDescription)
    },
    
    getPredicateLabel = function(){
      label <- as.character(self$contextEnv$instanceSelection$contextEnvParent$instanceSelection$terminology$getLabel(self$predicateName))
      return(label)
    }
  )
)

