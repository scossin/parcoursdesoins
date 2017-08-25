GetFile <- R6Class(
  "GetFile",
  public = list(
    getFile = function(fileName){
        results <- httr::GET(url, body=list(filedata=upload_file(self$fileName)))
        return(results)
    }
  ),
  private = list(
    url = ""
    
  )
)