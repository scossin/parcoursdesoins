XMLSearchQuery <- R6Class("XMLSearchQuery",
  inherit = XMLquery,

    public = list(
    
    initialize=function(){
      super$initialize()
    },

    addEventNode = function(eventNumber, eventType, predicatesNodes = NULL){
      eventNode <- private$makeEventNode(eventNumber, eventType, predicatesNodes = NULL)
      eventName <- paste0("event",eventNumber)
      if (!is.null(self$listEventNodes[[eventName]])){
        warning("Replacing an exist event ")
      }
      self$listEventNodes[[eventName]] <- eventNode
    },
    
    addPredicateNode = function(eventNumber,predicateClass, predicateType, values, minValue, maxValue){
      predicateNode <- self$makePredicateNode(predicateClass, predicateType, values, minValue, maxValue)
      self$addPredicateNode2(eventNumber,predicateNode)
    },
    
    addPredicateNode2 = function(eventNumber, predicateNode){
      eventName <- paste0("event",eventNumber)
      ## add PredicateNode to eventNode :
      if (is.null(self$listEventNodes[[eventName]])){
        stop("Trying to add a predicateNode to a non existing event")
      }
      eventNode <- self$listEventNodes[[eventName]]
      self$listEventNodes[[eventName]] <- private$makeEventNode2(eventNode, list(predicateNode))
    },
    
    addLinkNode = function(eventNumber1, eventNumber2, 
                           predicate1, predicate2, operator, minValue, maxValue){
      linkNode <- private$makeLinkNode(eventNumber1, eventNumber2,
                                       predicate1, predicate2, operator, minValue, maxValue)
      oldList <- self$listLinkNodes
      if (length(oldList) == 0){
        self$listLinkNodes <- list(linkNode)
      } else {
        self$listLinkNodes <- list(oldList, linkNode)
      }
    },
    
    # @Override
    saveQuery = function(){
      ## add predicates to each eventNode
      eventLinksNode <- private$makeEventsLinksNode(self$listEventNodes, self$listLinkNodes,
                                                    self$listContextNode)
      super$setFileName()
      saveXML(eventLinksNode, file=self$fileName,doctype = self$docType)
    },
    
    makePredicateNode = function(predicateClass, predicateType, values, minValue, maxValue){
      ## private functions
      getFactorNodes_ <- function(predicateClassNode, values){
        if (is.null(values) || length(values) == 0){
          stop("values must be have length > 0")
        }
        values <- paste(values, collapse="\t")
        valueNode <- xmlNode("value",text=values)
        predicateClassNode <- addChildren(predicateClassNode,valueNode)
        return(predicateClassNode)
      }
      
      getNumericDateNodes_ <- function(predicateClassNode, minValue, maxValue){
        if (is.null(maxValue) || !length(maxValue) == 1){
          stop("maxValue must be have length 1")
        }
        if (is.null(minValue) || !length(minValue) == 1){
          stop("minValue must be have length 1")
        }
        
        maxValueNode <- xmlNode("maxValue",text=maxValue)
        minValueNode <- xmlNode("minValue",text=minValue)
        
        predicateClassNode <- addChildren(predicateClassNode,minValueNode)
        predicateClassNode <- addChildren(predicateClassNode,maxValueNode)
        return(predicateClassNode)
      }
      
      
      if (!predicateClass %in% c("factor","Date","numeric")){
        stop("incorrect predicateClass")
      }
      if (is.null(predicateType) || length(predicateType) != 1){
        stop("predicateType must have length 1")
      }
      
      predicateNode <- xmlNode("predicate")
      predicateClassNode <- xmlNode(predicateClass)
      predicateTypeNode <- xmlNode("predicateType", text=predicateType)
      
      
      predicateClassNode <- addChildren(predicateClassNode, predicateTypeNode)
      
      predicateClassNode <- switch(predicateClass,
                                   "factor"= getFactorNodes_(predicateClassNode, values),
                                   "Date"= getNumericDateNodes_(predicateClassNode, minValue, maxValue),
                                   "numeric"= getNumericDateNodes_(predicateClassNode, minValue, maxValue))
      
      
      predicateNode <- addChildren(predicateNode,predicateClassNode)
      class(predicateNode) <- c(class(predicateNode),"predicateNode")
      return(predicateNode)
    }
    
    
  ),
  
  private=list(
    name = "eventslinks",
    system = "eventslinks.dtd",
    
    makeContextNode = function(contextNode,values){
      super$makeContextNode(contextNode,values)
    },

    makeEventNode = function(eventNumber, eventType, predicatesNodes = NULL){
      if (!is.numeric(eventNumber) || length(eventNumber) != 1){
        stop("eventNumber must be numeric and length 1")
      }
      if (!is.character(eventType) || length(eventType) != 1){
        stop("eventType must be character and length 1")
      }
      
      eventTypeNode <- xmlNode("eventType",text=eventType)
      names(eventNumber) <- "number"
      eventNode <- xmlNode("event",attrs=eventNumber, text="")
      eventNode <- addChildren(eventNode, eventTypeNode)
      
      class(eventNode) <- c(class(eventNode),"eventNode")
      
      eventNode <- private$makeEventNode2(eventNode, predicatesNodes)
      return(eventNode)
    },
    
    ## can't overload methods in R...
    makeEventNode2 = function(eventNode,predicatesNodes= NULL){
      if (!inherits(eventNode,"eventNode")){
        stop("eventNode must be instance of eventNode classe")
      }
      
      if (!is.null(predicatesNodes)){
        for (predicateNode in predicatesNodes){
          if (!inherits(predicateNode,"predicateNode")){
            stop("predicatesNodes must be instances of predicateNode classe")
          }
          eventNode <- addChildren(eventNode, predicateNode)
        }
      }
      return(eventNode)
    },
    
    makeLinkNode = function(eventNumber1, eventNumber2, 
                             predicate1, predicate2, operator, minValue, maxValue){
      linkNode <- xmlNode("link")
      
      eventNumber1Node <- xmlNode("event1",text = eventNumber1)
      eventNumber2Node <- xmlNode("event2",text = eventNumber2)
      predicate1Node <- xmlNode("predicate1",text = predicate1)
      predicate2Node <- xmlNode("predicate2",text = predicate2)
      operatorNode <- xmlNode("operator",text = operator)
      minValueNode <- xmlNode("minValue",text = minValue)
      maxValueNode <- xmlNode("maxValue",text = maxValue)
      
      linkNode <- addChildren(linkNode, eventNumber1Node)
      linkNode <- addChildren(linkNode, eventNumber2Node)
      linkNode <- addChildren(linkNode, predicate1Node)
      linkNode <- addChildren(linkNode, predicate2Node)
      linkNode <- addChildren(linkNode, operatorNode)
      linkNode <- addChildren(linkNode, minValueNode)
      linkNode <- addChildren(linkNode, maxValueNode)
      
      class(linkNode) <- c(class(linkNode), "linkNode")
      return(linkNode)
    },
    
    makeEventsLinksNode = function(eventNodes, linkNodes = NULL, contextNodes = NULL){
      eventslinks <- xmlNode("eventslinks")
      for (eventNode in eventNodes){
        if (!inherits(eventNode,"eventNode")){
          stop("eventNodes must be instances of eventNode classes")
        }
        eventslinks <- addChildren(eventslinks, eventNode)
      }
      
      if (!is.null(linkNodes)){
        for (linkNode in linkNodes){
          if (!inherits(linkNode,"linkNode")){
            stop("linkNodes must be instances of linkNode classes")
          }
          eventslinks <- addChildren(eventslinks, linkNode)
        }
      }
      
      if (!is.null(contextNodes)){
        for (contextNode in contextNodes){
          if (!inherits(contextNode,"contextNode")){
            stop("linkNodes must be instances of contextNode classes")
          }
          eventslinks <- addChildren(eventslinks, contextNode)
        }
      }
      return(eventslinks)
    }
  )
)