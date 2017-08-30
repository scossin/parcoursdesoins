STATICfilterCreator <- R6::R6Class(
  "STATICfilterCreator",
  
  public = list(
    
    createFilterObject = function(contextEnv, predicateName, parentId, where){
      filterType <- GLOBALpredicatesDescription$getPredicateDescription(predicateName)$category
      filterType <- as.character(filterType)
      bool <- filterType %in% private$availableFilters
      if (!bool){
        stop("filterType of ",predicateName,"(",filterType,") not in : ",
             paste0(private$availableFilters, collapse = " "))
      }
      if (filterType == "NUMERIC"){
        dataFrame <- staticMakeQueries$getContextEventsPredicate(contextEnv = contextEnv,
                                                                 predicateName = predicateName)
        filterNumeric <- FilterNumeric$new(contextEnv, predicateName, dataFrame,
                                           parentId, where)
        return(filterNumeric)
      }
      return(NULL)
    },
    
    initialize = function(){
      cat("initializing STATICfilterCreator \n")
    }
  ),
  
  private = list(
    availableFilters = c("NUMERIC","DATE","HIERARCHICAL","FACTOR")
  )
)