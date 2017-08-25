XMLDescribeQuery <- R6Class("XMLDescribeQuery",
  inherit = XMLquery,
  public = list(
    docType = XML::Doctype(),
    fileName = character(),

    initialize=function(){
      super$initialize()
      self$listEventNodes <- list(xmlNode("event"))
    },
    
    addEventTypeNode = function(eventType){
      eventNode <- xmlNode("eventType", text = eventType)
      self$listEventNodes <- list(addChildren(self$listEventNodes[[1]],eventNode))
    },
    
    addPredicateTypeNode = function(predicateTypes){
      predicateNode <- xmlNode("predicate")
      predicateTypes <- paste(predicateTypes,collapse="\t") ## only one normally 
      predicateTypeNode <- xmlNode("predicateType", text=predicateTypes)
      predicateNode <- addChildren(predicateNode, predicateTypeNode)
      self$listEventNodes <- list(addChildren(self$listEventNodes[[1]],predicateNode))
    },
    
    addEventInstances = function(eventInstances){
      eventInstances <- paste0(eventInstances, collapse = "\t")
      valueNode <- xmlNode("value", text = eventInstances)
      self$listEventNodes <- list(addChildren(self$listEventNodes[[1]],valueNode))
    },
    
    # @Override
    saveQuery = function(){
      ## add predicates to each eventNode
      eventLinksNode <- private$makeEventsLinksNode(self$listEventNodes,
                                                    self$listContextNode)
      super$setFileName()
      saveXML(eventLinksNode, file=self$fileName,doctype = self$docType)
    }
    
  ),
  
  private=list(
    name = "eventslinks",
    system = "describe.dtd",
    makeContextNode = function(contextNode,values){
      super$makeContextNode(contextNode,values)
    },
    
    makeEventsLinksNode = function(listEventNodes, listContextNode){
      eventslinks <- xmlNode("eventslinks")
      eventslinks <- addChildren(eventslinks, listEventNodes[[1]])
      eventslinks <- addChildren(eventslinks, listContextNode[[1]])
      return(eventslinks)
    }
  )
)
