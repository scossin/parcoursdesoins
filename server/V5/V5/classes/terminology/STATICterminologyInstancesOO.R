STATICterminologyInstances <- R6::R6Class(
  "STATICterminologyInstances",
  
  public = list(
    terminology = list(
      "Event" = list(terminologyName = "Event", mainClassName="Event"),
      # "RPPS" = list(terminologyName = "RPPS", mainClassName="RPPS"),
      # "Etablissement" = list(terminologyName = "Etablissement", mainClassName="Etablissement"),
      "Graph" = list(terminologyName = "Graph", mainClassName="Graph")),
      # "CIM10" = list(terminologyName = "CIM10", mainClassName="ICD-10-FR")),
      
    terminologyInstances = list(),
    
    initialize = function(){
      terminologies <- GLOBALcon$getTerminologies()
      for (i in 1:nrow(terminologies)){
        terminologyName <- terminologies[i,1]
        mainClassName <- terminologies[i,2]
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
  
  getTerminologyByClassName = function(mainClassName){
    terminologyName <- private$getTerminologyName(mainClassName = mainClassName)
    return(self$getTerminology(terminologyName))
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
    },
    
    getTerminologyName = function(mainClassName){
      for (termino in self$terminologyInstances){
        if (termino$mainClassName == mainClassName){
          return(termino$terminologyName)
        }
      }
      stop("Unfound mainClassName : ", mainClassName)
    }
  )
)