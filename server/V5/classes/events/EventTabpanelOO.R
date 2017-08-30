EventTabpanel <- R6::R6Class(
  "EventTabpanel",
  
  public=list(
    contextEnv = environment(),
    hierarchicalObject = NULL,
    listButtonFilterObject = list(),
    listButtonFilterObserver = list(),
    
    initialize = function(eventNumber, context){
      self$contextEnv <- new.env()
      self$contextEnv$context <- context
      self$contextEnv$eventNumber <- eventNumber
      
      jslink$newTabpanel(tabsetPanel = GLOBALeventTabSetPanel, 
                         liText = self$getLiText(),
                         contentId = self$getObjectId())
    },
    setHierarchicalObject = function(){
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
        print("clicked ! ")
        if (!is.null(self$contextEnv$eventType)){
          return(NULL)
        }
        ## choices are validated
        observerInput <- input[[self$hierarchicalObject$getInputObserver()]]
        self$contextEnv$eventType <- self$hierarchicalObject$getEventType(observerInput)
        
        staticMakeQueries$setContextEvents(self$contextEnv)
        
        ### insert new predicate
        predicatesDf <- GLOBALpredicatesDescription$predicatesDf
        
        predicateDescriptionOfEvent <- GLOBALpredicatesDescription$getPredicateDescriptionOfEvent(self$contextEnv$eventType)
        namesList <- NULL
        for (row in 1:nrow(predicateDescriptionOfEvent)){
          predicateName <- predicateDescriptionOfEvent$predicate[row]
          predicateLabel <- predicateDescriptionOfEvent$label[row]
          predicateComment <- predicateDescriptionOfEvent$comment[row]
          parentId = private$getFirstDivOfEventId()
          buttonFilter <- ButtonFilter$new(contextEnv = self$contextEnv,
                                           predicateName = predicateName,
                                           predicateLabel = predicateLabel,
                                           predicateComment = predicateComment, 
                                           parentId = parentId, 
                                           where = "beforeEnd")
          ## add buttonFilter to the list
          nObject <- length(self$listButtonFilterObject)
          self$listButtonFilterObject[[nObject+1]] <- buttonFilter
          namesList <- c(namesList, paste0(buttonFilter$getObjectId()))
          ## add observer
          #self$listButtonFilterObserver[[nObject+1]] <- self$addButtonFilterObserver(buttonFilter)
          ## 
        }
        names(self$listButtonFilterObject) <- namesList
        #names(self$listButtonFilterObserver) <- namesList
        # names(self$listButtonFilterObserver[[nObject+1]]) <- buttonFilter$getObjectId()
        self$hierarchicalObject$finalize()
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
    
    finalize = function(){
      if (!is.null(self$hierarchicalObject)){
        self$hierarchicalObject$finalize()
      }
      self$removeUI();
      self$removeLi();
    }
    
  ),
      
  private = list(
    getFirstDivOfEventId = function(){
      return(paste0("firstDivOf",self$getObjectId()))
    }
    ))