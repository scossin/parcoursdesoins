CategoricalValues <- R6::R6Class(
  "CategoricalValues",
  
  public = list(
    x = factor(),
    tableX = NULL,
    #chosenValues = NULL,
    tableChosenValues = NULL,
    naNumber = numeric(),
    
    initialize = function(x){
      staticLogger$info("new CategoricalValues")
      self$setX(x)
    },
    
    setX = function(x){
      private$toFactor(x)
      private$setTableX()
      #private$setTableChosenValues()
      return(NULL)
    },
    
    getChosenValues = function(){
      if (is.null(self$tableChosenValues)){
        return(NULL)
      } else {
        return(as.character(names(self$tableChosenValues)))
      }
    },
    
    setTableChosenValuesSelectize = function(chosenValues){
      if (length(chosenValues) == 0){
        self$tableChosenValues <- NULL
        return(NULL)
      }
      self$tableChosenValues <- subset (self$tableX, names(self$tableX) %in% chosenValues)
      bool <- self$tableChosenValues == 0 ## factor : same names but 0
      self$tableChosenValues <- subset (self$tableChosenValues, !bool)
      return(NULL)
    },
    
    setTableChosenValues = function(chosenValue){
      bool <- chosenValue %in% names(self$tableX)
      if (!bool){
        staticLogger$info(chosenValue, "not found in chosenValues : ")
        return(NULL)
      }
      selectedNames <- append(names(self$tableChosenValues),chosenValue)
      self$tableChosenValues <- subset (self$tableX, names(self$tableX) %in% selectedNames)
      bool <- self$tableChosenValues == 0 ## factor : same names but 0
      self$tableChosenValues <- subset (self$tableChosenValues, !bool)
      return(NULL)
    },
    
    getChoices = function(){
		diff <- setdiff(names(self$tableX), names(self$tableChosenValues))
		return(diff)
	},
    
    getValueWithPosition = function(clickNumber){
	   value <- names(self$tableX[clickNumber]);
	   return(value);
	}
    
  ),
  
  private = list(
    toFactor = function(x){
      self$x <- as.factor(x)
      bool <- is.na(self$x)
      self$naNumber <- sum(bool)
      staticLogger$info(self$naNumber, "NA value")
      return(NULL)
    },
    
    setTableX = function(){
      self$tableX <- sort(table(self$x),decreasing = T)
      return(NULL)
    }
    
    # setTableChosenValues = function(){
    #   self$tableChosenValues <- sort(table(self$chosenValues))
    #   return(NULL)
    # }
  )
)


# test <- sample(1:10,1000,replace = T)
# tab <- table(test)
# class(tab)
# barplot(table(test))
# test <- factor()
# tab <- table(test)
# plot(0)
# selection <- data.frame(sexe=c("H","F"), value=c(60,40))
# selection <- data.frame(sexe=character(), value=numeric())
# library(plotly)
# plotly::plot_ly(selection, labels = c("H","F"), values = selection$value, type = 'pie') %>%
#   layout(title = "test",
#          xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
#          yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
