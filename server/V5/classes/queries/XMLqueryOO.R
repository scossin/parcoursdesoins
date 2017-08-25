XMLquery <- R6Class(
  "XMLquery",
  public = list(
    docType = XML::Doctype(),
    fileName = character(),
    listContextNode = list(),
    listEventNodes = list(),
    listLinkNodes = list(),
    
    initialize = function(){
      if (is.null(private$name)){
        stop("name not implemented")
      }
      if (is.null(private$system)){
        stop("system not implemented")
      }
      self$docType <- XML::Doctype(name = private$name, system = private$system)
    },
    
    addContextNode = function(contextVector){
      contextNode <- xmlNode("context")
      self$listContextNode <- list(private$makeContextNode(contextNode, contextVector))
    },
    
    saveQuery = function(){
      stop("saveQuery not implemented")
    },
    
    setFileName = function(){
      randomNumber <- round(runif(1, 0, 10^12),0)
      self$fileName <- paste0("/tmp/XMLquery",private$system, randomNumber, ".xml")
    },
    
    makeContextNode = function(contextNode,values){
      ## private functions
      getValuesNodes_ <- function(contextNode, values){
        if (is.null(values) || length(values) == 0){
          stop("values must be have length > 0")
        }
        values <- paste(values, collapse="\t")
        valueNode <- xmlNode("value",text=values)
        contextNode <- addChildren(contextNode,valueNode)
        return(contextNode)
      }
      contextNode <- getValuesNodes_(contextNode,values)
      class(contextNode) <- c(class(contextNode),"contextNode")
      return(contextNode)
    }
    
  ),
  
  private=list(
    name = NULL,
    system = NULL
  )
)
