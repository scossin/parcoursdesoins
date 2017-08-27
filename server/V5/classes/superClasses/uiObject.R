uiObject <- R6::R6Class(
  "uiObject",
  
  public = list(
    # parentId = character(),
    # 
    # initialize = function(parentId){
    #   self$parentId <- parentId
    # },
    
    insertUI = function(){
      stop("Please, provide a method to insert the UI in the DOM")
    },
    
    removeUI = function(){
      ## removeId.js => document.getElementById(objectId).remove()
      session$sendCustomMessage(type = "removeId", 
                                message = list(objectId = self$getObjectId()))
    }, 
    
    getObjectId = function(){
      stop("Please, provide a method to get the id of the object in the DOM")
    }
  ),
  
  private = list(
    getJquerySelector = function(elementId){
      return(paste0("#", elementId))
    }
  )
)