Terminology <- R6::R6Class(
  "Terminology",
  
  public = list(
    terminologyName = character(),
    mainClassName = character(),
    
    predicateDescription = data.frame(),
    predicateEvent = data.frame(),
    lang = character(),
    
    initialize = function(terminologyName, mainClassName, lang){
      self$terminologyName = terminologyName
      self$mainClassName <- mainClassName
      private$setLang(lang)
      private$setPredicateDescription()
      private$setPredicateEvent()
    },
    
    getPredicatesOfEvent = function(eventType){
      bool <- self$predicateEvent$eventType == as.character(eventType)
      if (!any(bool)){
        stop(eventType, " not found in ", self$terminologyName)
      }
      predicates <- as.character(self$predicateEvent$predicate[bool])
      return(predicates)
    },
    
    getPredicateDescription = function(predicateNames){
      bool <- predicateNames %in% self$predicateDescription$predicate
      if (!all(bool)){
        stop(predicateNames[!bool], "unfound in ", self$terminologyName)
      }
      description <- subset (self$predicateDescription, predicate %in% predicateNames)
      return(description)
    },
    
    getPredicate = function (predicateLabel){
      bool <-  predicateLabel %in%  self$predicateDescription$label
      if (!bool){
        stop(predicateLabel, " unfound in ", self$terminologyName)
      }
      bool <- self$predicateDescription$label == predicateLabel
      description <- subset (self$predicateDescription, bool)
      return(as.character(description$predicate))
    },
    
    getLabels = function(predicates){
      labels <- NULL
      for (predicate in predicates){
        labels <- append(labels, self$getLabel(predicate))
      }
      return(labels)
    }, 
    
    getLabel = function(predicate){
      bool <- predicate %in% self$predicateDescription$predicate
      if (!bool){
        stop(predicate, "unfound in ", self$terminologyName)
      }
      bool <- self$predicateDescription$predicate %in% predicate
      description <- subset (self$predicateDescription, bool)
      return(as.character(description$label))
    },
    
    getPredicateDescriptionOfEvent = function(eventType){
      predicates <- self$getPredicatesOfEvent(eventType)
      description <- self$getPredicateDescription(predicates)
      return(description)
    }
  ),
  
  private = list(
    langList = c("fr","en"),
    
    setLang = function(lang){
      if (!lang %in% private$langList){
        stop("Authorized languages are : ", paste(private$langList, sep="\t"))
      }
      self$lang <- lang
    },
    
    categories = c("category","comment","label"),
    
    setPredicateDescription = function(){
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
      predicates$comment$lang <- NULL
      predicateDf <- predicates$comment
      predicateDf <- merge (predicateDf, predicates$label, by="predicate")
      predicateDf <- merge (predicateDf, predicates$category, by="predicate")
      bool <- colnames(predicateDf) %in% c("predicate","comment","lang","label","category","value")
      if (!all(bool)){
        stop("unfound columns in predicateDf", colnames(predicateDf))
      }
      self$predicateDescription <- predicateDf
      return(NULL)
    },
    
    setPredicateEvent = function(){
      content <- GLOBALcon$getContent(self$terminologyName, 
                                      information = GLOBALcon$information$predicateFrequency)
      predicatesFrequency <- GLOBALcon$readContentStandard(content)
      # keep only known predicates :
      knownPredicates <- unique(as.character(self$predicateDescription$predicate))
      bool <- !predicatesFrequency$predicate %in% knownPredicates
      if (any(bool)){
        undescribedPredicate <- unique(predicatesFrequency$predicate[bool])
        staticLogger$info("undescribded ", undescribedPredicate, "in ", self$terminologyName, "ontology")
        predicatesFrequency <- subset (predicatesFrequency, !bool)
      }
      bool <- colnames(predicatesFrequency) %in% c("predicate","eventType","frequency")
      if (!all(bool)){
        stop("unfound columns in predicatesFrequency", colnames(predicatesFrequency))
      }
      self$predicateEvent <- predicatesFrequency
    }
  )
)
