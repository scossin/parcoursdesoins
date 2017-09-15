SpatialPointValues <- R6::R6Class(
  "SpatialPointValues",
  
  public = list(
    initialize = function(dataFrame){
      private$checkDataFrame(dataFrame)
    }
  ),
  
  private = list(
    checkDataFrame = function(dataFrame){
      bool <- c("long","lat","N","label") %in% colnames(dataFrame)
      if (!all(bool)){
        stop("incorrect columns in dataFrame")
      }
    }
  )
)