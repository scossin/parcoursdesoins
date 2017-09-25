EventTabpanel <- R6::R6Class(
  "EventTabpanel",
  
  public=list(
    contextEnv = environment(),
    terminology = NULL,
    hierarchicalObject = NULL,
    
    initialize = function(eventNumber, context){
      staticLogger$info("Creating EventTabpanel", eventNumber)
      self$contextEnv <- new.env()
      self$contextEnv$context <- context
      self$contextEnv$eventNumber <- eventNumber
      terminologyName <- staticTerminologyInstances$terminology$Event$terminologyName
      self$terminology <- staticTerminologyInstances$getTerminology(terminologyName)
      private$newTabpanel(tabsetPanel = GLOBALeventTabSetPanel, 
                         liText = self$getLiText(),
                         contentId = self$getObjectId())
    },
    
    updateContext = function(context){
      staticLogger$info("Updating context in EventTabPanel",self$contextEnv$eventNumber)
      self$contextEnv$context <- context
      if (is.null(self$contextEnv$instanceSelection)){
        staticLogger$info("EventTabPanel",self$contextEnv$eventNumber, " : no event selected yet")
        return(NULL)
      }
      self$contextEnv$instanceSelection$context <- context
      self$contextEnv$instanceSelection$searchAndUpdate(boolGetXMLpredicateNode = F) ### search events without filter
      self$contextEnv$instanceSelection$makeDescription()
    },
    
    setHierarchicalObject = function(){
      staticLogger$info("setting a new HierarchicalObject for",self$getObjectId())
      dataFrame <- data.frame(event=character(), value=numeric())
      hierarchicalObject <- FilterHierarchicalEvent$new(contextEnv = self$contextEnv,
                                                     terminology = self$terminology,
                                                     predicateName = "hasType", ## hard coded ...
                                                     dataFrame = dataFrame,
                                                     parentId = private$getFirstDivOfEventId(),
                                                     where = "beforeEnd")
      self$hierarchicalObject <- hierarchicalObject
      self$addHierarchicalObserver()
    },
    
    getObjectId = function(){
      paste0("eventTabpanel",self$contextEnv$eventNumber)
    },
    
    addHierarchicalObserver = function(){
      observeEvent(input[[self$hierarchicalObject$getButtonValidateId()]],{
        staticLogger$user("Button validate cliked of HierarchicalObjectEvent")
        if (!is.null(self$contextEnv$eventType)){
          staticLogger$info("\t nothing to do : eventType already choosen")
          return(NULL)
        }
        ## choices are validated
        eventType <- self$hierarchicalObject$getEventChoice()
        staticLogger$user("\t clicked value : ",eventType)
        if (eventType %in% c(GLOBALnoselected, GLOBALmanyselected)){
          staticLogger$info("\t Bad choice for event selection : ")
          return(NULL)
        }
        self$contextEnv$eventType <- eventType
        
        staticLogger$info("\t getting events ...")
        contextEvents <- staticMakeQueries$getContextEvents(eventNumber = self$contextEnv$eventNumber,
                                           terminologyName = self$terminology$terminologyName,
                                           eventType = self$contextEnv$eventType, 
                                           context = self$contextEnv$context)
        parentId = private$getFirstDivOfEventId()
        where = "beforeEnd"
        self$contextEnv$instanceSelection <- InstanceSelectionEvent$new(contextEnv = self$contextEnv, 
                                                        terminology = self$terminology, 
                                                        className = self$contextEnv$eventType, 
                                                        contextEvents = contextEvents, 
                                                        parentId = parentId, 
                                                        where = where
                                                        )

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
      staticLogger$info("Destroying EventTabPanel ", self$getObjectId())
      if (!is.null(self$hierarchicalObject)){
        self$hierarchicalObject$destroy()
      }
      if (!is.null(self$contextEnv$instanceSelection)){
        self$contextEnv$instanceSelection$destroy()
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



