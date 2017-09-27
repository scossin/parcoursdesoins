NumericValues <- R6::R6Class(
  "NumericValues",
  
  public = list(
    x = numeric(),
    min = numeric(),
    minFloor = numeric(),
    minChosen = numeric(),
    max = numeric(),
    maxCeiling = numeric(),
    maxChosen = numeric(),
    naNumber = numeric(),
    
    initialize = function(x){
      staticLogger$info("new NumericValues")
      self$setX(x)
    },
    
    setX = function(x){
      private$toNumeric(x)
      private$setMin()
      private$setMax()
    },
    
    setMinChosen = function(minChosen){
      if (!private$isCorrectChosenValue(minChosen)){
        staticLogger$info("minChosen incorrect !")
        return(NULL)
      }
      
      if (minChosen > self$maxChosen){
        staticLogger$info("minChosen incorrect !")
        return(NULL)
      }
      self$minChosen <- minChosen 
      return(NULL)
    },
    
    setMinMaxChosen = function(minChosen, maxChosen){
      if (!private$isCorrectChosenValue(maxChosen) || !private$isCorrectChosenValue(minChosen)){
        staticLogger$info("maxChosen or minChosen incorrect !")
        return(NULL)
      }
      if (maxChosen < minChosen){
        staticLogger$info("maxChosen or minChosen incorrect !")
        return(NULL)
      }
      self$minChosen <- minChosen 
      self$maxChosen <- maxChosen 
    },
    
    setMaxChosen = function(maxChosen){
      if (!private$isCorrectChosenValue(maxChosen)){
        staticLogger$info("maxChosen incorrect !")
        return(NULL)
      }
      
      if (maxChosen < self$minChosen){
        staticLogger$info("maxChosen incorrect !")
        return(NULL)
      }
      self$maxChosen <- maxChosen 
      return(NULL)
    }
    
  ),
  
  private = list(
    toNumeric = function(x){
      self$x <- as.numeric(x)
      bool <- is.na(self$x)
      if (all(bool)){
        # stop("vector x dataFrame contains only NA value")
      }
      self$naNumber <- sum(bool)
      staticLogger$info(self$naNumber, "NA value")
      return(NULL)
    },
    
    setMin = function(){
      self$min <- min(self$x, na.rm=T)
      self$minFloor <- floor(self$min)
      if (length(self$maxChosen) == 0 || (self$minChosen >= self$min && self$minChosen <= self$max)){
        self$minChosen <- self$minFloor 
      }
    },
    
    setMax = function(){
      self$max <- max(self$x, na.rm=T)
      self$maxCeiling <-ceiling(self$max)
      self$maxChosen <- self$maxCeiling 
      if (length(self$maxChosen) == 0 || (self$maxChosen >= self$min && self$maxChosen <= self$max)){
        self$maxChosen <- self$maxCeiling 
      }
      return(NULL)
    },
    
    isCorrectChosenValue = function(chosenValue){
      return(!is.na(as.numeric(chosenValue)))
    }
  )
)


