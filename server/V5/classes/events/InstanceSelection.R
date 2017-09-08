InstanceSelection <- R6::R6Class(
  "InstanceSelection",
  
  public = list(
    contextEnv = environment(),
    terminologyName = character(),
    className = character(),
    contextEvents = list(),
    context = "",
    parentId = character(),
    terminologyDescription = list(),
    listButtonFilterObject = list(),
    listFilters = list(),
    filterReactive = NULL,
    
    initialize = function(contextEnv, terminologyName, className, contextEvents, parentId, where){
      self$contextEnv <- contextEnv
      self$terminologyName <- as.character(terminologyName)
      self$className <- className
      self$contextEvents <- contextEvents
      self$context <- unique(contextEvents$context)
      self$terminologyDescription <- GLOBALterminologyDescription[[self$terminologyName]]
      self$parentId <- parentId
      self$setButtonFilter(parentId, where)
      staticLogger$info("new instanceSelection terminology : ", terminologyName,
                        "location : ", parentId)
      
    },
    
    getEventsSelected = function(){
      if (length(self$listFilters) == 0){
        return(contextEvents$event)
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
    
    getDescription = function(){
      if (length(self$listFilters) == 0){
        return(NULL)
      }
      description <- NULL
      for (filter in self$listFilters){
        description <- append(filter$getDescription(),description)
      }
      return(description)
    }, 
    
    getContextsSelected = function(){
      eventsSelected <- self$getEventsSelected()
      bool <- self$contextEvents$event %in% eventsSelected
      contextsSelected <- unique(as.character(self$contextEvents$context[bool]))
      return(contextsSelected)
    },
    
    printFunction = function(){
      staticLogger$info("FAIT QUELQUE CHOSE YA EU DU CHANGEMENT !! :")
      # print(self$getEventsSelected())
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
      return(NULL)
    },
    
    setButtonFilter = function(parentId, where){
      staticLogger$info("\t setting Button filter in ", self$parentId, "...")
      ### insert new predicate
      staticLogger$info("\t \t getting predicates...")
      predicatesDf <- self$terminologyDescription$predicatesDf
      
      staticLogger$info("\t \t getting predicatesDescription of ", self$className)
      predicateDescriptionOfEvent <- self$terminologyDescription$getPredicateDescriptionOfEvent(self$className)
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
        namesList <- c(namesList, paste0(buttonFilter$getObjectId()))
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
  )
)


PointerEnv <- R6::R6Class(
  "PointerEnv",
  
  public=list(
    contextEnv = environment(), 
    initialize=function(contextEnv){
      self$contextEnv <- contextEnv
    },
    
    destroy = function(){
      self$contextEnv$instanceSelection$destroy()
      self$contextEnv <- NULL
      return(NULL)
    },
    
    getEventsSelected = function(){
      self$contextEnv$instanceSelection$getContextsSelected() ### context corresponds to events
    },
    
    getDescription = function(){
      subDescription <- self$contextEnv$instanceSelection$getDescription()
      if (!is.null(subDescription)){
        subDescription <- paste0("\t", subDescription)
        subDescription <- append(self$contextEnv$instanceSelection$terminologyName, subDescription)
        subDescription <- paste(subDescription, collapse="\n")
      }
      return(subDescription)
    }
  )
)

# library(digest)
# test <- new.env()
# test <- NULL
# test
# Test <- R6::R6Class(
#   "Test",
#   public = list(
#     value = numeric(),
#     getHash = function(){digest::sha1(self$value)},
#     initialize = function(value){
#       self$value <- value
#     }
#   )
# )
# test <- Test$new(10)

# test$getHash()
# digest::sha1(test)
# hash::hash(test)
# ls(test)
