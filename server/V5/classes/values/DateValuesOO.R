DateValues <- R6::R6Class(
  "DateValues",
  
  public = list(
    naNumber = numeric(),
    xtsObject = NULL, 
    xtsObjectSelection = NULL,
    
    initialize = function(x){
      staticLogger$info("new DateValues")
      self$setXTS(x)
    },
    
    setXTS = function(x){
      private$toXTS(x)
      self$xtsObjectSelection <- self$xtsObject
      return(NULL)
    },
    
    setXTSobjectSelection = function(minDateChosen = NULL, maxDateChosen = NULL){
      staticLogger$info("setXTSobjectSelection called")
      if (is.null(minDateChosen) & is.null(maxDateChosen)){
        return(NULL)
      }
      self$xtsObjectSelection <- self$xtsObject[paste0(minDateChosen, "/",maxDateChosen)]
    },
    
    getMinDate = function(){
      minDate <- min(self$xtsObjectSelection$date)
      return(minDate)
    },
    
    getMaxDate = function(){
      maxDate <- max(self$xtsObjectSelection$date)
      return(maxDate)
    },
    
    valueToDate = function(x){
      ## date format : 
      bool <- is.na(x)
      self$naNumber <- sum(bool)
      staticLogger$info(self$naNumber, "NA value")
      x <- x[!bool] ## remove NA
      x <- gsub("T|Z"," ",x )
      x <- gsub("\\.[0-9]+ $","",x)
      return(x)
    }
  ),
  
  private = list(
    toXTS = function(x){
      x <- self$valueToDate(x)
      tab <- table(x)
      tab <- data.frame(date=as.Date(names(tab)), frequency = as.numeric(tab))
      self$xtsObject <- xts::xts(x = tab, order.by = tab$date, frequency = tab$frequency)
      return(NULL)
    }
  )
)