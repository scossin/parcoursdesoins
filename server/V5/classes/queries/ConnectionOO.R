Connection <- R6Class(
  "Connection",
  public = list(
    filePredicatesDescription = "predicatesDescription.csv",
    filePredicateFrequency = "predicateFrequency.csv",
    fileEventHierarchy4Sunburst = "EventHierarchy4Sunburst.csv",
    
    getContent = function(fileName){
      fileNames=c(self$filePredicatesDescription,self$filePredicateFrequency,self$fileEventHierarchy4Sunburst)
      bool <- fileName %in% fileNames
      if (!any(bool)){
        stop("choose fileName among ",fileNames)
      }
      url <- paste0(private$webserverURL,private$GetFilePattern)
      response <- httr::GET(url, query=list(fileName=fileName))
      private$checkResponse(response)
      return(rawToChar(response$content))
    },
    
    readContentStandard = function(content){
      results <- read.table(file=textConnection(content), sep="\t",header = T,
                            comment.char ="",quote="")
    },
    
    sendQuery = function(XMLqueryInstance){
      if (!inherits(XMLqueryInstance, "XMLquery")){
        stop("provide a XMLquery instance to sendQuery")
      }
      XMLqueryInstance$saveQuery()
      url <- paste0(private$webserverURL, private$XMLqueryPattern)
      fileName <- XMLqueryInstance$fileName
      response <- httr::POST(url, body=list(filedata=upload_file(fileName)))
      private$checkResponse(response)
      content <- rawToChar(response$content)
      results <- self$readContentStandard (content)
      return(results)
    }
  ), 
  private = list(
    webserverURL = "http://localhost:8080/parcoursdesoins-0.0.1/",
    XMLqueryPattern = "XMLQuery",
    GetFilePattern = "GetFile",
    
    checkResponse = function(response){
      if (response$status_code!=200){
        write(file="ERROR.html",x=rawToChar(response$content))
        stop("Request failed", rawToChar(response$content))
      }
    }
  )
)