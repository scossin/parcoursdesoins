uiObject <- R6::R6Class(
  "uiObject",
  
  public = list(
    parentId = character(),
    where = character(),

    initialize = function(parentId, where){
      self$parentId <- parentId
      self$where = where
    },
    
    insertUI = function(){
      stop("Please, provide a method to insert the UI in the DOM")
    },
    
    removeUI = function(){
      stop("Please, provide a method to remove the UI in the DOM")
      # session$sendCustomMessage(type = "removeId",
      #                           message = list(objectId = self$getObjectId()))
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