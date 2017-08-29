ButtonFilter <- R6::R6Class(
   inherit = uiObject,
  "ButtonFilter",
  
  public = list(
    eventNumber = numeric(),
    predicateName = character(),
    predicateComment = character(),
    predicateLabel = character(),
    filterObject = NULL,
    isChecked = logical(),
    
    initialize = function(eventNumber, predicateName, predicateLabel, predicateComment, parentId, where){
      super$initialize(parentId = parentId, where = where)
      self$eventNumber <- eventNumber
      self$predicateName <- predicateName
      self$predicateComment <- predicateComment
      self$predicateLabel <- predicateLabel
    },
    
    setFilterObject = function(filterObject){
      self$filterObject <- filterObject
    },
    
    
    getObjectId = function(){
      return(paste0("Button",self$eventNumber, self$predicateName))
    },
    
    getDivId = function(){
      buttonId <- self$getObjectId()
      return(paste0("div",buttonId))
    },
    
    makeUI = function(){
      ## bold predicate
      htmlText <- paste0("<b>", self$predicateLabel, "</b> (", self$predicateComment, ")")
      # all in div to append filterObject inside
      ui <- div(id = self$getDivId(),
                    shinyWidgets::materialSwitch(inputId = self$getObjectId(), 
                                      label = HTML(htmlText), 
                                      value = FALSE, ### not checked by default
                                      status = "primary", right = T)) ### label to the right to align
      insertUI(selector = private$getJquerySelector(self$parentId),
               where = self$where,
               ui = ui)
    }
  ),
  
  private = list(
  )
)

# buttonFilter <- ButtonFilter$new(1, "predicateName","comment", "parentId","afterEnd")
