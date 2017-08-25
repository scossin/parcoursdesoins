XMLCountquery <- R6Class(
  "XMLquery",
  inherit = XMLquery,
  public = list(
    
    initialize = function(){
      super$initialize()
    },
    
    saveQuery = function(){
      super$setFileName()
      saveXML(self$listContextNode[[1]], file=self$fileName,doctype = self$docType)
    }
  ),
  
  private=list(
    name = "context",
    system = "count.dtd",
    
    makeContextNode = function(contextNode,values){
      super$makeContextNode(contextNode,values)
    }
  )
)
