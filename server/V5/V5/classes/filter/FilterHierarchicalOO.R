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
      private$setRandomNumber()
      staticLogger$info("initiliazing a new HierarchicalSunburst")
      self$terminology <- terminology
      self$setHierarchicalData()
      self$insertUIandPlot()
      self$addTreeObserver()
      self$addSunburstObserver()
      self$addChangePlotObserver()
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
      description <- paste0(lengthChosen, " ",  GLOBALvaleursselected, " (",
                            namesChosen, ")")
      predicateLabel <- self$getPredicateLabel()
      lipredicate <- shiny::tags$li(predicateLabel, class= GLOBALliPredicateLabelClass,
                                    shiny::tags$p(description))
      return(lipredicate)
    },
    
    updateDataFrame = function(){
      staticLogger$info("updateDataFrame of FilterHierarchical")
      eventType <- self$contextEnv$instanceSelection$className
      terminologyName <- self$contextEnv$instanceSelection$terminology$terminologyName
      contextEvents <- self$contextEnv$instanceSelection$getContextEvents()
      # print(self$dataFrame)
      self$dataFrame <- staticFilterCreator$getDataFrame(terminologyName = terminologyName, 
                                                         eventType = eventType, 
                                                         contextEvents = contextEvents, 
                                                         predicateName = self$predicateName)
      # print(self$dataFrame)
      self$setHierarchicalData()
      self$makePlot()
    },
    
    ### DONT touch this function getEventCount because FilterHierarchicalEvent overrides it !
    getEventCount = function(){
      tab <- table(self$dataFrame$value)
      eventCount <- data.frame(className = names(tab), count = as.numeric(tab))
      return(eventCount)
    },
    
    setHierarchicalData = function(){
      staticLogger$info("Setting hierarchical Data")
      eventCount <- self$getEventCount()
      # print(eventCount)
      ## hierarchy
      hierarchy <- self$getHierarchy()
      # print(hierarchy)
      staticLogger$info("\t Merging hierarchy and eventCount ...")
      bool <- nrow(eventCount) == 0
      if (bool){
        hierarchicalData <- hierarchy
        hierarchicalData$count <- 0
        private$eventChoice <- GLOBALnoChoiceAvailable
        self$printChoice()
      } else {
        bool <- hierarchy$code %in% eventCount$className
        hierarchy <- subset (hierarchy, bool)
        hierarchicalData <- merge (hierarchy, eventCount, by.x="code", by.y="className",all.x=T)
      }
      bool <- is.na(hierarchicalData$count) | hierarchicalData$count == 0
      staticLogger$info(sum(bool),"have 0 count in the hierarchy")
      hierarchicalData$count[bool] <- 0
      colnames(hierarchicalData) <- c("code","label","hierarchy","size")
      #hierarchicalData <- rbind(hierarchicalData, data.frame(event="Event",hierarchy="Event",size=0))
      # private$checkHierarchicalData(hierarchicalData)
      self$hierarchicalData <- hierarchicalData
    }, 
    
    getHierarchy = function(){
      staticLogger$info("Trying to getHierarchy from server")
      content <- GLOBALcon$getContent(terminologyName = self$terminology$terminologyName,
                                      information = GLOBALcon$information$hierarchy)
      # print(self$terminology$terminologyName)
      # print(content)
      # staticLogger$info("Content received, reading content ...")
      hierarchy <- GLOBALcon$readContentStandard(content)
      bool <- colnames(hierarchy) %in% c("code","label","tree")
      if (!all(bool)){
        staticLogger$error("Unexpected columns :", colnames(hierarchy))
        stop("Unexpected columns :", colnames(hierarchy))
      }
      return(hierarchy)
    },
    
    destroy = function(){
      staticLogger$info("Destroying hierarchicalSunburst",self$getHierarchicalPlotId())
      
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
    
    getCodeFromLabel = function(label){
      # print(self$hierarchicalData)
      bool <- self$hierarchicalData$label == label
      if (sum(bool)== 0){
        staticLogger$error(label, "not found in hierarchicalData")
        stop("")
      }
      if (sum(bool) > 1){
        staticLogger$error(label, "more than 1 label found")
        stop("")
      }
      return(as.character(self$hierarchicalData$code[bool]))
    },
    
    getEventTypeSunburst = function(sunburstChoice){
      # sunburstChoice is a vector with length the depth of the node in the hierarchy
      staticLogger$info("Getting event from choice : ", sunburstChoice)
      sunburstChoice <- paste(sunburstChoice, collapse="-")
      bool <- grepl(pattern = sunburstChoice,self$hierarchicalData$hierarch, fixed = T)
      # bool <- self$hierarchicalData$hierarchy %in% sunburstChoice 
      # print(self$hierarchicalData)
      if (!any(bool)){
        stop(sunburstChoice, " : not found in hierarchicalData")
      }
      # if (sum(bool) != 1){
      #   stop(sunburstChoice, " : many possibilities in hierarchicalData")
      # }
      eventType <- as.character(self$hierarchicalData$label[bool])
      staticLogger$info("eventType found : ", eventType)
      return(eventType)
    }, 
    
    getDivId = function(){
      return(paste0("hierarchical-", private$randomNumber,self$parentId))
    },
    
    getHierarchicalPlotId = function(){
      return(paste0("HierarchicalPlot",self$getDivId()))
    },
    
    getDivSunburstId = function(){
      return(paste0("DivSunburstId", self$getHierarchicalPlotId()))
    },
    
    getSunburstId = function(){
      return(paste0("sunburst",self$getDivSunburstId()))
    },
    
    getShinyTreeId = function(){
      return(paste0("shinyTree",self$getHierarchicalPlotId()))
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
    
    getChoiceVerbatimId = function(){
      return(paste0("ChoiceVerbatim",self$getDivId()))
    },
    
    printChoice = function(){
      output[[self$getChoiceVerbatimId()]] <- shiny::renderPrint(
        self$getEventChoice()
      )
      self$contextEnv$instanceSelection$filterHasChanged()
      return(NULL)
    },
   
    getCodeChoice = function(){
      labelChoices <- self$getEventChoice()
      bool <- as.character(self$hierarchicalData$label) %in% as.character(labelChoices)
      print(labelChoices)
      print(sum(bool))
      return(as.character(self$hierarchicalData$code[bool]))
    },
    
    getEventChoice = function(){
      return(as.character(private$eventChoice))
    },
    
    getXMLpredicateNode = function(){
      tempQuery <- XMLSearchQuery$new()
      namesChosen <- self$getCodeChoice()
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
      private$eventChoice <- c(selection[!bool],previousChoices)
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
        if (is.null(selection)){
          private$eventChoice <- character()
          self$printChoice()
          return(NULL)
        }
        eventChoice <- sapply(selection, function(x) gsub(" [(][0-9]+[)]$", "",x))
        staticLogger$user("New user choice ShinyTree: ", eventChoice)
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
      staticLogger$info("inserting HierarchicalSunburst")
      ui <- div (id = self$getDivId(),
                 shiny::actionButton(inputId = self$getButtonChangePlotId(), label="",
                                     icon = icon("refresh")),
                 shiny::verbatimTextOutput(outputId = self$getChoiceVerbatimId()),
                 div(id = self$getHierarchicalPlotId()))

      insertUI(
        selector = private$getJquerySelector(self$parentId),
        where = self$where,
        ui = ui,
        immediate = T
      )
    },
    
    insertUIgraphic = function(){
      if (private$currentChoice == "SHINYTREE"){
        ui <- self$getUIshinytree()
      } else if (private$currentChoice == "SUNBURST") {
        ui <- self$getUIsunburst()
      }
      insertUI(
        selector = private$getJquerySelector(self$getHierarchicalPlotId()),
        where = "beforeEnd",
        ui = ui,
        immediate = T
      )
    },
    
    removeUIhierarchical = function(){
      # selector = private$getJquerySelector(self$getHierarchicalPlotId())
      # removeUI(selector = selector)
      # self$removeUIgraphic()
      # session$sendCustomMessage(type = "removeId",
      #                           message = list(objectId = self$getChoiceVerbatimId()))
      session$sendCustomMessage(type = "removeId",
                                message = list(objectId = self$getDivId()))
    },
    
    getShinyList = function(){
      terminologyName <- self$terminology$terminologyName
      dfShinyTreeQuery <- subset(self$hierarchicalData, size != 0, select=c("code","size"))
      print(dfShinyTreeQuery)
      dfShinyTreeQuery$terminologyName <- ""
      dfShinyTreeQuery <- dfShinyTreeQuery[,c(3,1,2)]
      colnames(dfShinyTreeQuery)[1] <- terminologyName
      content <- GLOBALcon$getShinyTreeList(dfShinyTreeQuery)
      print(content)
      return(content)
    },
    
    makePlot = function(){
      staticLogger$info("Plotting hierarchical", self$getHierarchicalPlotId())
      if (private$currentChoice == "SUNBURST"){
        output[[self$getSunburstId()]] <- renderSunburst({
          sunburstData <- private$getSunburstData()
          sunburstData <- subset (sunburstData, size !=0)
          staticLogger$info("Trying to plot sunburst")
          add_shiny(sunburst(sunburstData, count=T,legend = list(w=200)))
        })
      } else if (private$currentChoice == "SHINYTREE"){
        staticLogger$info("Outputing shinytree")
        output[[self$getShinyTreeId()]] <- shinyTree::renderTree({
          jsonlite::fromJSON(self$getShinyList())
        })
      }
    },
    
    insertUIandPlot = function(){
      staticLogger$info("Inserting UI hierarchical", self$getHierarchicalPlotId())
      self$insertUIhierarchical()
      self$insertUIgraphic()
      self$makePlot()
    },
    
    addChangePlotObserver = function(){
      self$changePlotObserver <- observeEvent(input[[self$getButtonChangePlotId()]],{
        staticLogger$info("Change plot UI hierarchical", self$getHierarchicalPlotId(), "clicked ! ")
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
      return(paste0("changeButton",self$getHierarchicalPlotId()))
    }
    
  ),
  
  private = list(
    
    randomNumber = numeric(),
    
    setRandomNumber = function(){
      private$randomNumber =  abs(round(runif(1)*10000000,0))
    },
    
    
    
    eventChoice = character(),
    currentChoice = c("SUNBURST"),
    plotChoice = c("SUNBURST","SHINYTREE"),
    
    # checkHierarchicalData = function(hierarchicalData){
    #   columnsNames <- c("event","hierarchy","size")
    #   bool <- colnames(hierarchicalData) %in% columnsNames
    #   if (!all(bool)){
    #     stop("hierarchicalData must be a data.frame containing 3 columns", columnsNames)
    #   }
    # },
    
    getSunburstData = function(){
      staticLogger$info("getSunburstData for HierarchicalSunburst")
      sunburstData <- subset(self$hierarchicalData, select=c("hierarchy","size"))
      return(sunburstData)
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


# read in sample visit-sequences.csv data provided in source
# only use first 200 rows to speed package build and check
#   https://gist.github.com/kerryrodden/7090426#file-visit-sequences-csv
# sequences <- read.csv(
#   system.file("examples/visit-sequences.csv",package="sunburstR")
#   ,header = FALSE
#   ,stringsAsFactors = FALSE
# )[1:100,]
# 
# sequences$V1 <- gsub("-","\t",sequences$V1)
# sunburst(sequences)
# 
# jsonlite::fromJSON(data)
# csv_to_hierd