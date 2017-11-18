HandleTimelines <- R6::R6Class(
  inherit = uiObject,
  "HandleTimelines",
  public = list(
    searchQueries = NULL,
    validateObserver = NULL,
    changeContextObserver = NULL,
    timeline = NULL,
    # result = NULL,
    
    initialize = function(parentId, where){
      super$initialize(parentId, where)
      self$searchQueries <- SearchQueries$new(parentId = GLOBALtimelineDiv, 
                                              where = "beforeEnd",
                                              validateButtonId = self$getValidateButtonId())
      self$addValidateObserver()
      self$addChangeContextObserver()
    },
    
    insertUIdiv = function(){
      jQuerySelector = paste0("#",self$parentId)
      insertUI(selector = jQuerySelector,
               where = self$where,
               ui = self$getUI())
    },
    
    getUI = function(){
      ui <- div (id = self$getDivId(),
                 shiny::tags$h3(GLOBALtimelineViz,style='text-align:center;margin-top:150px;'),
                 actionButton(inputId = self$getChangeContextButtonId(), label="",
                              icon = icon(name="refresh"))
                 )
    },
    
    getChangeContextButtonId = function(){
      return(paste0("ChangeContext-",self$getDivId()))
    },
    
    addChangeContextObserver = function(){
      self$changeContextObserver <- observeEvent(input[[self$getChangeContextButtonId()]],{
        self$setTimeline()
      })
    },
    ### same function in Sankey , not optimal
    addValidateObserver = function(){
      self$validateObserver <- observeEvent(input[[self$getValidateButtonId()]],{
        staticLogger$user("Validate Button Timeline clicked ")
        
        if (is.null(self$searchQueries$xmlSearchQuery)){
            staticLogger$info("HandleTimeline : no query selected")
            return(NULL)
        }
        self$searchQueries$result <-  Result$new(self$searchQueries$xmlSearchQuery)
        self$setTimeline()
        # queryChoice <- input[[self$searchQueries$getSelectizeResultId()]]
        # 
        # if (is.null(queryChoice) || queryChoice == ""){
        #   staticLogger$info("No query selected")
        #   return(NULL)
        # }
        # 
        # queryChoice <- gsub(GLOBALquery,"",queryChoice)
        # queryChoice <- as.numeric(queryChoice)
        # lengthListResults <- length(GLOBALlistResults$listResults)
        # bool <- queryChoice > lengthListResults
        # if (bool){
        #   stop("queryChoice number not found in GLOBALlistResults ")
        # }
        # self$result <- GLOBALlistResults$listResults[[queryChoice]]
      })
    },
    
    setTimeline = function(){
      resultDf <- self$searchQueries$result$resultDf
      if (nrow(resultDf) == 0){
        staticLogger$info("HandleTimeline : resultDf nrow is 0, timeline can't be made")
        return(NULL)
      }
      Ncontexts <- length(unique(resultDf$context))
      randomContext <- sample(unique(resultDf$context),size=1)
      staticLogger$info("randomContext : ", randomContext)
      contextEvents <- subset (resultDf, context == as.character(randomContext))
      nColumns <- length(contextEvents)
      eventsSelected <- NULL
      for (i in 2:nColumns){
        eventsSelected <- c(eventsSelected, as.character(contextEvents[,i]))
      }
      contextEvents <- data.frame(context = randomContext, event = eventsSelected)
      if (is.null(self$timeline)){
        self$insertUIdiv()
        self$timeline <- Timeline$new(parentId=self$getDivId(),
                                 where="beforeEnd",
                                 contextEvents = contextEvents)
      } else {
        self$timeline$setContextEvents(contextEvents)
      }
    },
    
    getDivId = function(){
      return(paste0("HandleTimelineDiv-",self$parentId))
    },
    
    getValidateButtonId = function(){
      return(paste0("buttonValidateResult-",self$getDivId()))
    }
  )
)