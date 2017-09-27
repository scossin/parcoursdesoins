ButtonFilter <- R6::R6Class(
   inherit = uiObject,
  "ButtonFilter",
  
  public = list(
    contextEnv = environment(),
    predicateName = character(),
    predicateComment = character(),
    predicateLabel = character(),
    isChecked = logical(),
    hideShowObserver = NULL,
    buttonFilterObserver = NULL,
    
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
      staticLogger$info("new ButtonFilter",self$getObjectId())
    },
    
    getObjectId = function(){
      return(paste0("ButtonFilter", self$predicateName, "-",self$parentId))
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
    
    # removeUI = function(){
    #   session$sendCustomMessage(type = "removeId",
    #                             message = list(objectId = self$getObjectId()))
    #   session$sendCustomMessage(type = "removeId",
    #                             message = list(objectId = self$getDivId()))
    # },
    
    destroy = function(){
      staticLogger$info("Destroying Button Filter",self$getObjectId())
      jQuerySelector <- paste0("#", self$getHideShowId())
      removeUI(jQuerySelector)
      jQuerySelector <- paste0("#", self$getObjectId())
      removeUI(jQuerySelector)
      jQuerySelector <- paste0("#", self$getDivIdSwitches())
      removeUI(jQuerySelector)
      jQuerySelector <- paste0("#", self$getDivId())
      removeUI(jQuerySelector)
      
      staticLogger$info("\t Removing hideShowObserver")
      if (!is.null(self$hideShowObserver)){
        self$hideShowObserver$destroy()
        staticLogger$info("\t \t done")
      }
      staticLogger$info("\t Removing buttonFilterObserver")
      if (!is.null(self$buttonFilterObserver)){
        self$buttonFilterObserver$destroy()
        staticLogger$info("\t \t done")
      }
      staticLogger$info("End destroying Button Filter",self$getObjectId())
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
      self$buttonFilterObserver <- observeEvent(input[[self$getObjectId()]],{
        isClickedButtonFilter <- input[[self$getObjectId()]]
        staticLogger$user(self$getObjectId(), "was clicked")
        if (!isClickedButtonFilter){
          staticLogger$user("\t",self$getObjectId(), "turned off")
          staticLogger$info("\t removing filterObject of ",self$getObjectId())
          self$contextEnv$instanceSelection$removeFilter(self$predicateName)
          staticLogger$info("\t Hidding HideShow button : ",self$getHideShowId())
          session$sendCustomMessage(type = "displayHideId",
                                    message = list(objectId = self$getHideShowId()))
          staticLogger$info("\t GLOBALshow HideShow button : ",self$getHideShowId())
          shinyWidgets::updateRadioGroupButtons(session,inputId = self$getHideShowId(),
                                          label="",choices = c(GLOBALshow, GLOBALhide),
                                          selected = GLOBALshow)
          return(NULL)
        }
        
        staticLogger$user(self$getObjectId(), " turned on")
        
        ## moving the element
        private$goToFirstChild()
        
        staticLogger$info("\t \t new filterObject for ",self$getObjectId())
        contextEvents <- self$contextEnv$instanceSelection$getContextEvents()
        eventNumber <- self$contextEnv$eventNumber
        eventType <- self$contextEnv$instanceSelection$className
        terminology <- self$contextEnv$instanceSelection$terminology
        
        filterObject <- staticFilterCreator$createFilterObject(contextEnv = self$contextEnv,
                                                               eventType = eventType, 
                                                               contextEvents = contextEvents, 
                                                               predicateName= self$predicateName,
                                                               terminology = terminology,
                                                               parentId = self$getDivIdFilterObject(),
                                                               where = "beforeEnd"
        )
        self$contextEnv$instanceSelection$addFilter(filterObject, self$predicateName)
        staticLogger$info("\t \t showing HideShow button : ",self$getHideShowId())
        private$showHideShowButton()
      },ignoreInit = T)
    },
    
    addHideShowObserver = function(){
      self$hideShowObserver <- observeEvent(input[[self$getHideShowId()]],{
        hideShow <- input[[self$getHideShowId()]]
        if (hideShow == GLOBALshow){
          private$showDivIdFilterObject()
        } else {
          private$hideDivIdFilterObject()
        }
      },ignoreInit = T)
    }
  ),
  
  private = list(
    hideHideShowButton = function(){
      staticLogger$info("Sending Js function to hide ",self$getHideShowId())
      session$sendCustomMessage(type = "displayHideId",
                                message = list(objectId = self$getHideShowId()))
    },
    showHideShowButton = function(){
      staticLogger$info("Sending Js function to show ",self$getHideShowId())
      session$sendCustomMessage(type = "displayShowId",
                                message = list(objectId = self$getHideShowId()))
    }, 
    
    hideDivIdFilterObject = function(){
      staticLogger$info("Sending Js function to hide ",self$getDivIdFilterObject())
      session$sendCustomMessage(type = "displayHideId",
                                message = list(objectId = self$getDivIdFilterObject()))
    }, 
    
    showDivIdFilterObject = function(){
      staticLogger$info("Sending Js function to show ",self$getDivIdFilterObject())
      session$sendCustomMessage(type = "displayShowId",
                                message = list(objectId = self$getDivIdFilterObject()))
    },
    
    goToFirstChild = function(){
      staticLogger$info("\t \t moving ",self$getDivId(), " to go first")
      session$sendCustomMessage(type = "goFirstSibling",
                                message = list(objectId = self$getDivId()))
    },
    
    checkEnvironment = function(contextEnv){
      if (!is.environment(contextEnv)){
        stop("contextEnv must be an environment")
      }
      envObjects <- ls(contextEnv)
      print(envObjects)
      expectedObjects <- c("eventNumber")
      bool <-  expectedObjects %in% envObjects
      if (!all(bool)){
        stop("Missing ", expectedObjects[bool], " in context environment for ButtonFilter to work")
      }
      return(NULL)
    }
    
  )
)

# buttonFilter <- ButtonFilter$new(1, "predicateName","comment", "parentId","afterEnd")
