ButtonFilter <- R6::R6Class(
  "ButtonFilter",
  
  public = list(
    eventNumber = numeric(),
    predicateName = character(),
    predicateComment = character(),
    filterObject = NULL,
    isChecked = logical(),
    
    initialize = function(eventNumber, predicateName, predicateComment){
      self$eventNumber <- eventNumber
      self$predicateName <- predicateName
      self$predicateComment <- predicateComment
    },
    
    setFilterObject = function(filterObject){
      self$filterObject <- filterObject
    },
    
    
    getButtonId = function(){
      return(paste0("Button",self$eventNumber, self$predicateName))
    },
    
    getDivId = function(){
      buttonId <- self$getButtonId()
      return(paste0("div",buttonId))
    },
    
    getUI = function(){
      ## bold predicate
      htmlText <- paste0("<b>", self$predicateName, "</b> (", self$predicateComment, ")")
      # all in div to append filterObject inside
      div(id = self$getDivId(),
      materialSwitch(inputId = self$getButtonId(), 
                     label = HTML(htmlText), 
                     value = FALSE, ### not checked by default
                     status = "primary", right = T)) ### label to the right to align
    }
  ),
  
  private = list(
  )
)


