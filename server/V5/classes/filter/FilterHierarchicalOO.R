FilterHierarchical <- R6::R6Class(
  "FilterHierarchical",
  inherit = Filter,
  
  public = list(
    terminology = NULL,
    hierarchicalData = data.frame(),
    choice = character(),
    changePlotObserver = NULL,
    treeObserver = NULL,
    sunburstObserver = NULL,
    
    initialize = function(contextEnv, terminology, predicateName, dataFrame, parentId, where){
      super$initialize(contextEnv, predicateName, dataFrame, parentId, where)
      staticLogger$info("initiliazing a new HierarchicalSunburst")
      self$terminology <- terminology
      self$setHierarchicalData()
      self$insertUIandPlot()
      self$addChangePlotObserver()
      self$addTreeObserver()
      self$addSunburstObserver()
    }, 
    
    getEventCount = function(){
      tab <- table(self$dataFrame$value)
      eventCount <- data.frame(className = names(tab), count = as.numeric(tab))
      return(eventCount)
    },
    
    getDescription = function(){
      namesChosen <- self$getEventChoice()
      lengthChosen <- length(namesChosen)
      if (lengthChosen > 10){
        namesChosen <- namesChosen[1:10]
        namesChosen <- append(namesChosen, "...")
      }
      if (lengthChosen == 0){
        namesChosen <- ""
      } else {
        namesChosen <- paste(namesChosen, collapse = " ; ")
      }
      description <- paste0(self$predicateName,"\t ", lengthChosen, " values chosen (",
                            namesChosen, ")")
      return(description)
    },
    
    updateDataFrame = function(){
      staticLogger$info("updateDataFrame of FilterHierarchical")
      eventType <- self$contextEnv$instanceSelection$className
      terminologyName <- self$contextEnv$instanceSelection$terminology$terminologyName
      contextEvents <- self$contextEnv$instanceSelection$getContextEvents()
      print(self$dataFrame)
      self$dataFrame <- staticFilterCreator$getDataFrame(terminologyName = terminologyName, 
                                                         eventType = eventType, 
                                                         contextEvents = contextEvents, 
                                                         predicateName = self$predicateName)
      print(self$dataFrame)
      self$setHierarchicalData()
      self$makePlot()
    },
    
    setHierarchicalData = function(){
      eventCount <- self$getEventCount()
      ## hierarchy
      hierarchy <- self$getHierarchy()
      staticLogger$info("merging hierarchy and eventCount ...")
      bool <- nrow(eventCount) == 0
      if (bool){
        hierarchicalData <- hierarchy
        hierarchicalData$count <- 0
      } else {
        hierarchicalData <- merge (hierarchy, eventCount, by.x="event", by.y="className",all.x=T)
      }
      bool <- is.na(hierarchicalData$count) | hierarchicalData$count == 0
      staticLogger$info(sum(bool),"have 0 count in the hierarchy")
      hierarchicalData$count[bool] <- 0
      colnames(hierarchicalData) <- c("event","hierarchy","size")
      #hierarchicalData <- rbind(hierarchicalData, data.frame(event="Event",hierarchy="Event",size=0))
      private$checkHierarchicalData(hierarchicalData)
      self$hierarchicalData <- hierarchicalData
    }, 
    
    getHierarchy = function(){
      staticLogger$info("Trying to getHierarchy from server")
      content <- GLOBALcon$getContent(terminologyName = self$terminology$terminologyName,
                                      information = GLOBALcon$information$hierarchy)
      staticLogger$info("Content received, reading content ...")
      hierarchy <- GLOBALcon$readContentStandard(content)
      bool <- colnames(hierarchy) %in% c("event","tree")
      if (!all(bool)){
        staticLogger$error("Unexpected columns :", colnames(hierarchy))
        stop("Unexpected columns :", colnames(hierarchy))
      }
      return(hierarchy)
    },
    
    destroy = function(){
      staticLogger$info("Destroying hierarchicalSunburst",self$getObjectId())
      
      staticLogger$info("\t Destroying observer sunburstObserver")
      if (!is.null(self$sunburstObserver)){
        self$treeObserver$destroy()
        staticLogger$info("\t Done")
      }
      
      staticLogger$info("\t Destroying observer treeObserver")
      if (!is.null(self$treeObserver)){
        self$treeObserver$destroy()
        staticLogger$info("\t Done")
      }
      
      staticLogger$info("\t Destroying observer changePlotObserver")
      if (!is.null(self$changePlotObserver)){
        self$changePlotObserver$destroy()
        staticLogger$info("\t Done")
      }
      
      staticLogger$info("\t Removing hierarchical UI")
      self$removeUIhierarchical()
      
      staticLogger$info("End destroying hierarchical Filter")
    },
    
    getEventTypeSunburst = function(sunburstChoice){
      # hierarchicalChoice is a vector with length the depth of the node in the hierarchy
      staticLogger$info("Getting event from choice : ", sunburstChoice)
      hierarchicalChoice <- sunburstChoice
      if (length(hierarchicalChoice) == 1){ ## it's the top class : no parent
        return(hierarchicalChoice)
      }
      hierarchicalChoice <- paste(hierarchicalChoice, collapse="-")
      bool <- self$hierarchicalData$hierarchy %in% hierarchicalChoice 
      print(self$hierarchicalData)
      if (!any(bool)){
        stop(hierarchicalChoice, " : not found in hierarchicalData")
      }
      if (sum(bool) != 1){
        stop(hierarchicalChoice, " : many possibilities in hierarchicalData")
      }
      eventType <- as.character(self$hierarchicalData$event[bool])
      staticLogger$info("eventType found : ", eventType)
      return(eventType)
    }, 
    
    getObjectId = function(){
      return(paste0("hierarchical",self$parentId))
    },
    
    getSunburstId = function(){
      return(paste0("sunburst",self$getDivSunburstId()))
    },
    
    getShinyTreeId = function(){
      return(paste0("shinyTree",self$getObjectId()))
    },
    
    getDivSunburstId = function(){
      return(paste0("DivSunburstId", self$getObjectId()))
    },
    
    getUIshinytree = function(){
      ui <- shinyTree::shinyTree(outputId = self$getShinyTreeId(),
                                 checkbox = T)
      return(ui)
    },
    
    getUIsunburst = function(){
      ui <- div (id = self$getDivSunburstId(),
           sunburstR::sunburstOutput(outputId = self$getSunburstId()))
      return(ui)
    },
    
    insertUIgraphic = function(){
      if (private$currentChoice == "SHINYTREE"){
        ui <- self$getUIshinytree()
      } else if (private$currentChoice == "SUNBURST") {
        ui <- self$getUIsunburst()
      }
      insertUI(
        selector = private$getJquerySelector(self$getObjectId()),
        where = "beforeEnd",
        ui = ui,
        immediate = T
      )
    },
    
    getChoiceVerbatimId = function(){
      return(paste0("ChoiceVerbatim",self$getObjectId()))
    },
    
    printChoice = function(){
      output[[self$getChoiceVerbatimId()]] <- shiny::renderPrint(
        self$getEventChoice()
      )
      self$contextEnv$instanceSelection$filterHasChanged()
      return(NULL)
    },
   
    getEventChoice = function(){
      return(as.character(private$eventChoice))
    },
    
    getXMLpredicateNode = function(){
      tempQuery <- XMLSearchQuery$new()
      namesChosen <- self$getEventChoice()
      if (length(namesChosen) == 0 || namesChosen == ""){
        return(NULL)
      }
      predicateNode <- tempQuery$makePredicateNode(predicateClass = "factor",
                                                   predicateType = self$predicateName,
                                                   values = namesChosen)
      return(predicateNode)
    },
    
    getEventsSelected = function(){
      if (length(private$eventChoice) == 0){
        return(NULL)
      }
      bool <- self$dataFrame$value %in% private$eventChoice
      eventsSelected <- as.character(self$dataFrame$event[bool])
      return(eventsSelected)
    },
    
    addEventChoiceTree = function(selection){
      private$eventChoice <- selection
      return(NULL)
    },
    
    addEventChoiceSunburst = function(selection){
      previousChoices <- private$eventChoice
      bool <- selection %in% previousChoices
      if  (!bool){
        private$eventChoice <- c(selection,previousChoices)
      }
      return(NULL)
    },
    
    addSunburstObserver = function(){
      inputSunburst <- paste0(self$getSunburstId(), "_click")
      self$sunburstObserver <- observeEvent(input[[inputSunburst]],{
        sunburstChoice <- input[[inputSunburst]]
        if (is.null(sunburstChoice)){
          return(NULL)
        }
        selection <- self$getEventTypeSunburst(sunburstChoice = sunburstChoice)
        staticLogger$user(selection, "selected in ", self$getSunburstId())
        self$addEventChoiceSunburst(selection)
        self$printChoice()
      })
    },
    
    addTreeObserver = function(){
      self$treeObserver <- observeEvent(input[[self$getShinyTreeId()]],{
        #### add an observer for tree : 
        selection <- unlist(get_selected(input[[self$getShinyTreeId()]]))
        print(selection)
        if (is.null(selection)){
          private$eventChoice <- character()
          self$printChoice()
          return(NULL)
        }
        eventChoice <- sapply(selection, function(x) gsub("[(][0-9]+[)]", "",x))
        self$addEventChoiceTree(eventChoice)
        self$printChoice()
      },ignoreNULL = F)
    },

    removeUIgraphic = function(){
      if (private$currentChoice == "SHINYTREE"){
        selector <- paste0("#",self$getShinyTreeId())
      } else if (private$currentChoice == "SUNBURST") {
        selector <- paste0("#",self$getSunburstId())
      }
      removeUI(selector=selector)
    },
    
    insertUIhierarchical = function(){
      staticLogger$info("inserting HierarchicalSunburst", self$getObjectId(),self$where,self$parentId)
      ui <- div (id = self$getObjectId(),
                 shiny::actionButton(inputId = self$getButtonChangePlotId(), label="",
                                     icon = icon("refresh")),
                 shiny::verbatimTextOutput(outputId = self$getChoiceVerbatimId()))

      insertUI(
        selector = private$getJquerySelector(self$parentId),
        where = self$where,
        ui = ui,
        immediate = T
      )
    },
    
    removeUIhierarchical = function(){
      # selector = private$getJquerySelector(self$getObjectId())
      # removeUI(selector = selector)
      session$sendCustomMessage(type = "removeId",
                                message = list(objectId = self$getObjectId()))
    },
    
    makePlot = function(){
      staticLogger$info("Plotting hierarchical", self$getObjectId())
      if (private$currentChoice == "SUNBURST"){
        output[[self$getSunburstId()]] <- renderSunburst({
          sunburstData <- private$getSunburstData()
          add_shiny(sunburst(sunburstData, count=T,legend = list(w=200)))
        })
      } else if (private$currentChoice == "SHINYTREE"){
        staticLogger$info("Outputing shinytree")
        output[[self$getShinyTreeId()]] <- shinyTree::renderTree({
          private$getShinyTreeList2(self$hierarchicalData)
        })
        staticLogger$info("Done")
      }
    },
    
    insertUIandPlot = function(){
      staticLogger$info("Inserting UI hierarchical", self$getObjectId())
      self$insertUIhierarchical()
      self$insertUIgraphic()
      self$makePlot()
    },
    
    addChangePlotObserver = function(){
      self$changePlotObserver <- observeEvent(input[[self$getButtonChangePlotId()]],{
        staticLogger$info("Change plot UI hierarchical", self$getObjectId(), "clicked ! ")
        position <- which(private$plotChoice == private$currentChoice)
        doubleplotList <- rep(private$plotChoice,2)
        self$removeUIgraphic()
        private$currentChoice <- doubleplotList[position+1]
        self$insertUIgraphic()
        staticLogger$info("Changing to", private$currentChoice)
        self$makePlot()
      })
    },
    
    getButtonChangePlotId = function(){
      return(paste0("changeButton",self$getObjectId()))
    }
    
  ),
  
  private = list(
    eventChoice = character(),
    currentChoice = c("SUNBURST"),
    plotChoice = c("SUNBURST","SHINYTREE"),
    
    checkHierarchicalData = function(hierarchicalData){
      columnsNames <- c("event","hierarchy","size")
      bool <- colnames(hierarchicalData) %in% columnsNames
      if (!all(bool)){
        stop("hierarchicalData must be a data.frame containing 3 columns", columnsNames)
      }
    },
    
    getSunburstData = function(){
      staticLogger$info("getSunburstData for HierarchicalSunburst")
      return(subset(self$hierarchicalData, select=c("hierarchy","size")))
    },
    
    getShinyTreeList = function(hierarchicalData){
      ### step1 : create a dataFrame with 2 columns : parent and child
      hierarchy <- as.character(hierarchicalData$hierarchy)
      library(stringr)
      lastChildPattern <- "[-][A-Za-z0-9]+$"
      child <- str_extract(hierarchy,lastChildPattern)
      hierarchy <- gsub(pattern = lastChildPattern,replacement = "", hierarchy)
      parent <- str_extract(hierarchy,"[-][A-Za-z0-9]+$")
      bool <- is.na(parent)
      parent[bool] <- hierarchy[bool]
      child <- gsub("^-","",child)
      parent <- gsub("^-","",parent)
      df_hierarchy <- data.frame(parent=parent, child=child, stringsAsFactors = F)
      
      ### Step 2 : transform this dataFrame in nested list
      bool <- df_hierarchy$parent %in% df_hierarchy$child ## classes qui ne sont pas sous-classe (top classe)
      top <- unique(as.character(df_hierarchy$parent[!bool])) ## no parents
      
      ## recursive function : look at every child for every parent (algorithm goes from top to bottom in the hierarchy)
      recursive <- function(x, df_hierarchy){
        bool <- x %in% df_hierarchy$parent
        if (!bool) {
          return(x)
        } else {
          childs <- subset (df_hierarchy, parent == x)$child
          liste <- lapply(childs, recursive, df_hierarchy = df_hierarchy)
          names(liste) <- childs
          return(liste) 
        }
      }
      
      listes <- vector("list",length(top))
      names(listes) <- top
      i <- 1
      for (i in 1:length(top)){
        listes[[i]] <- recursive (top[i], df_hierarchy)
      }
      ShinyTreeList <- listes
      return(ShinyTreeList)
    },
    
    getShinyTreeListN = function(shinyTreeList, hierarchicalData){
      rmatch_ <- function(x, name) {
        pos <- match(name, names(x))
        if (!is.na(pos)) return(x[[pos]])
        for (el in x) {
          if (class(el) == "list") {
            out <- Recall(el, name)
            if (!is.null(out)) return(out)
          }
        }
      }
      require(jsonlite)
      ## fonction récursive pour récupérer tous les noms de la liste :  
      getnames_of_liste <- function(liste){
        if (is.list(liste)){
          nom <- names(liste)
          noms <- NULL
          for (i in nom){
            noms <- append(noms,getnames_of_liste(liste[[i]]))
          }
          return(c(nom,noms))
        } else 
        {
          return(NULL)
        }
      }
      
      ### on a une hiérarchie
      # pour le niveau le plus bas de la hiérarchie, on connait le nombre de valeurs :
      lowestlevel <- as.character(unlist(shinyTreeList))
      eventN <- subset (hierarchicalData, select=c("event","size"))
      bool <- eventN$event %in% lowestlevel
      eventN <- subset (eventN,bool)
      tab <- eventN
      colnames(tab) <- c("classe","value")
      
      ## il faut ajouter aux noms de la hiérarchie le nombre de valeurs
      noms <- getnames_of_liste(shinyTreeList)
      bool <- noms%in%lowestlevel ## on enlève le lowest levels
      noms <- noms[!bool]
      noms <- rev(noms) ## rev permet de classer du plus petit niveau de la hiérarchie
      ## au plus haut ; important car ensuite on itère dans cet ordre pour déterminer le nombre
      superclasse <- data.frame (classe=noms, value=NA)
      
      tab <- rbind(tab, superclasse) ## on a les valeurs pour le lowest level, on détermine pour les niveaux au-dessus
      
      for (i in noms){
        fils <- names(rmatch_(shinyTreeList, i))
        tab$value[tab$classe == i] <- sum(tab$value[tab$classe %in% fils])
      }
      tab$newname <- paste0(tab$classe,"(",tab$value,")")
      
      ## il faut maintenant remplacer les valeurs ...
      # je n ai pas trouvé de solution plus élégante que d'écrier le JSON dans un txt
      # puis de remplacer les chaines de charactere
      txt <- jsonlite::prettify(jsonlite::toJSON(shinyTreeList))
      txt <- unlist(strsplit(as.character(txt),"\n"))
      
      i <- 1
      for (i in 1:nrow(tab)){
        oldname <- paste0("\"",as.character(tab$classe[i]),"\"")
        newname <- paste0("\"",tab$newname[i],"\"")
        numligne <- min(which(grepl(oldname, txt)))
        txt[numligne] <- gsub(oldname,newname,txt[numligne])
      }
      
      hierarchylisteN <- jsonlite::fromJSON(txt)
      return(hierarchylisteN)
    },
    
    getShinyTreeList2 = function(hierarchicalData){
      shinyTreeList <- private$getShinyTreeList(hierarchicalData)
      shinyTreeListN <- private$getShinyTreeListN(shinyTreeList = shinyTreeList, hierarchicalData = hierarchicalData)
      return(shinyTreeListN)
    }
  )
)

