ButtonFilter <- R6::R6Class(
   inherit = uiObject,
  "ButtonFilter",
  
  public = list(
    contextEnv = environment(),
    predicateName = character(),
    predicateComment = character(),
    predicateLabel = character(),
    filterObject = NULL,
    isChecked = logical(),
    
    initialize = function(contextEnv, 
                          predicateName, 
                          predicateLabel, 
                          predicateComment, 
                          parentId, 
                          where){
      super$initialize(parentId = parentId, where = where)
      private$checkEnvironment(contextEnv)
      self$contextEnv <- contextEnv
      self$predicateName <- predicateName
      self$predicateComment <- predicateComment
      self$predicateLabel <- predicateLabel
      self$makeUI()
      
      self$addButtonFilterObserver()
      self$addHideShowObserver()
      
      private$hideHideShowButton()
      ## hide/show
      
    },
    
    setFilterObject = function(filterObject){
      self$filterObject <- filterObject
    },
    
    getObjectId = function(){
      return(paste0("Button",self$contextEnv$eventNumber, self$predicateName))
    },
    
    getDivId = function(){
      buttonId <- self$getObjectId()
      return(paste0("div",buttonId))
    },
    
    getHideShowId = function(){
      return(paste0("HideShow",self$getObjectId()))
    },
    
    getDivIdSwitches = function(){
      return(paste0("switches",self$getDivId()))
    },
    
    getDivIdFilterObject = function(){
      return(paste0("FilterObject",self$getDivId()))
    },
    
    makeUI = function(){
      ## bold predicate
      htmlText <- paste0("<b>", self$predicateLabel, "</b> (", self$predicateComment, ")")
      # all in div to append filterObject inside
      ui <- div(id = self$getDivId(),
                 HTML("<hr>"),
                          div(id = self$getDivIdSwitches(),
                    shinyWidgets::materialSwitch(inputId = self$getObjectId(), 
                                      label = HTML(htmlText), 
                                      value = FALSE, ### not checked by default
                                      status = "primary", right = T), ### label to the right to align
                    shinyWidgets::radioGroupButtons(inputId = self$getHideShowId(),
                                                    label="",choices = c(GLOBALshow, GLOBALhide),
                                                    selected = GLOBALshow)
                          ), ## end of switches div
                      div(id = self$getDivIdFilterObject())
                                                    #status = c("green","red"),
                ) 
      insertUI(selector = private$getJquerySelector(self$parentId),
               where = self$where,
               ui = ui)
    },
    
    addButtonFilterObserver = function(){
      observeEvent(input[[self$getObjectId()]],{
        isolate(isClickedButtonFilter <- input[[self$getObjectId()]])
        cat("value of isClicked : ", isClickedButtonFilter, "\n")
        if (!isClickedButtonFilter){
          cat ("\t button ", self$getObjectId(), " unclicked \n")
          if (!is.null(self$filterObject)){
            cat ("\t \t removing filterObject of ",self$getObjectId(), "\n")
            self$filterObject$finalize()
            self$filterObject <- NULL
            cat ("\t \t Hidding HideShow button : ",self$getHideShowId(), "\n")
            session$sendCustomMessage(type = "displayHideId",
                                      message = list(objectId = self$getHideShowId()))
          }
          return(NULL)
        }
        
        cat ("button ", self$getObjectId(), " clicked \n")
        
        ## moving the element
        cat ("\t \t moving ",self$getDivId(), " to go first \n")
        private$goToFirstChild()
        
        
        cat ("\t \t new filterObject for ",self$getObjectId(), "\n")
        self$filterObject <- staticFilterCreator$createFilterObject(contextEnv = self$contextEnv,
                                                                    predicateName= self$predicateName,
                                                                    parentId = self$getDivIdFilterObject(),
                                                                    where = "beforeEnd")
        cat ("\t \t showing HideShow button : ",self$getHideShowId(), "\n")
        private$showHideShowButton()
      },ignoreInit=T)
    },
    
    addHideShowObserver = function(){
      observeEvent(input[[self$getHideShowId()]],{
        hideShow <- input[[self$getHideShowId()]]
        if (hideShow == GLOBALshow){
          private$showDivIdFilterObject()
        } else {
          private$hideDivIdFilterObject()
        }
      },ignoreInit=T)
    }
  ),
  
  private = list(
    hideHideShowButton = function(){
      session$sendCustomMessage(type = "displayHideId",
                                message = list(objectId = self$getHideShowId()))
    },
    showHideShowButton = function(){
      session$sendCustomMessage(type = "displayShowId",
                                message = list(objectId = self$getHideShowId()))
    }, 
    
    hideDivIdFilterObject = function(){
      session$sendCustomMessage(type = "displayHideId",
                                message = list(objectId = self$getDivIdFilterObject()))
    }, 
    
    showDivIdFilterObject = function(){
      session$sendCustomMessage(type = "displayShowId",
                                message = list(objectId = self$getDivIdFilterObject()))
    },
    
    goToFirstChild = function(){
      session$sendCustomMessage(type = "goFirstSibling",
                                message = list(objectId = self$getDivId()))
    },
    
    checkEnvironment = function(contextEnv){
      if (!is.environment(contextEnv)){
        stop("contextEnv must be an environment")
      }
      envObjects <- ls(contextEnv)
      expectedObjects <- c("eventNumber", "context")
      bool <-  expectedObjects %in% envObjects
      if (!all(bool)){
        stop("Missing ", expectedObjects[bool], " in context environment for ButtonFilter to work")
      }
      return(NULL)
    }
    
  )
)

# buttonFilter <- ButtonFilter$new(1, "predicateName","comment", "parentId","afterEnd")
