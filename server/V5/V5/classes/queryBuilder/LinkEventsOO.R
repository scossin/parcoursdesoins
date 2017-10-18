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
    linkNumber = numeric(),
    
    initialize = function(eventNumber1, 
                          eventNumber2, 
                          predicate1, 
                          predicate2, 
                          operator, 
                          minValue, 
                          maxValue,
                          linkNumber){
      staticLogger$info("\t new LinkEvents")
      self$eventNumber1 <- eventNumber1
      self$eventNumber2 <- eventNumber2
      self$predicate1 = predicate1
      self$predicate2 = predicate2
      self$operator = operator
      self$minValue = minValue
      self$maxValue = maxValue
      self$linkNumber <- linkNumber
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
    
    getButtonRemoveId = function(){
      return(paste0("buttonRemoveLink",self$linkNumber))
    },
    
    addButtonRemoveObserver = function(){
      observeEvent(input[[self$getButtonRemoveId()]],{
        staticLogger$user("removelink", self$linkNumber)
        GLOBALqueryBuilder$linkDescription$removeLink(self$linkNumber) ## ask to remove itself
      },once = T)
    },
    
    getDescription = function(){
      event1 <- paste0("event",self$eventNumber1)
      event2 <- paste0("event",self$eventNumber2)
      text <- paste0(event1, "<---->", event2, " ", 
                     self$operator, "(",self$predicate1, "----",self$predicate2, ")"       ,
                     GLOBALbetween, ": ", self$minValue, " ", GLOBALand, " ", self$maxValue)
      linkNumberText <- paste0("link",self$linkNumber)
      liLink <- shiny::tags$li(
        div(linkNumberText,                  
            shiny::actionButton(inputId = self$getButtonRemoveId(),
                                                                 label = "",
                                                                 icon = icon("remove"))
                     ),
        shiny::tags$p(text))
      return(liLink)
    }
  ),
  
  private = list(
  )
)