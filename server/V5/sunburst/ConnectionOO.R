Connection <- R6Class(
  "Connection",
  public = list(
    getQueryURL = function(){
      return(paste0(private$webserverURL, private$urlPattern))
    }
  ), 
  private = list(
    webserverURL = "http://localhost:8080/parcoursdesoins-0.0.1/",
    urlPattern = "XMLQuery"
  )
)