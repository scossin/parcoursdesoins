EventTabpanel <- R6::R6Class(
  "EventTabpanel",
  
  public=list(
    contextEnv = environment(),
    hierarchicalObject = NULL,
    # listButtonFilterObject = list(),
    # listButtonFilterObserver = list(),
    instanceSelection = NULL,
    
    initialize = function(eventNumber, context){
      staticLogger$info("Creating EventTabpanel", eventNumber)
      self$contextEnv <- new.env()
      self$contextEnv$context <- context
      self$contextEnv$eventNumber <- eventNumber
      #self$contextEnv$terminologyName <- GLOBALcon$terminology$Event
      
      private$newTabpanel(tabsetPanel = GLOBALeventTabSetPanel, 
                         liText = self$getLiText(),
                         contentId = self$getObjectId())
    },
    
    setHierarchicalObject = function(){
      staticLogger$info("setting a new HierarchicalObject for",self$getObjectId())
      hierarchicalObject <- HierarchicalSunburst$new(contextEnv = self$contextEnv,
                                                     parentId = private$getFirstDivOfEventId(),
                                                     where = "beforeEnd")
      hierarchicalObject$getHierarchicalDataFromServer()
      hierarchicalObject$insertUIandMakePlot()
      self$hierarchicalObject <- hierarchicalObject
      self$addHierarchicalObserver()
    },
    
    getObjectId = function(){
      paste0("eventTabpanel",self$contextEnv$eventNumber)
    },
    
    addHierarchicalObserver = function(){
      observeEvent(input[[self$hierarchicalObject$getInputObserver()]],{
        staticLogger$user(self$hierarchicalObject$getObjectId(),"clicked")
        if (!is.null(self$contextEnv$eventType)){
          staticLogger$info("\t nothing to do : eventType already choosen")
          return(NULL)
        }
        ## choices are validated
        observerInput <- input[[self$hierarchicalObject$getInputObserver()]]
        staticLogger$user("\t clicked value : ",observerInput)
        self$contextEnv$eventType <- self$hierarchicalObject$getEventType(observerInput)
        staticLogger$info("\t event choosen : ",  self$contextEnv$eventType )
        
        staticLogger$info("\t getting events ...")
        contextEvents <- staticMakeQueries$getContextEvents(eventNumber = self$contextEnv$eventNumber, 
                                           eventType = self$contextEnv$eventType, 
                                           context = self$contextEnv$context)
        parentId = private$getFirstDivOfEventId()
        where = "beforeEnd"
        self$contextEnv$instanceSelection <- InstanceSelection$new(contextEnv = self$contextEnv, 
                                                        terminologyName = GLOBALcon$terminology$Event, 
                                                        className = self$contextEnv$eventType, 
                                                        contextEvents = contextEvents, 
                                                        parentId = parentId, 
                                                        where = where
                                                        )

        # staticMakeQueries$getContextEvents(self$contextEnv)
        
        ### insert new predicate
        # staticLogger$info("\t getting predicates...")
        # predicatesDf <- GLOBALterminologyDescription[[self$contextEnv$terminologyName]]$predicatesDf
        # 
        # staticLogger$info("\t getting predicatesDescription...")
        # predicateDescriptionOfEvent <- GLOBALterminologyDescription[[self$contextEnv$terminologyName]]$getPredicateDescriptionOfEvent(self$contextEnv$eventType)
        # namesList <- NULL
        # staticLogger$info("Creating a list of ButtonFilter...")
        # for (row in 1:nrow(predicateDescriptionOfEvent)){
        #   predicateName <- predicateDescriptionOfEvent$predicate[row]
        #   predicateLabel <- predicateDescriptionOfEvent$label[row]
        #   predicateComment <- predicateDescriptionOfEvent$comment[row]
        #   parentId = private$getFirstDivOfEventId()
        #   buttonFilter <- ButtonFilter$new(contextEnv = self$contextEnv,
        #                                    predicateName = predicateName,
        #                                    predicateLabel = predicateLabel,
        #                                    predicateComment = predicateComment, 
        #                                    parentId = parentId, 
        #                                    where = "beforeEnd")
        #   ## add buttonFilter to the list
        #   nObject <- length(self$listButtonFilterObject)
        #   self$listButtonFilterObject[[nObject+1]] <- buttonFilter
        #   namesList <- c(namesList, paste0(buttonFilter$getObjectId()))
        # }
        # names(self$listButtonFilterObject) <- namesList
        staticLogger$info("Destroying hierarchical object")
        self$hierarchicalObject$destroy()
        self$hierarchicalObject <- NULL
      },once = T)
    },
    
    getLiText = function(){
      return(paste0("event",self$contextEnv$eventNumber))
    },
    
    removeUI = function(){
      session$sendCustomMessage(type = "removeId", 
                                message = list(objectId = self$getObjectId()))
    },
    
    removeLi = function(){
      liSelector <- paste0("li a[href='#",self$getObjectId(),"']")
      removeUI(selector = liSelector)
    },
    
    destroy = function(){
      staticLogger$info("Finalizing hierarchical object",self$getObjectId())
      if (!is.null(self$hierarchicalObject)){
        self$hierarchicalObject$destroy()
      }
      self$removeUI();
      self$removeLi();
    }
    
  ),
      
  private = list(
    getFirstDivOfEventId = function(){
      return(paste0("firstDivOf",self$getObjectId()))
    },
    
    newTabpanel = function(tabsetPanel, liText, contentId){
      staticLogger$info("Sending Js message to create a new tab", tabsetPanel, liText, contentId)
      session$sendCustomMessage(type = "newTabpanel", 
                                message = list(tabsetPanel = tabsetPanel,
                                               liText = liText, contentId=contentId))}
    )
  )



