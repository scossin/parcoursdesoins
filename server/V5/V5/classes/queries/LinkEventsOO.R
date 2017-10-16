LinkEvents <- R6::R6Class(
  "LinkEvents",
  public = list(
    
    xmlSearchQuery = NULL,
    eventNumber1 = numeric(),
    eventNumber2 = numeric(),
    predicate1 = character(),
    predicate2 = character(),
    operator = character(),
    minValue = numeric(),
    maxValue = numeric(),
    
    initialize = function(eventNumber1, eventNumber2, predicate1, predicate2, operator, minValue, maxValue){
      staticLogger$info("\t new LinkEvents")
      self$eventNumber1 <- eventNumber1
      self$eventNumber2 <- eventNumber2
      self$predicate1 = predicate1
      self$predicate2 = predicate2
      self$operator = operator
      self$minValue = minValue
      self$maxValue = maxValue
    },
    
    addLinkNode = function(query){
      query$addLinkNode(eventNumber1 = self$eventNumber1,
                        eventNumber2 = self$eventNumber2,
                        predicate1 = self$predicate1,
                        predicate2 = self$predicate2,
                        operator = "diff", ## CAUTION : change diff with operator value
                        minValue = self$minValue,
                        maxValue = self$maxValue)
      return(query)
    },
    
    getDescription = function(){
      text <- paste0(self$event1, " is linked to ", self$event2)
      return(text)
    }
  ),
  
  private = list(
  )
)