ListEventsTabpanel <- R6::R6Class(
  "ListEventsTabpanel",
  
  public = list(
    listEventTabpanel = list(),
    
    updateContext = function(context){
      for (eventTabPanel in self$listEventTabpanel){
        eventTabPanel$updateContext(context)
      }
    },
    
    addEventTabpanel = function(eventTabpanel){
      bool <- inherits(eventTabpanel, "EventTabpanel")
      if (!bool){
        stop("eventTabpanel must be instance of EventTabpanel")
      }
      listLength <- length(self$listEventTabpanel)
      self$listEventTabpanel[[listLength+1]] <- eventTabpanel
      names(self$listEventTabpanel)[listLength+1] <- eventTabpanel$getLiText()
    },
    
    emptyTabpanel = function(){
      for (eventTabpanel in self$listEventTabpanel){
        eventTabpanel$destroy()
      }
      self$listEventTabpanel <- list()
    },
    
    removeEventTabpanel = function(liText){
      for (eventTabpanel in self$listEventTabpanel){
        if (eventTabpanel$getLiText() == liText){
          eventTabpanel$destroy()
          self$listEventTabpanel[[liText]] <- NULL
          return()
        }
      }
    },
    
    getAllLiText = function(){
      liTexts <- NULL
      for (eventTabpanel in self$listEventTabpanel){
        liTexts <- append(liTexts,eventTabpanel$getLiText())
      }
      return(liTexts)
    }
  ),
  
  private = list(
    
  )
)