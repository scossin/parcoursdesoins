XMLDescribeTerminologyQuery <- R6Class("XMLDescribeTerminologyQuery",
  inherit = XMLquery,
  public = list(
    docType = XML::Doctype(),
    fileName = character(),

    initialize=function(){
      super$initialize()
      self$listEventNodes <- list(xmlNode("event"))
    },
    
    addTerminologyName = function(terminologyName){
      eventNode <- xmlNode("terminologyName", text = terminologyName)
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
    system = "describeTerminology.dtd",
    makeContextNode = function(contextNode,values){
      super$makeContextNode(contextNode,values)
    },
    
    makeEventsLinksNode = function(listEventNodes, listContextNode){
      eventslinks <- xmlNode("eventslinks")
      eventslinks <- addChildren(eventslinks, listEventNodes[[1]])
      #eventslinks <- addChildren(eventslinks, listContextNode[[1]])
      return(eventslinks)
    }
  )
)

# query <- XMLDescribeTerminologyQuery$new()
# query$addTerminologyName("RPPS")
# query$addPredicateTypeNode("Nom")
# query$addEventInstances("RPPS810100499945")
# 
# query$saveQuery()
