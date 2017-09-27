XMLCountquery <- R6Class(
  "XMLquery",
  inherit = XMLquery,
  public = list(
    
    initialize = function(){
      super$initialize()
    },
    
    addEventNode = function(terminologyName, eventType, predicateName){
      predicateNode <- self$makePredicateNode(predicateName)
      eventNode <- self$makeEventNode(terminologyName, eventType, predicateNode)
      eventName <- paste0("event")
      self$listEventNodes[[eventName]] <- eventNode
      return(NULL)
    },
    
    makePredicateNode = function(predicateName){
      predicateTypeNode <- xmlNode("predicateType",text=predicateName)
      predicateNode <- xmlNode("predicate", text="")
      predicateNode <- addChildren(predicateNode, predicateTypeNode)
      class(predicateNode) <- c(class(predicateNode),"predicateNode")
      return(predicateNode)
    },
    
    makeEventNode = function(terminologyName, eventType, predicateNode){
      if (!is.character(terminologyName) || length(eventType) != 1){
        stop("terminologyName must be character and length 1")
      }
      
      if (!is.character(eventType) || length(eventType) != 1){
        stop("eventType must be character and length 1")
      }
      
      if (!inherits(predicateNode,"predicateNode")){
        stop("predicateNode must be of class predicateNode")
      }
      eventNode <- xmlNode("event",text="")
      eventTypeNode <- xmlNode("eventType",text=eventType)
      terminologyNameNode <- xmlNode("terminologyName",text=terminologyName)
      eventNode <- addChildren(eventNode, terminologyNameNode)
      eventNode <- addChildren(eventNode, eventTypeNode)
      eventNode <- addChildren(eventNode, predicateNode)
      class(eventNode) <- c(class(eventNode),"eventNode")
      return(eventNode)
    },
    
    makeEventContextNode = function(){
      if (length(self$listEventNodes) == 0){
        stop("listEventNodes not set")
      }
      if (length(self$listContextNode) == 0){
        stop("listContextNode not set")
      }
      eventNode <- self$listEventNodes[[1]]
      contextNode <- self$listContextNode[[1]]
      eventNode <- addChildren(eventNode, contextNode)
      return(eventNode)
    },
    
    saveQuery = function(){
      super$setFileName()
      xmlNode <- self$makeEventContextNode()
      saveXML(xmlNode, file=self$fileName,doctype = self$docType)
    }
  ),
  
  private=list(
    name = "event",
    system = "count.dtd",
    
    makeContextNode = function(contextNode,values){
      super$makeContextNode(contextNode,values)
    }
  )
)

### Test
# eventType : it does not matter...
# query <- XMLCountquery$new()
# query$addEventNode(terminologyName = "Event",eventType = "Event",predicateName = "hasType")
# context <- paste0("p",1:100)
# query$addContextNode(context)
# query$saveQuery()
# con <- Connection$new()
# con$sendQuery(query)
