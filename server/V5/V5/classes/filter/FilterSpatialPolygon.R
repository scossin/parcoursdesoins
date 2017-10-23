FilterSpatialPolygon <- R6::R6Class(
  "FilterSpatialPolygon",
  inherit=Filter,
  
  public = list(
    spatialPolygon = NULL,
    eventName = character(),
    polygonCoordinate = data.frame(),
    selectizeChoicesObserver = NULL,
    markerObserver = NULL,
    pal = NULL,
    boolUpdating = F, ## when updating SelectizeInput : first NULL then Selected => first NULL is boolUpdating
    
    initialize = function(contextEnv, predicateName, dataFrame, parentId, where){
      staticLogger$info("Creating a new FilterSpatialPolygon object")
      super$initialize(contextEnv, predicateName, dataFrame, parentId, where)
      eventName <- paste0("event",contextEnv$eventNumber, "-",self$predicateName)
      self$eventName <- eventName
      self$pal <- colorQuantile("RdYlBu", self$spatialPolygon$N, n = 1)
      self$setPolygonCoordinate()
      ## shapeFile check and load : 
      self$loadShapeFile()
      self$addMetadataToShapeFile()
      self$insertUIseeMap()
      self$insertUIControllerMap()
      self$addSpatialLayer()
      self$updateSelectizeChoices()
      self$addSelectizeChoicesObserver()
      staticLogger$info("FilterSpatialPolygon object created")
    },
    
    updateDataFrame = function(){
      staticLogger$info("updateDataFrame of FilterSpatialPolygon")
      eventType <- self$contextEnv$instanceSelection$className
      terminologyName <- self$contextEnv$instanceSelection$terminology$terminologyName
      predicateName <- self$predicateName
      contextEvents <- self$contextEnv$instanceSelection$getContextEvents()
      self$dataFrame <- staticFilterCreator$getDataFrame(terminologyName, eventType, 
                                                         contextEvents, 
                                                         predicateName)
      
      ## remove 
      self$removeMarkerLayer()
      # GLOBALmapObject$removeSpatialFilter(self$eventName)
      
      ## previous selection : 
      bool <- self$spatialPolygon$isSelected
      values <- as.character(self$spatialPolygon$value[bool])
      self$setPolygonCoordinate()
      self$addMetadataToShapeFile(previousValues = values)
      ## add previous selection
     
      self$addSpatialPolygon()
      
      self$updateSelectizeChoices()
      
      self$contextEnv$instanceSelection$filterHasChanged()
    },
    
    setPolygonCoordinate = function(){
      polygonCoordinate <- table(self$dataFrame$value)
      polygonCoordinate <- data.frame(event = names(polygonCoordinate), 
                                     N = as.numeric(polygonCoordinate))
      terminologyName <- self$contextEnv$instanceSelection$terminology$terminologyName
      expectedValue <- self$contextEnv$instanceSelection$terminology$getPredicateDescription(self$predicateName)$value
      
      for (spatialPredicate in c("layerId","shapeFile")){
        addColumn <- staticFilterCreator$getDataFrame(terminologyName = terminologyName, 
                                       eventType = expectedValue, 
                                       contextEvents = polygonCoordinate, 
                                       predicateName = spatialPredicate)
        colnames(addColumn) <- c("event",spatialPredicate)
        polygonCoordinate <- merge (polygonCoordinate, addColumn, by="event")
      }
      numCol <- which(colnames(polygonCoordinate) == "event")
      colnames(polygonCoordinate)[numCol] <- "value"
      private$checkpolygonCoordinate(polygonCoordinate)
      #}
      
      self$polygonCoordinate <- polygonCoordinate
    },
    
    loadShapeFile = function(){
      shapeFile <- as.character(unique(self$polygonCoordinate$shapeFile))
      self$polygonCoordinate$shapeFile <- NULL
      if (length(shapeFile) > 2){
        staticLogger$error("Error in shapeFile : it's not unique : ", shapeFile)
        stop("")
      }
      
      #shapeFile <- shapeFiles[1]
      shapeFiles <- list.files(GLOBALshapeFileFolder)
      bool <- shapeFile %in% shapeFiles
      if (!bool){
        staticLogger$error("Error in shapeFile. Unfound file : ", shapeFile,
                           " in folder : ", GLOBALshapeFileFolder)
        stop("")
      }
      shapeFiles <- list.files(GLOBALshapeFileFolder,full.names = T)
      fileName <- shapeFiles[bool]
      # load
      load(fileName)
      objectName <- load(fileName)
      self$spatialPolygon <- get(objectName)
      rm(list=objectName) ## maybe not important
      bool <- inherits(self$spatialPolygon, what="SpatialPolygonsDataFrame")
      if (!bool){
        stop(fileName, "is not a SpatialPolygonsDataFrame")
      }
      self$spatialPolygon <- spTransform(self$spatialPolygon, CRS("+init=epsg:4326")) ## WGS84
      
      if (shapeFile == "couchegeoPMSI2014.rdata"){ ## hard coded : too many pmsi geo codes, a bit slow
        self$spatialPolygon <- subset (self$spatialPolygon, substr(self$spatialPolygon$layerId,1,2) == 33)
      }
      
      bool <- c("layerId", "label") %in% colnames(self$spatialPolygon@data)
      if (!all(bool)){
        staticLogger$error(c("layerId", "label")[!bool],
                           "not found in spatialPolygon", fileName)
        stop("")
      }
    },
    
    addMetadataToShapeFile = function(previousValues = NULL){
      self$spatialPolygon$N <- NULL
      self$spatialPolygon$isSelected <- NULL
      self$spatialPolygon$value <- NULL 
      self$spatialPolygon$shapeFile <- NULL
      ### put N in spatialPolygon :
      layerIds <- self$spatialPolygon@data$layerId
      self$spatialPolygon@data <- merge (self$spatialPolygon@data,
                                         self$polygonCoordinate,by="layerId",all.x=T
      )
      
      ## keep the same order of layerId or the map will be wrong : 
      numRows <- match(layerIds, self$spatialPolygon@data$layerId)
      self$spatialPolygon@data <- self$spatialPolygon@data[numRows,]
      
      bool <- is.na(self$spatialPolygon@data$N)
      self$spatialPolygon@data$N[bool] <- 0
      ### is selected : 
      self$spatialPolygon$isSelected <- F
      
      self$pal <- colorNumeric(
        palette = "Blues",
        domain = c(0,max(self$polygonCoordinate$N)),na.color = "white"
      )
      #self$pal <- colorQuantile("RdYlBu", self$spatialPolygon$N, n = 1)
      self$spatialPolygon@data$color <- self$pal(self$spatialPolygon$N)
      self$spatialPolygon@data$popupLabel <- paste0(self$spatialPolygon@data$label,"(",
                                                    self$spatialPolygon@data$N,")")
      
      ## 
      if (!is.null(previousValues)){
        bool <- self$spatialPolygon@data$value %in% previousValues
        self$spatialPolygon@data$isSelected <- bool
      }
    },
    
    addSpatialLayer = function(){
      self$addSpatialPolygon()
      self$addMarkerObserver()
      return(NULL)
    },
    
    insertUIControllerMap = function(){
      jQuerySelector = paste0("#",GLOBALlayerControl)
      insertUI(
        selector = jQuerySelector,
        where = "beforeEnd",
        ui = self$getUIcontrollerMap(),
        immediate = T
      )
    },
    
    ### same as Categorical and Hierarchical
    getDescription = function(){
      bool <- self$spatialPolygon$isSelected
      selected <- as.character(self$spatialPolygon$label)[bool]
      namesChosen <- selected
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
      description <- paste0(lengthChosen, " ", GLOBALvaleursselected," (",
                            namesChosen, ")")
      predicateLabel <- self$getPredicateLabel()
      lipredicate <- shiny::tags$li(predicateLabel, class= GLOBALliPredicateLabelClass,
                                    shiny::tags$p(description))
      return(lipredicate)
    },
    
    getXMLpredicateNode = function(){
      tempQuery <- XMLSearchQuery$new()
      bool <- self$spatialPolygon@data$isSelected
      namesChosen <- as.character(self$spatialPolygon@data$value[bool])
      if (is.null(namesChosen) || length(namesChosen) == 0 || namesChosen == ""){
        return(NULL)
      }
      predicateNode <- tempQuery$makePredicateNode(predicateClass = "factor",
                                                   predicateType = self$predicateName,
                                                   values = namesChosen)
      return(predicateNode)
    },
    
    getEventsSelected = function(){
      bool <- self$spatialPolygon$isSelected
      values <- as.character(self$spatialPolygon$value[bool])
      bool <- self$dataFrame$value %in% values
      events <- as.character(self$dataFrame$event[bool])
      return(events)
    },
    
    addSpatialPolygon = function(){
      addSpatialPolygon_ <- function(spatialPolygon){
        weight <- rep(1,nrow(spatialPolygon))
        bool <- spatialPolygon$isSelected
        weight[bool] <- 4
        leafletProxy(GLOBALmapId) %>%
          addPolygons(data = spatialPolygon,
                      popup= ~popupLabel,
                      label= ~label, 
                      labelOptions = labelOptions(direction = 'auto'),
                      stroke=T,opacity=1,weight=weight,
                      fillColor= ~color,
                      layerId = ~layerId,
                      group = self$eventName,
                      highlightOptions = highlightOptions(
                        color='#00ff00',bringToFront = T, sendToBack=T)
          )  %>%
          addLegend(layerId="uniqueLegend",
                    position = "bottomleft", pal = self$pal, values = spatialPolygon$N,
                    title = "N",
                    labFormat = labelFormat(prefix = ""),
                    opacity = 1, group = self$eventName
          )
      }
      staticLogger$info("\t FilterSpatialPolygon : adding Spatial Layer")
      addSpatialPolygon_(self$spatialPolygon)
      ## different icons for selected and unselected
      # selectedDf <- subset (self$polygonCoordinate, isSelected == T)
      # newIcon <- private$selectedIcone()
      # if (nrow(selectedDf) != 0){
      #   addMarker_(selectedDf, newIcon)
      # }
      # unselectedDf <- subset (self$polygonCoordinate, isSelected == F)
      # newIcon <- private$unSelectedIcone()
      # if (nrow(unselectedDf) != 0){
      #   addMarker_(unselectedDf, newIcon)
      # }
    },
    
    updateSelectizeChoices = function(){
      staticLogger$info("\t FilterSpatialPolygon : updating Selectize Choices")
      choices <- as.character(self$spatialPolygon$label)
      bool <- self$spatialPolygon$isSelected
      selected <- self$spatialPolygon$label[bool]
      shiny::updateSelectizeInput(session,
                                  inputId = self$getSelectizeChoicesId(),
                                  choices = choices,
                                  selected = selected,
                                  server = T)
      self$contextEnv$instanceSelection$filterHasChanged()
    },
    
    ## UI to add to control this filter
    getUIcontrollerMap = function(){
      ui <- div(id=self$getUIcontrollerMapId(),
                shiny::selectizeInput(inputId = self$getSelectizeChoicesId(),
                                      label="Spatial choices :",
                                      choices = NULL,
                                      selected = NULL,
                                      multiple = T,
                                      width = "100%",
                                      options = list(hideSelected = T,
                                                     plugins=list('remove_button')))
                )
    },
    
    addSelectizeChoicesObserver = function(){
      self$selectizeChoicesObserver <- observeEvent(input[[self$getSelectizeChoicesId()]],{
        if (self$boolUpdating == T){ ## when updating, it reset to 0 first : this if captures this reset
          self$boolUpdating <- F
          return(NULL)
        }
        staticLogger$info("\t FilterSpatialPolygon : Selectize Choices change")
        bool <- self$spatialPolygon$isSelected
        choices <- as.character(self$spatialPolygon$label[bool])
        vector1 <- choices
        vector2 <- input[[self$getSelectizeChoicesId()]]
        staticLogger$info("\t \t previous choices : ",vector1)
        staticLogger$info("\t \t new choices : ",vector2)
        diffChoice <- union(setdiff(vector1, vector2), setdiff(vector2, vector1))
        staticLogger$info("\t \t diffChoice : ",diffChoice)
        if (!is.null(diffChoice) && length(diffChoice) == 1){
          bool <- self$spatialPolygon$label == diffChoice
          isSelected <- self$spatialPolygon$isSelected[bool]
          self$spatialPolygon$isSelected[bool] <- !isSelected ## inversing the choice
          markerId <- self$spatialPolygon$layerId[bool]
          staticLogger$info("\t \t markerId : ", markerId , " changed")
          self$reMakeMarker(markerId)
          self$contextEnv$instanceSelection$filterHasChanged()
        } else {
          staticLogger$info("\t \t null diffChoice : ")
        }
        return(NULL)
      },ignoreNULL = F,ignoreInit = T)
    },
    
    reMakeMarker = function(markerId){
      staticLogger$info("\t \t remaking : ", markerId,"...")
      line <- subset (self$spatialPolygon, layerId == markerId)
      if (line@data$isSelected){
        staticLogger$info("\t \t ", markerId, " new selected Shape")
        weight = 4
      } else {
        staticLogger$info("\t \t ", markerId, " new unselected Shape")
        weight = 1
      }
      leafletProxy(GLOBALmapId) %>% removeMarker(layerId = markerId)
      leafletProxy(GLOBALmapId) %>%
        addPolygons(data = line,
                    popup= ~popupLabel,
                    label= ~label, 
                    labelOptions = labelOptions(direction = 'auto'),
                    stroke=T,opacity=1,weight = weight,
                    color= ~color,
                    layerId = ~layerId,
                    group = self$eventName,
                    highlightOptions = highlightOptions(
                      color='#00ff00',bringToFront = T, sendToBack=T))
    },
    
    removeMarkerLayer = function(markerId = NULL){
      ### if is null markerId : remove all markerId
      staticLogger$info("\t \t ", "removing markerId : ", markerId)
      if (is.null(markerId)){
        leafletProxy(GLOBALmapId) %>% removeMarker(layerId = self$spatialPolygon$layerId)
        leafletProxy(GLOBALmapId) %>% clearGroup(group=self$eventName)
      } else {
        leafletProxy(GLOBALmapId) %>% removeMarker(layerId = markerId)
      }
    },
    
    addMarkerObserver = function(){
      if(!is.null(self$markerObserver)){
        self$markerObserver$destroy()
      }
      markerInput <- paste0(GLOBALmapId, "_shape_click")
      self$markerObserver <- observeEvent(input[[markerInput]],{
        markerId <- input[[markerInput]]$id
        cat(markerId,"clicked \n")
        if (markerId %in% self$spatialPolygon$layerId){
          bool <- self$spatialPolygon$layerId == markerId
          self$spatialPolygon$isSelected[bool] <- !self$spatialPolygon$isSelected[bool]
          self$reMakeMarker(markerId)
          self$boolUpdating <- T
          self$updateSelectizeChoices()
          return(NULL)
        } else {
          return(NULL)
        }
      })
    },
    
    destroy = function(){
      staticLogger$info("Destroying FilterSpatialPolygon ", self$eventName)
      staticLogger$info("\t Destroying selectizeChoicesObserver ")
      if (!is.null(self$selectizeChoicesObserver)){
        self$selectizeChoicesObserver$destroy()
        staticLogger$info("\t Done ")
      }
      
      staticLogger$info("\t Removing UI Controller")
      self$removeUIcontrollerMap()
      
      staticLogger$info("\t Removing UISeeMap")
      self$removeUIseeMap()
      
      staticLogger$info("\t Removing Markers")
      self$removeMarkerLayer()
      
      staticLogger$info("\t Removing Filter from mapObject")
      GLOBALmapObject$removeSpatialFilter(self$eventName)
      
      staticLogger$info("End Destroying FilterSpatialPolygon ", self$eventName)
    },
    
    removeUIcontrollerMap = function(){
      jQuerySelector=paste0("#",self$getUIcontrollerMapId())
      removeUI(
        selector=jQuerySelector
      )
    },
    
    removeUIseeMap = function() {
      jQuerySelector=paste0("#",self$getUIseeMapId())
      removeUI(
        selector=jQuerySelector
      )
    },
    
    insertUIseeMap = function(){
      ui <- shiny::actionButton(inputId = self$getUIseeMapId(),
                                label = GLOBALvoirlacarte 
                                )
      jQuerySelector = paste0("#",self$parentId)
      insertUI(selector = jQuerySelector,
               where = self$where,
               ui = ui)
    },
    
    getUIseeMapId = function(){
      return(paste0("seeMap",self$eventName,self$parentId))
    }, 
    
    getUIcontrollerMapId = function(){
      return(paste0("UIcontrollerId",self$eventName))
    },
    
    getSelectizeChoicesId = function(){
      return(paste0("selectizeChoicesId",self$eventName))
    },
    
    getRadioButtonMarkerId = function(){
      return(paste0("radioButtonMarkerId",self$eventName))
    }
  ),
  
  private = list(
    checkpolygonCoordinate = function(polygonCoordinate){
      bool <- c("value","layerId","shapeFile","N") %in% colnames(polygonCoordinate)
      if (!all(bool)){
        staticLogger$error("Unfound colnames in spatialDataPoint polygonCoordinate : ",
                           c("value","layerId","shapeFile","N")[bool])
        stop("")
      }
    }
    #selectedColor = "green",
    #unSelectedColor = "red"
  )
)

