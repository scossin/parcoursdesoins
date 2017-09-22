STATICterminologyInstances <- R6::R6Class(
  "STATICterminologyInstances",
  
  public = list(
    terminology = list(
      "Event" = list(terminologyName = "Event", mainClassName="Event"),
      "RPPS" = list(terminologyName = "RPPS", mainClassName="RPPS"),
      "Etablissement" = list(terminologyName = "Etablissement", mainClassName="Etablissement"),
      "Graph" = list(terminologyName = "Graph", mainClassName="Graph")),
    
    
    terminologyInstances = list(),
    
    initialize = function(){
      for (ter in self$terminology){
        terminologyName <- ter$terminologyName
        mainClassName <- ter$mainClassName
        terminology <- Terminology$new(terminologyName = terminologyName,
                                       mainClassName = mainClassName, 
                                       lang = GLOBALlang)
        self$addTerminology(terminology,terminologyName)
      }

    },
  
  addTerminology = function(terminology,terminologyName){
    lengthList <- length(self$terminologyInstances)
    namesList <- names(self$terminologyInstances)
    self$terminologyInstances[[lengthList + 1]] <- terminology
    namesList <- append(namesList, terminologyName)
    names(self$terminologyInstances) <- namesList
  },
  
  getTerminology = function(terminologyName){
    private$isKnownTerminology(terminologyName)
    return(self$terminologyInstances[[terminologyName]])
  }
  
  ),
  private = list(
    isKnownTerminology = function(terminologyName){
      bool <- terminologyName %in% names(self$terminologyInstances)
      if (!bool){
        stop("unfound terminology : ", terminologyName)
      }
      return(NULL)
    }
  )
)