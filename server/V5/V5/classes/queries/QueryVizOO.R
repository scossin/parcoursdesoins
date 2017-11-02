QueryViz <- R6::R6Class(
  classname = "QueryViz",
  
  public = list(
    dfEventNode = NULL, 
    dfObjectNodes = NULL, 
    dfEdges = NULL, 
    dfValueNodes = NULL,
    
    initialize = function(xmlSearchQuery){
      self$setNodesEdges(xmlSearchQuery)
      self$setLinkNodes(xmlSearchQuery)
    },
    
    getTextValue = function(element, valueElement){
      valueNode <- XML::xmlElementsByTagName(el=element, 
                                             name=valueElement)
      value <- XML::xmlValue(valueNode[[1]])
      return(value)
    },
    
    setLinkNodes = function(xmlSearchQuery){
      for (linkNode in xmlSearchQuery$listLinkNodes){
        idEvent <- self$getTextValue(linkNode, "event1")
        predicateType <-  self$getTextValue(linkNode, "predicate1")
        predicateId1 <- paste0 (idEvent, predicateType)
        self$addObjectNode(predicateId1)
        self$addEdge(from = idEvent,
                     to = predicateId1, 
                     label = predicateType)
        from <- predicateId1
        idEvent <- self$getTextValue(linkNode, "event2")
        predicateType <-  self$getTextValue(linkNode, "predicate2")
        predicateId2 <- paste0 (idEvent, predicateType)
        self$addObjectNode(predicateId2)
        self$addEdge(from = idEvent,
                     to = predicateId2, 
                     label = predicateType)
        to <- predicateId2
        operator <- self$getTextValue(linkNode, "operator")
        minValue <- self$getTextValue(linkNode, "minValue")
        maxValue <- self$getTextValue(linkNode, "maxValue")
        label <- paste0 (operator, "(",minValue, " - ", maxValue,")")
        self$addEdge(from = from, 
                     to = to,
                     label = label)
      }
    },
    
    setNodesEdges = function(xmlSearchQuery){
      for (eventNode in xmlSearchQuery$listEventNodes){
        eventTypeNodes <- XML::xmlElementsByTagName(el=eventNode, name="eventType")
        eventTypeNode <- eventTypeNodes[[1]]
        eventType <- XML::xmlValue(eventTypeNode)
        eventId <- XML::xmlGetAttr(node = eventNode, name = "number")
        self$addEventNode(id = eventId,
                          label = eventType)
        ## predicates of eventNode
        predicateNodes <- XML::xmlElementsByTagName(el=eventNode, name="predicate")
        for (predicateNode in predicateNodes){
          predicate <- names(XML::xmlChildren(predicateNode))
          print(predicate)
          if (predicate == "numeric" || predicate == "date"){
            self$numericPredicate(eventId, predicateNode)
          } else if (predicate == "factor"){
            self$factorPredicate(eventId, predicateNode)
          } else {
            stop("unknown predicate : ", predicate)
          }
        }
      }
    },
    
    factorPredicate = function(eventId, predicateNode){
      predicateType <- self$getPredicateType(predicateNode)
      predicateId <- paste0(eventId, predicateType)
      self$addObjectNode(predicateId)
      self$addEdge(from = eventId, 
                   to = predicateId,
                   label = predicateType)
      values <-  XML::xmlElementsByTagName(el=predicateNode[[1]], 
                                           name="value")
      values <- XML::xmlValue(values[[1]])
      values <- unlist(strsplit(values,split="\t"))
      iter = 0
      for (value in values){
        print(value)
        iter <- iter + 1 
        if (iter == 10){
          break
        }
        self$addValue(
          predicateId = predicateId, 
          predicateNode = predicateNode, 
          valueElement=NULL, 
          value = value
        )
      }
    },
    
    getPredicateType = function(predicateNode){
      predicateTypeNode <- XML::xmlElementsByTagName(el=predicateNode[[1]], 
                                                     name="predicateType")
      predicateType <- XML::xmlValue(predicateTypeNode[[1]])
    },
    
    numericPredicate = function(eventId, predicateNode){
      predicateType <- self$getPredicateType(predicateNode)
      predicateId <- paste0(eventId, predicateType)
      self$addObjectNode(predicateId)
      
      self$addEdge(from = eventId, 
                   to = predicateId,
                   label = predicateType)

      ### minValue : 
      self$addValue(predicateId = predicateId, 
                    predicateNod = predicateNode, 
                    valueElement = "minValue")
      ### maxValue : 
      self$addValue(predicateId, predicateNode, "maxValue")
    },
    
    addValue = function(predicateId, predicateNode, valueElement=NULL, value = NULL){
      if (!is.null(valueElement)){
        valueNode <- XML::xmlElementsByTagName(el=predicateNode[[1]], 
                                               name=valueElement)
        value <- XML::xmlValue(valueNode[[1]])
      }
      valueId <-  paste0(predicateId, value)
      self$addValueNode(valueId,value)
      if (is.null(valueElement)){
        valueElement <- ""
      }
      self$addEdge(from = predicateId, 
                   to = valueId,
                   label = valueElement)
    },
    
    addObjectNode = function(predicateId){
      df <- data.frame(id = predicateId, 
                       label="",
                       shape = private$shapeObject,
                       color="blue")
      self$dfObjectNodes <- rbind(self$dfObjectNodes, df)
    },
    
    addValueNode = function(valueId, value){
      df <- data.frame(id = valueId, 
                       label = value,
                       shape = private$shapeValue,
                       color=NA)
      self$dfValueNodes <- rbind(self$dfValueNodes, df)
    },
    
    addEdge = function(from, to, label){
      dfEdge <- data.frame(from = from, 
                           to = to,
                           label = label,
                           arrows = "to")
      self$dfEdges <- rbind(self$dfEdges, dfEdge)
    },
    
    
    getOutput = function(){
      vis <- renderVisNetwork({
        myNodes <- rbind (self$dfEventNode, 
                          self$dfObjectNodes, 
                          self$dfValueNodes)
        myNodes <- unique(myNodes)
        myEdges <- self$dfEdges
        myEdges <- unique(myEdges)
        visNetwork(myNodes, myEdges)  %>% visOptions(highlightNearest = TRUE) %>%
          visInteraction(navigationButtons = TRUE)
      })
      return(vis)
    },
    
    addEventNode = function(id,label){
      node <- data.frame(id = id,
                         label = label,
                         shape = private$shapeEventNode,
                         color="red")
      self$dfEventNode <- rbind(self$dfEventNode, 
                                node)
    }
  ),
  
  private = list(
    shapeEventNode = "square",
    shapeObject = "triangle",
    shapeValue = "text"
  )
)