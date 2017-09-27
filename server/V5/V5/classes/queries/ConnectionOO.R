Connection <- R6::R6Class(
  "Connection",
  public = list(
    terminology = list(
      Event = "Event",
      RPPS = "RPPS",
      FINESS = "Etablissement",
      Graph = "Graph"),
    information = list(
      predicateDescription = "predicateDescription",
      predicateFrequency = "predicateFrequency",
      hierarchy = "hierarchy"
    ),
    # filePredicatesDescription = "predicatesDescription.csv",
    # filePredicateFrequency = "predicateFrequency.csv",
    # fileEventHierarchy4Sunburst = "EventHierarchy4Sunburst.csv",
    
    getContent = function(terminologyName, information){
      url <- paste0(private$getWebServerURL(),private$GetFilePattern)
      response <- httr::GET(url, query=list(terminologyName=terminologyName,
                                            information = information))
      private$checkResponse(response)
      return(rawToChar(response$content))
    },
    
    readContentStandard = function(content){
      results <- read.table(file=textConnection(content), sep="\t",header = T,
                            comment.char ="",quote="")
    },
    
    sendQuery = function(XMLqueryInstance){
      staticLogger$info("ConnectionOO sending the query")
      if (!inherits(XMLqueryInstance, "XMLquery")){
        stop("provide a XMLquery instance to sendQuery")
      }
      XMLqueryInstance$saveQuery()
      url <- paste0(private$getWebServerURL(), private$XMLqueryPattern)
      fileName <- XMLqueryInstance$fileName
      response <- httr::POST(url, body=list(filedata=upload_file(fileName)))
      
      # staticLogger$info("query time to getAnswer : ",timeMesure["elapsed"])
      private$checkResponse(response)
      content <- rawToChar(response$content)
      results <- self$readContentStandard (content)
      return(results)
    }
  ), 
  private = list(
    XMLqueryPattern = "XMLQuery",
    GetFilePattern = "GetTerminologyDescriptionFile",
    
    checkResponse = function(response){
      if (response$status_code!=200){
        write(file="ERROR.html",x=rawToChar(response$content))
        stop("Request failed", rawToChar(response$content))
      }
    },
    getWebServerURL = function(){
      return(GLOBALurlserver)
    }
  )
)

