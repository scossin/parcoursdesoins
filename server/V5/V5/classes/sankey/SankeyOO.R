Sankey <- R6::R6Class(
  "Sankey",
  inherit=uiObject,
  
  public = list(
    result = NULL,
    validateObserver = NULL,
    plotSankeyObserver = NULL,
    V1V2Observer = NULL,
    dfSankey = data.frame(),
    boolV1 = logical(),
    hideShowButton = NULL,
    isInsertedGraphicSankey = F,
    searchQueries = NULL,
    
    initialize = function(parentId, where){
      staticLogger$info("New Sankey")
      super$initialize(parentId, where)
      self$searchQueries <- SearchQueries$new(parentId = GLOBALmainPanelSankeyId, 
                                              where = "beforeEnd",
                                              validateButtonId = self$getValidateButtonId())
      self$insertSankeyUI()
      self$addValidateObserver()
      self$addMakeSankeyObserver()
      self$addPlotSankeyObserver()
      self$addV1V2Observer()
      self$boolV1 <- T
    },
    
    insertSankeyUI = function(){
      jQuerySelector = paste0("#",self$parentId)
      insertUI(
        selector = jQuerySelector, 
        where = self$where,
        ui = self$getUI(),
        immediate = F)
    },
    
    getUI = function(){
      ui <- div(id = self$getDivId(),
                div (id = self$getSankeyParamId(),
                     shiny::actionButton(inputId = self$getButtonMakeSankeyId(),
                                         label = "MakeSankey"),
                     shiny::actionButton(inputId = self$getButtonPlotSankeyId(),
                                         label = "PlotSankey"),
                     shiny::radioButtons(inputId = self$getV1V2choiceId(),
                                         label = "Sankey style",
                                         choices = c("V1","V2"),
                                         selected = "V1")),
                div(id = self$getSankeyPlotDivId()
                    )
                
                
      )
    },
    
    insertUIgraphicSankey = function(){
      if (self$isInsertedGraphicSankey){
        return(NULL)
      }
      jQuerySelector = paste0("#",self$getSankeyPlotDivId())
      ui <- sankeyD3::sankeyNetworkOutput(self$getSankeyGraphicId())
      insertUI(selector = jQuerySelector,
               where = "beforeEnd",
               ui = ui,
               immediate=T)
      self$isInsertedGraphicSankey <- T
    },
    
    addPlotSankeyObserver = function(){
      self$plotSankeyObserver <- observeEvent(input[[self$getButtonPlotSankeyId()]],{
        self$insertUIgraphicSankey()
        if (is.null(self$hideShowButton)){
          self$hideShowButton <- HideShowButton$new(parentId = self$getSankeyParamId(),
                                                    where = "beforeEnd",
                                                    divIdToHide = self$getSankeyPlotDivId(),
                                                    boolHideFirst = F)
        }
        
        staticLogger$user("Plot Sankey clicked ")
        if (is.null(self$dfSankey) || nrow(self$dfSankey) == 0){
          staticLogger$info("Sankey Df not set yet")
          return(NULL)
        }
        self$plotSankey()
      })
    },
    
    addV1V2Observer = function(){
      self$V1V2Observer <- observeEvent(input[[self$getV1V2choiceId()]],{
        staticLogger$user("V1V2 sankey choice clicked ")
        bool <- input[[self$getV1V2choiceId()]] == "V1"
        if (bool){
          self$boolV1 <- T
        } else {
          self$boolV1 <- F
        }
      })
    },
    
    plotSankey = function(){
      staticLogger$user("plotSankey function called")
      output[[self$getSankeyGraphicId()]] <- sankeyD3::renderSankeyNetwork({
        private$makeSankey(df_sankey = self$dfSankey, V1=self$boolV1, V2=!self$boolV1)
      })
    },
    
    addValidateObserver = function(){
      self$validateObserver <- observeEvent(input[[self$getValidateButtonId()]],{
        staticLogger$user("Validate Button Sankey clicked ")
        
        queryChoice <- input[[self$searchQueries$getSelectizeResultId()]]

        if (is.null(queryChoice) || queryChoice == ""){
          staticLogger$info("No query selected")
          return(NULL)
        }
        
        staticLogger$info("Sankey : ", queryChoice, "selected")
        
        queryChoice <- gsub(GLOBALquery,"",queryChoice)
        queryChoice <- as.numeric(queryChoice)
        lengthListResults <- length(GLOBALlistResults$listResults)
        bool <- queryChoice > lengthListResults
        if (bool){
          stop("queryChoice number not found in GLOBALlistResults ")
        }
        self$result <- GLOBALlistResults$listResults[[queryChoice]]
        self$setEventTabpanel()
      })
    },
    
    setEventTabpanel = function(){
      getContextEvents_ = function(resultDf,eventNumber){
        print(nrow(resultDf))
        event <- paste0("event",eventNumber)
        bool <- event %in% colnames(resultDf)
        if (!bool){
          stop(event, "unfound in resultDf colnames : ", colnames(resultDf))
        }
        bool <- colnames(resultDf) %in% c("context",event)
        if (sum(bool)!=2){
          stop("context unfound in resultDf colnames : ", colnames(resultDf))
        }
        contextEvents <- resultDf[,bool]
        return(contextEvents)
      }
      
      staticLogger$info("setEventTabpanel of Sankey")
      xmlSearchQuery <- self$result$XMLsearchQuery
      Nevents <- length(xmlSearchQuery$listEventNodes)
      context <- self$result$resultDf$context
      GLOBALSankeylistEventTabpanel$emptyTabpanel() ## empty before adding new
      for (eventNode in xmlSearchQuery$listEventNodes){
        eventNumber <- xmlSearchQuery$getEventNumber(eventNode)
        eventType <- xmlSearchQuery$getEventTypeByEventNode(eventNode)
        eventTabpanel <- EventTabpanel$new(eventNumber = eventNumber,
                                           context = context,
                                           tabsetPanelId = GLOBALeventTabSetPanelSankey)
        contextEvents <- getContextEvents_(resultDf = self$result$resultDf,
                                           eventNumber = eventNumber)
        eventTabpanel$createInstanceSelectionEvent(contextEvents = contextEvents, 
                                                   eventType = eventType)
        GLOBALSankeylistEventTabpanel$addEventTabpanel(eventTabpanel)
      }
    },

    getDivId = function(){
      return(paste0("divSankey-",self$parentId))
    },
    
    getValidateButtonId = function(){
      return(paste0("buttonValidateResult-",self$getDivId()))
    },
    
    getSankeyParamId = function(){
      return(paste0("SankeyParam-",self$getDivId()))
    },
    
    getButtonMakeSankeyId = function(){
      return(paste0("MakeSankeyId-",self$getSankeyParamId()))
    },
    
    getButtonPlotSankeyId = function(){
      return(paste0("SankeyPlot-",self$getSankeyParamId()))
    },
    
    getV1V2choiceId = function(){
      paste0("V1V2choice",self$getSankeyParamId())
    },
    
    getSankeyPlotDivId = function(){
      return(paste0("DivPlotSankey",self$getDivId()))
    },
    
    getSankeyGraphicId = function(){
      paste0("SankeyGraphic-",self$getSankeyPlotDivId())
    },
    
    addMakeSankeyObserver = function(){
      observeEvent(input[[self$getButtonMakeSankeyId()]],{
        staticLogger$user(" MakeSankey clicked !")
        tempResult <- self$result$resultDf
        staticLogger$info(nrow(tempResult), " resultDf lines initially")
        column <- 2
        sankeyColumns <- NULL
        if (length(GLOBALSankeylistEventTabpanel$listEventTabpanel) == 0){
          staticLogger$info(" no event in predicate")
          return(NULL)
        }
        for (i in 1:length(GLOBALSankeylistEventTabpanel$listEventTabpanel)){
          eventTabpanel <- GLOBALSankeylistEventTabpanel$listEventTabpanel[[i]]
          eventName <- names(GLOBALSankeylistEventTabpanel$listEventTabpanel)[[i]]
          instanceSelection <- eventTabpanel$contextEnv$instanceSelection
          eventValue <- instanceSelection$getValue4Sankey()
          if (is.null(eventValue)){
            staticLogger$info(eventName, " no predicate selected")
            return(NULL)
          }
          colnameResult <- colnames(tempResult)[column]
          print(tempResult)
          print(eventValue)
          tempResult <- merge (tempResult, eventValue, by.x=colnameResult, by.y="event")
          newSankeyColumn <- paste0("value", eventName)
          colnames(tempResult)[length(colnames(tempResult))] <- newSankeyColumn
          column <- column + 1
          sankeyColumns <- append(sankeyColumns, newSankeyColumn)
        }
        
        self$dfSankey <- subset(tempResult,select=sankeyColumns)
        staticLogger$info(nrow(self$dfSankey), " lines after merging")
      })
    },
    
    addResult = function(result){
      bool <- inherits(result, "Result")
      if (!bool){
        stop("result must be instance of Result")
      }
      listLength <- length(self$listResults)
      self$listResults[[listLength+1]] <- eventTabpanel
    }),
    
    private = list(
      ## fonction pour réaliser le sankey
      makeSankey = function(df_sankey, V1 = F, V2 = T){
        ## re-ordonner les colonnes :
        # si colonne patient on l'enlève :
        
        # numeros <- str_extract(colnames(df_sankey), "[-]?[0-9]+")
        # numeros <- as.numeric(numeros)
        # df_sankey <- df_sankey[,match(sort(numeros),numeros)]
        # numeros <- sort(numeros)
        
        ## on ajoute le numéro de l'event :
        for (i in 1:length(df_sankey)){
          df_sankey[,i] <- as.factor( df_sankey[,i])
          #levels(df_sankey[,i]) <- paste0(levels(df_sankey[,i]), "NUM",numeros[i])
          levels(df_sankey[,i]) <- paste0(levels(df_sankey[,i]), "NUM",i)
          # df_sankey[,i] <- paste0(df_sankey[,i], numeros[i])
        }
        
        ### premier type de regroupement
        ## on compte le nombre de trajectoires uniques 
        
        if (V1){
          grp_cols <- names(df_sankey)
          dots <- lapply(grp_cols, as.symbol)
          df_sankey2 <- df_sankey %>% group_by_(.dots=dots) %>% summarise(N=n())
          df_sankey2 <- data.frame(df_sankey2)
          
          #### l'ordre ici est très important, c'est ce qui détermine ensuite l'alignement des noeuds sur le sankey !
          df_sankey2 <- df_sankey2[order(-df_sankey2$N),]
          
          
          ### on met le nombre entre parenthèse au premier event pour l'affichage sur le Sankey
          ## bcp plus jolie que de répéter le N à chaque event alors que le N est le meme (NodeValue = F)
          df_sankey2[,1] <- paste0("(",df_sankey2$N,")",df_sankey2[,1])
          ## ajouter l'id du cluster (cluster = trajectoire unique)
          cluster <- 1:nrow(df_sankey2)
          
          i <- 1
          for (i in 1:(length(df_sankey2)-1)){
            df_sankey2[,i] <- paste0(df_sankey2[,i], cluster)
          }
          
          ## création de links et nodes pour les besoins du sankey - 2 colonnes : source et target
          links <- NULL
          i <- 1
          for (i in 1:(length(df_sankey2)-2)){
            ajout <- df_sankey2[,c(i:(i+1), length(df_sankey2))]
            colnames(ajout) <- c("source","target","N")
            links <- rbind (links, ajout)
          }
          # bool <- grepl("^NA",links$target)
          # sum(bool)
          # links <- subset (links, !bool)
          nodes <- c(as.character(links$source),as.character(links$target))
          nodes <- unique(nodes)
          nodes <- data.frame(name=nodes)
          
          ### il faut retirer le name et mettre un id pour que sankeyD3 accepte :
          ## alors que GoogleVis accepte ce format
          # cependant il n'est pas possible de changer le label avec googleVis !
          # test <- googleVis::gvisSankey(links, from="source",to="target",weight = "N",
          #                       options=list(sankey = "{node: {interactivity: true, width: 50}}",
          #                                    width="800px", height="800px"))
          # plot(test)
          
          
          nodes$id <- 0:(nrow(nodes)-1) ## doit commencer à 0 pour JS
          links <- merge (links, nodes, by.x="source",by.y="name")
          links <- merge (links, nodes, by.x="target", by.y="name")
          links$target <- NULL
          links$source <- NULL
          colnames(links) <- c("N","source","target")
          
          nodes$name <- gsub("NUM[-]?[0-9]+$","",nodes$name) ## suprprimer le numéro de l'event et du cluster
          nodes$groupe <- gsub("^[(0-9)]+","",nodes$name) ## pour avoir le groupe : chaque groupe a une couleur différente
          nodes$name <- gsub("NA$","",nodes$name) ## remplacer les NA par ""
          
          # nodes$position <- str_extract(nodes$name,"[0-9]")
          # nodes$position <- as.numeric(nodes$position)
          
          ##### j'essayais de me battre pour mettre les couleurs : 
          # couleurs <- rainbow(3)
          # pie(1:length(couleurs),col=couleurs)
          # couleurs <- tolower(couleurs)
          # couleurs <- c("#7d3945","#e0677b", "#244457")
          # couleurs <-  paste(couleurs, collapse="\",\"")
          # couleurs <- paste0('d3.scaleOrdinal().range(["',couleurs, '"])')
          # car je voulais mettre aucun couleur pour NA
          
          sankey <- sankeyNetwork(Links = links, Nodes = nodes, Source = "source",
                                  Target = "target", Value = "N", NodeID = "name",
                                  units = "TWh", fontSize = 12, nodeWidth = 30,nodePadding=1,numberFormat = ".0f",
                                  dragX = T, dragY = T, NodeGroup = "groupe",showNodeValues = F, highlightChildLinks=T,
                                  zoom = T)
          
          return(sankey)
        }
        
        
        ##### pour ce regroupement, les noeuds d'un meme axe sont mergés ; on voit avant/apres pour un event mais pas plus loin
        
        if (V2){
          ## si un event est facultatif, un event sera "NA"
          # il faut récupérer le remplacer par le next event :
          for (i in 2:length(df_sankey)){ ## on ignore le premier et le dernier event
            bool <- is.na(df_sankey[,i-1]) & !is.na(df_sankey[,i])
            df_sankey[,i-1] <- ifelse(!bool, as.character(df_sankey[,i-1]), as.character(df_sankey[,i]))
          }
          
          df_sankey <- df_sankey[order(df_sankey[,1]),]
          
          ### links et nodes pour networkd3
          links <- NULL
          for (i in 1:(length(df_sankey)-1)){
            ajout <- df_sankey[,c(i:(i+1))]
            colnames(ajout) <- c("source","target")
            links <- rbind (links, ajout)
          }
          
          ## retirer les NA de fin
          bool <- is.na(links$target)
          links <- subset (links, !bool)
          
          ## si c'est égal c'est lié au remplacement des NA ci-dessus
          bool <- links$source == links$target & !is.na(links$source)
          links <- subset (links, !bool)
          
          bool <- is.na(links$source)
          links$source[bool] <- ""## pour faire disparaitre NA
          links <- group_by(links, source,target)
          links <- summarise(links, N=n())
          links <- data.frame(links)
          
          
          ### remplacer tous les NA par "" ??
          
          #### avec Google::gvisSankey :
          # test <- googleVis::gvisSankey(links, from="source",to="target",weight = "N",
          #                       options=list(sankey = "{node: {interactivity: true, width: 50}}",
          #                                    width="800px", height="800px"))
          # plot(test)
          
          
          nodes <- c(as.character(links$source),as.character(links$target))
          nodes <- unique(nodes)
          nodes <- data.frame(name=nodes)
          
          ### il faut retirer le name et mettre un id pour que sankeyD3 accepte :
          nodes$id <- 0:(nrow(nodes)-1) ## doit commencer à 0 pour JS
          links <- merge (links, nodes, by.x="source",by.y="name")
          links <- merge (links, nodes, by.x="target", by.y="name")
          links$target <- NULL
          links$source <- NULL
          colnames(links) <- c("N","source","target")
          
          # nodes$groupe <- gsub("[-]?[0-9]+$","",nodes$name) ## suprprimer le numéro de l'event et du cluster
          nodes$name <- gsub("NUM[-]?[0-9]+$","",nodes$name)
          nodes$groupe <- nodes$name
          ## retirer 
          
          sankey <- sankeyNetwork(Links = links, Nodes = nodes, Source = "source",
                                  Target = "target", Value = "N", NodeID = "groupe",
                                  units = "TWh", fontSize = 12, nodeWidth = 30,nodePadding=1,numberFormat = ".0f",
                                  dragX = T, dragY = T,NodeGroup = "groupe", zoom = T)
          
          return(sankey)
        } ## fin V2
      } ## fin fonction
  )
)