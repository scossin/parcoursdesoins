EventTabpanel <- R6::R6Class(
  "EventTabpanel",
  
  public=list(
    eventNumber = numeric(),
    hierarchicalObject = NULL,
    listButtonFilterObject = list(),
    listButtonFilterObserver = list(),
    eventType = NULL,
    
    initialize = function(eventNumber,hierarchicalObject){
      self$eventNumber <- eventNumber
      bool <- inherits(hierarchicalObject, "Hierarchical")
      if (!bool){
        stop("hierarchicalObject must be a Hierarchical instance")
      }
      self$hierarchicalObject <- hierarchicalObject
    },
    
    getObjectId = function(){
      paste0("eventTabpanel",self$eventNumber)
    },
    
    getTabpanel = function(){
      tab <- shiny::tabPanel(
        self$getObjectId(), class="tabset",
        fluidRow(
          column(12,
            self$hierarchicalObject$getUI()
        )
      )
      )
      return(tab)
    },
    
    addHierarchicalObserver = function(){
      observeEvent(input[[self$hierarchicalObject$getInputObserver()]],{
        print("clicked ! ")
        if (!is.null(self$eventType)){
          return(NULL)
        }
        ## choices are validated
        hierarchicalChoice <- input[[self$hierarchicalObject$getInputObserver()]]
        self$eventType <- self$hierarchicalObject$getEvent(hierarchicalChoice)
        self$hierarchicalObject$setUI() ## replot with new sizes
        
        ### insert new predicate
        colnames(GLOBALpredicatesDescription)
        print(self$eventType)
        
        predicateDescription <- subset (GLOBALpredicatesDescription, eventType %in% self$eventType)
        namesList <- NULL
        for (ligne in 1:nrow(predicateDescription)){
          predicateName <- predicateDescription$predicate[ligne]
          comment <- predicateDescription$comment[ligne]
          buttonFilter <- ButtonFilter$new(self$eventNumber, predicateName,comment)
          jquerySelector <- paste0("#",hierarchicalObject$getObjectId())
          insertUI(selector = jquerySelector,
                   where = "afterEnd",
                   ui = buttonFilter$getUI())
          
          ## add buttonFilter to the list
          nObject <- length(self$listButtonFilterObject)
          self$listButtonFilterObject[[nObject+1]] <- buttonFilter
          namesList <- c(namesList, paste0(buttonFilter$getButtonId()))
          ## add observer
          self$listButtonFilterObserver[[nObject+1]] <- self$addButtonFilterObserver(buttonFilter)
          ## 
        }
        names(self$listButtonFilterObject) <- namesList
        names(self$listButtonFilterObserver) <- namesList
        # names(self$listButtonFilterObserver[[nObject+1]]) <- buttonFilter$getButtonId()
      },once = T)
    },
    
    addButtonFilterObserver = function(buttonFilter){
      inputName <- paste0(buttonFilter$getButtonId())
      return(observeEvent(input[[inputName]],{
        if (!input[[inputName]]){
          return(NULL)
        }
        ### check predicate and category expected 
        print("clicked !" )
        
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
    }
    
  ),
  private = list(
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