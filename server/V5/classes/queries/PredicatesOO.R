library(R6)
Predicates <- R6::R6Class(
  "Predicates",
  
  public = list(
    terminologyName = character(),
    predicatesDf = list(),
    lang = character(),
    
    initialize = function(terminologyName, lang){
      self$terminologyName = terminologyName
      private$checkLang(lang)
      self$lang <- lang
      private$setPredicatesDf()
      private$addEventPredicateFrequency()
    },
    
    getPredicateOfEvent = function(eventType){
      bool <- self$predicatesDf$frequency$eventType == as.character(eventType)
      predicates <- as.character(self$predicatesDf$frequency$predicate[bool])
      return(predicates)
    },
    
    getPredicateDescription = function(predicates){
      predicatesDf <- self$predicatesDf
      predicatesDf$comment$lang <- NULL
      predicatesDf$label$lang <- NULL
      description <- merge (predicatesDf$label, predicatesDf$comment, by="predicate")
      description <- merge (description, predicatesDf$category, by="predicate")
      description <- subset (description, predicate %in% predicates)
      return(description)
    },
    
    getPredicateDescriptionOfEvent = function(eventType){
      predicates <- self$getPredicateOfEvent(eventType)
      description <- self$getPredicateDescription(predicates)
      return(description)
    }
  ),
  private = list(
    langList = c("fr","en"),
    checkLang = function(lang){
      if (!lang %in% private$langList){
        stop("Authorized languages are : ", paste(private$langList, sep="\t"))
      }
    },
    
    categories = c("category","comment","label"),
    
    setPredicatesDf = function(){
      content <- GLOBALcon$getContent(self$terminologyName, 
                                      information = GLOBALcon$information$predicateDescription)
      
      predicates <- paste(content, collapse = "\n")
      predicates <- unlist(strsplit(predicates, split = "DATAFRAMESEPARATOR",fixed = T))
      predicates <- lapply(predicates, function(x){
        read.table(file=textConnection(x), sep="\t", header=T, comment.char = "",quote="")
      })
      categories <- private$categories
      for (category in categories){
        bool <- unlist(lapply(predicates, function(x,category){
          any(colnames(x) == category)
        }, category=category))
        names(predicates)[bool] <- category
      }
      ## lang : 
      predicates <- lapply(predicates, function(x){
        if (!any(colnames(x) == "lang")){
          return(x)
        }
        return(subset(x, lang == self$lang))
      })
      
      self$predicatesDf = predicates
    },
    
    addEventPredicateFrequency = function(){
      content <- GLOBALcon$getContent(self$terminologyName, 
                                      information = GLOBALcon$information$predicateFrequency)
      predicatesFrequency <- GLOBALcon$readContentStandard(content)
      ## keep only known predicates : 
      knownPredicates <- unique(unlist(lapply(self$predicatesDf, function(x){
        return(as.character(x$predicate))
      })))
      predicatesFrequency <- subset (predicatesFrequency, predicate %in% knownPredicates)
      listLength <- length(self$predicatesDf)
      self$predicatesDf[[listLength + 1]] <- predicatesFrequency
      names(self$predicatesDf)[[listLength + 1]] <- "frequency"
    }
  )
)
