Connection <- R6Class(
  "Connection",
  public = list(
    getQueryURL = function(){
      return(paste0(private$webserverURL, private$query))
    }
  ), 
  private = list(
    webserverURL = "http://localhost:9999/parcoursdesoins-0.0.1/",
    query = "HelloServlet"
  )
)