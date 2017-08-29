EventTabpanel <- R6::R6Class(
  "EventTabpanel",
  
  public=list(
    eventNumber = numeric(),
    context = character(),
    hierarchicalObject = NULL,
    listButtonFilterObject = list(),
    listButtonFilterObserver = list(),
    eventType = NULL,
    
    initialize = function(eventNumber, context){
      self$eventNumber <- eventNumber
      self$context <- context
      
      jslink$newTabpanel(tabsetPanel = GLOBALeventTabSetPanel, 
                         liText = self$getLiText(),
                         contentId = self$getObjectId())
    },
    
    setHierarchicalObject = function(){
      hierarchicalObject <- HierarchicalSunburst$new(eventNumber = self$eventNumber, 
                                                     context = self$context,
                                                     parentId = private$getFirstDivOfEventId(),
                                                     where = "afterEnd")
      hierarchicalObject$getHierarchicalDataFromServer()
      hierarchicalObject$insertUIandMakePlot()
      self$hierarchicalObject <- hierarchicalObject
      self$addHierarchicalObserver()
    },
    
    getObjectId = function(){
      paste0("eventTabpanel",self$eventNumber)
    },
    
    addHierarchicalObserver = function(){
      observeEvent(input[[self$hierarchicalObject$getInputObserver()]],{
        print("clicked ! ")
        if (!is.null(self$eventType)){
          return(NULL)
        }
        ## choices are validated
        observerInput <- input[[self$hierarchicalObject$getInputObserver()]]
        self$eventType <- self$hierarchicalObject$getEventType(observerInput)
        
        cat(self$eventType)
        ### insert new predicate
        predicatesDf <- GLOBALpredicatesDescription$predicatesDf
        
        predicateDescriptionOfEvent <- GLOBALpredicatesDescription$getPredicateDescriptionOfEvent(self$eventType)
        namesList <- NULL
        for (row in 1:nrow(predicateDescriptionOfEvent)){
          predicateName <- predicateDescriptionOfEvent$predicate[row]
          predicateLabel <- predicateDescriptionOfEvent$label[row]
          predicateComment <- predicateDescriptionOfEvent$comment[row]
          parentId = self$hierarchicalObject$getObjectId()
          where = "afterEnd"
          buttonFilter <- ButtonFilter$new(eventNumber = self$eventNumber, 
                                           predicateName = predicateName,
                                           predicateLabel = predicateLabel,
                                           predicateComment = predicateComment, 
                                           parentId = parentId, 
                                           where = where)
          buttonFilter$makeUI()
          ## add buttonFilter to the list
          nObject <- length(self$listButtonFilterObject)
          self$listButtonFilterObject[[nObject+1]] <- buttonFilter
          namesList <- c(namesList, paste0(buttonFilter$getObjectId()))
          ## add observer
          self$listButtonFilterObserver[[nObject+1]] <- self$addButtonFilterObserver(buttonFilter)
          ## 
        }
        names(self$listButtonFilterObject) <- namesList
        names(self$listButtonFilterObserver) <- namesList
        # names(self$listButtonFilterObserver[[nObject+1]]) <- buttonFilter$getObjectId()
        self$hierarchicalObject$finalize()
        self$hierarchicalObject <- NULL
      },once = T)
    },
    
    addButtonFilterObserver = function(buttonFilter){
      inputName <- paste0(buttonFilter$getObjectId())
      return(observeEvent(input[[inputName]],{
        if (!input[[inputName]]){
          return(NULL)
        }
        
        ### create the right object
        buttonFilter <- self$listButtonFilterObject[[inputName]]
        ## request server here to get dataFrame
        dataFrame <- data.frame(context = "test", event = "test", value=c(1:1000))
        filterObject <- private$createFilterObject(filterType = "NUMERIC",
                                          eventNumber= buttonFilter$eventNumber,
                                          predicateName= buttonFilter$predicateName,
                                          dataFrame = dataFrame)
        jquerySelector <- paste0("#",buttonFilter$getDivId())
        insertUI(selector = jquerySelector, 
                 where = "afterEnd",
                 ui = filterObject$getUI())
        filterObject$addPrivateObservers()
        buttonFilter$setFilterObject(filterObject)
      }))
    },
    
    getLiText = function(){
      return(paste0("event",self$eventNumber))
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
    },
    
    
    availableFilters = c("NUMERIC","DATE","HIERARCHICAL","FACTOR"),
    createFilterObject = function(filterType,
                                  eventNumber, predicateName, dataFrame){
      bool <- filterType %in% private$availableFilters
      if (!bool){
        stop("filterType not in : ",
             paste0(private$availableFilters, collapse = " "))
      }
      if (filterType == "NUMERIC"){
        filterNumeric <- FilterNumeric$new(eventNumber, predicateName, dataFrame)
        return(filterNumeric)
      }
    }
    ))