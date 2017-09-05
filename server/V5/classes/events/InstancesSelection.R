InstanceSelection <- R6::R6Class(
  "InstanceSelection",
  
  public = list(
    contextEnv = environment(),
    terminologyName = character(),
    className = character(),
    contextEvents = list(),
    context = "",
    terminologyDescription = list(),
    listButtonFilterObject = list(),
    listFilters = list(),
    
    initialize = function(contextEnv, terminologyName, className, contextEvents, parentId, where){
      self$contextEnv = contextEnv
      print(ls(contextEnv))
      self$terminologyName = terminologyName
      self$className = className
      self$contextEvents = contextEvents
      self$context = unique(contextEvents$context)
      self$terminologyDescription <- GLOBALterminologyDescription[[terminologyName]]
      self$setButtonFilter(parentId, where)
      staticLogger$info("\t new instanceSelection created of terminology : ", terminologyName)
    },
    
    getContextEvents = function(){
      return(self$contextEvents)
    },
    
    addFilter = function(filter, predicateName){
      predicateName <- as.character(predicateName)
      staticLogger$info("\t Adding a filter ", predicateName, "to instanceSelection")
      lengthList <- length(self$listFilters)
      namesList <- names(self$listFilters)
      self$listFilters[[lengthList+1]] <- filter
      names(self$listFilters) <- append(namesList,predicateName)
      return(NULL)
    },
    
    removeFilter = function(predicateName){
      predicateName <- as.character(predicateName)
      staticLogger$info("\t Trying to remove filter", predicateName, "of instanceSelection")
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
      ### insert new predicate
      staticLogger$info("\t getting predicates...")
      predicatesDf <- self$terminologyDescription$predicatesDf
      
      staticLogger$info("\t getting predicatesDescription of ", self$className)
      predicateDescriptionOfEvent <- self$terminologyDescription$getPredicateDescriptionOfEvent(self$className)
      namesList <- NULL
      staticLogger$info("Creating a list of ButtonFilter...")
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
      for (button in self$listButtonFilterObject){
        staticLogger$info("Removing ButtonFilterObject before destroying")
        button$removeUI()
      }
      for (filter in self$listFilters){
        staticLogger$info("Removing listFilters before destroying")
        filter$destroy()
      }
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
    }
  )
)