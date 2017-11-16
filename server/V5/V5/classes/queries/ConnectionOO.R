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
    
    getTerminologies = function(){
      terminologies <- self$getContent(terminologyName = "Event",information = "terminologies")
      terminologies <- read.table(file=textConnection(terminologies), sep="\t",header =F,
                                  stringsAsFactors = F)
      
      
      # url <- paste0(private$getWebServerURL(),private$GetContextDescriptionURL)
      # response <- httr::GET(url, query=list(contextName = contextName))
      # private$checkResponse(response)
      # terminologies <- rawToChar(response$content)
      # terminologies <- read.table(file=textConnection(terminologies), sep="\t",header =F,
      #                             stringsAsFactors = F)
      return(terminologies)
    },
    
    getContextDescriptionTimeline = function(terminologyName, instanceName){
      url <- paste0(private$getWebServerURL(),private$GetContextDescriptionURL)
      response <- httr::GET(url, query=list(
        terminologyName = terminologyName,
        instanceName = instanceName))
      private$checkResponse(response)
      return(rawToChar(response$content))
    },
    
    getEventDescriptionTimeline = function(eventName){
      url <- paste0(private$getWebServerURL(),private$GetEventDescriptionURL)
      response <- httr::GET(url, query=list(eventName = eventName))
      private$checkResponse(response)
      return(rawToChar(response$content))
    },
    
    getShinyTreeHierarchy = function(eventName){
      url <- paste0(private$getWebServerURL(),private$GetEventDescriptionURL)
      response <- httr::GET(url, query=list(eventName = eventName))
      private$checkResponse(response)
      return(rawToChar(response$content))
    },
    
    
    getContextTimeline = function(contextName){
      url <- paste0(private$getWebServerURL(),private$GetTimelineURL)
      response <- httr::GET(url, query=list(contextName=contextName))
      private$checkResponse(response)
      return(rawToChar(response$content))
    },
    
    getContent = function(terminologyName, information){
      url <- paste0(private$getWebServerURL(),private$GetTerminologyURL)
      response <- httr::GET(url, query=list(terminologyName=terminologyName,
                                            information = information))
      private$checkResponse(response)
      return(rawToChar(response$content))
    },
    
    readContentStandard = function(content){
      results <- read.table(file=textConnection(content), sep="\t",header = T,
                            comment.char ="",quote="")
    },
    
    getShinyTreeList = function(dfShinyTreeQuery){
      fileName <- "/tmp/shinyTreeQuery.csv"
      write.table(dfShinyTreeQuery, fileName,sep = "\t",col.names = T, row.names = F,quote=F)
      url <- paste0(private$getWebServerURL(), private$GetShinyTreeHierarchy)
      response <- httr::POST(url, body=list(filedata=httr::upload_file(fileName)))
      private$checkResponse(response)
      content <- rawToChar(response$content)
      return(content)
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
    GetTerminologyURL = "GetTerminologyDescriptionFile",
    
    GetTimelineURL = "GetTimeline", 
    GetEventDescriptionURL = "GetEventDescriptionTimeline",
    GetContextDescriptionURL = "GetContextDescriptionTimeline",
    GetShinyTreeHierarchy = "GetShinyTreeHierarchy",
    GetTerminologies = "GetTerminologies",
    
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

