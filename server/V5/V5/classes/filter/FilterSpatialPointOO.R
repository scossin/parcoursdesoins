FilterSpatialPoint <- R6::R6Class(
  "FilterSpatialPoint",
  inherit=Filter,
  
  public = list(
    eventName = character(),
    pointsCoordinate = data.frame(),
    selectizeChoicesObserver = NULL,
    selectizeIconObserver = NULL,
    markerObserver = NULL,
    circleObserver = NULL,
    
    boolUpdating = F, ## when updating SelectizeInput : first NULL then Selected => first NULL is boolUpdating
    
    initialize = function(contextEnv, predicateName, dataFrame, parentId, where){
      staticLogger$info("Creating a new FilterSpatialPoint object")
      super$initialize(contextEnv, predicateName, dataFrame, parentId, where)
      eventName <- paste0("event",contextEnv$eventNumber, "-",self$predicateName)
      self$setPointsCoordinate()
      self$eventName <- eventName
      self$insertUIseeMap()
      self$insertUIControllerMap()
      self$addSpatialLayer()
      self$addCircleObserver()
      self$addSelectizeIconObserver()
      self$updateSelectizeChoices()
      self$addSelectizeChoicesObserver()
      staticLogger$info("FilterSpatialPoint object created")
    },
    
    updateDataFrame = function(){
      staticLogger$info("updateDataFrame of FilterSpatialPoint")
      eventType <- self$contextEnv$instanceSelection$className
      terminologyName <- self$contextEnv$instanceSelection$terminology$terminologyName
      predicateName <- self$predicateName
      contextEvents <- self$contextEnv$instanceSelection$getContextEvents()
      self$dataFrame <- staticFilterCreator$getDataFrame(terminologyName, eventType, 
                                                         contextEvents, 
                                                         predicateName)
      ## previous selection : 
      bool <- self$pointsCoordinate$isSelected
      values <- as.character(self$pointsCoordinate$value[bool])
      
      self$removeMarkerLayer() ## first ! because it depends on pointsCoordinates
      self$removeCircleMarker()
      
      self$setPointsCoordinate()
      
      ## add previous selection
      bool <- self$pointsCoordinate$value %in% values
      self$pointsCoordinate$isSelected <- bool
      
     
      self$addMarkerLayer()
      
      self$updateSelectizeChoices()
      
      self$contextEnv$instanceSelection$filterHasChanged()
    },
    
    setPointsCoordinate = function(){
      pointsCoordinate <- table(self$dataFrame$value)
      pointsCoordinate <- data.frame(event = names(pointsCoordinate), 
                                     N = as.numeric(pointsCoordinate))
      pointsCoordinate$context <- ""
      terminologyName <- self$contextEnv$instanceSelection$terminology$terminologyName
      expectedValue <- self$contextEnv$instanceSelection$terminology$getPredicateDescription(self$predicateName)$value
      
      for (spatialPredicate in c("lat","long","label")){
        addColumn <- staticFilterCreator$getDataFrame(terminologyName = terminologyName, 
                                       eventType = expectedValue, 
                                       contextEvents = pointsCoordinate, 
                                       predicateName = spatialPredicate)
        colnames(addColumn) <- c("event",spatialPredicate)
        pointsCoordinate <- merge (pointsCoordinate, addColumn, by="event")
      }
      numCol <- which(colnames(pointsCoordinate) == "event")
      colnames(pointsCoordinate)[numCol] <- "value"
      private$checkPointsCoordinate(pointsCoordinate)
      pointsCoordinate$layerId <- paste0(pointsCoordinate$lat, pointsCoordinate$long)
      pointsCoordinate$layerIdCircle <- paste0(pointsCoordinate$layerId,"circle")
      pointsCoordinate$isSelected <- F
      self$pointsCoordinate <- pointsCoordinate
    },
    
    addSpatialLayer = function(){
      self$addMarkerLayer()
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
      choices <- as.character(self$pointsCoordinate$label)
      bool <- self$pointsCoordinate$isSelected
      selected <- self$pointsCoordinate$label[bool]
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
      bool <- self$pointsCoordinate$isSelected
      namesChosen <- as.character(self$pointsCoordinate$value[bool])
      if (is.null(namesChosen) || length(namesChosen) == 0 || namesChosen == ""){
        return(NULL)
      }
      predicateNode <- tempQuery$makePredicateNode(predicateClass = "factor",
                                                   predicateType = self$predicateName,
                                                   values = namesChosen)
      return(predicateNode)
    },
    
    getEventsSelected = function(){
      bool <- self$pointsCoordinate$isSelected
      values <- as.character(self$pointsCoordinate$value[bool])
      bool <- self$dataFrame$value %in% values
      events <- as.character(self$dataFrame$event[bool])
      return(events)
    },
    
    addMarkerLayer = function(){
      addMarker_ <- function(pointsCoordinate, newIcone){
        pointsCoordinate$popupLabel <- paste0(pointsCoordinate$label, " (",pointsCoordinate$N,")")
        leafletProxy(GLOBALmapId) %>%
          addAwesomeMarkers(
            lng = pointsCoordinate$long, 
            lat = pointsCoordinate$lat,
            layerId = pointsCoordinate$layerId,
            label = pointsCoordinate$popupLabel,
            popup = pointsCoordinate$popupLabel,
            group = self$eventName,
            icon = newIcon)
      }
      staticLogger$info("\t FilterSpatialPoint : adding Spatial Layer")
      ## different icons for selected and unselected
      selectedDf <- subset (self$pointsCoordinate, isSelected == T)
      newIcon <- private$selectedIcone()
      if (nrow(selectedDf) != 0){
        addMarker_(selectedDf, newIcon)
      }
      
      unselectedDf <- subset (self$pointsCoordinate, isSelected == F)
      newIcon <- private$unSelectedIcone()
      if (nrow(unselectedDf) != 0){
        addMarker_(unselectedDf, newIcon)
      }
    },
    
    updateSelectizeChoices = function(){
      staticLogger$info("\t FilterSpatialPoint : updating Selectize Choices")
      choices <- as.character(self$pointsCoordinate$label)
      bool <- self$pointsCoordinate$isSelected
      selected <- self$pointsCoordinate$label[bool]
      shiny::updateSelectizeInput(session,
                                  inputId = self$getSelectizeChoicesId(),
                                  choices = choices,
                                  selected = selected,
                                  server = T)
      self$contextEnv$instanceSelection$filterHasChanged()
    },
    
    ## UI to add to control this Filter
    getUIcontrollerMap = function(){
      ui <- div(id=self$getUIcontrollerMapId(),
                shiny::selectizeInput(inputId = self$getSelectizeChoicesId(),
                                      label="Spatial choices :",
                                      choices = NULL,
                                      selected = NULL,
                                      multiple = T,
                                      width = "100%",
                                      options = list(hideSelected = T,
                                                     plugins=list('remove_button'))),
                shiny::selectizeInput(inputId = self$getSelectizeIconShapeId(),
                                      label="Icon choices :",
                                      choices = private$iconeShapes,
                                      selected = private$iconeShape,
                                      multiple = F,
                                      width = "100%"),
                shinyWidgets::awesomeCheckbox(inputId = self$getRadioButtonMarkerId(),
                                    label=GLOBALaddCircles,
                                    value = F
                                    )
                )
    },
    
    addSelectizeChoicesObserver = function(){
      self$selectizeChoicesObserver <- observeEvent(input[[self$getSelectizeChoicesId()]],{
        if (self$boolUpdating == T){ ## when updating, it reset to 0 first : this if captures this reset
          self$boolUpdating <- F
          return(NULL)
        }
        staticLogger$info("\t FilterSpatialPoint : Selectize Choices change")
        bool <- self$pointsCoordinate$isSelected
        choices <- as.character(self$pointsCoordinate$label[bool])
        vector1 <- choices
        vector2 <- input[[self$getSelectizeChoicesId()]]
        staticLogger$info("\t \t previous choices : ",vector1)
        staticLogger$info("\t \t new choices : ",vector2)
        diffChoice <- union(setdiff(vector1, vector2), setdiff(vector2, vector1))
        staticLogger$info("\t \t diffChoice : ",diffChoice)
        if (!is.null(diffChoice) && length(diffChoice) == 1){
          bool <- self$pointsCoordinate$label == diffChoice
          isSelected <- self$pointsCoordinate$isSelected[bool]
          self$pointsCoordinate$isSelected[bool] <- !isSelected ## inversing the choice
          markerId <- self$pointsCoordinate$layerId[bool]
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
      line <- subset (self$pointsCoordinate, layerId == markerId)
      newIcon <- NULL
      if (line$isSelected){
        staticLogger$info("\t \t ", markerId, " new selected Icon")
        newIcon <- private$selectedIcone()
      } else {
        staticLogger$info("\t \t ", markerId, " new unselected Icon")
        newIcon <- private$unSelectedIcone()
      }
      leafletProxy(GLOBALmapId) %>% removeMarker(layerId = markerId)
      line$popupLabel <- paste0(line$label, " (",line$N,")")
      leafletProxy(GLOBALmapId) %>%
        addAwesomeMarkers(icon = newIcon,
                          lng = line$long,
                          lat = line$lat,
                          label = line$popupLabel,
                          layerId = line$layerId,
                          group = self$eventName)
    },
    
    removeMarkerLayer = function(markerId = NULL){
      ### if is null markerId : remove all markerId
      staticLogger$info("\t \t ", "removing markerId : ", markerId)
      if (is.null(markerId)){
        leafletProxy(GLOBALmapId) %>% removeMarker(layerId = self$pointsCoordinate$layerId)
      } else {
        leafletProxy(GLOBALmapId) %>% removeMarker(layerId = markerId)
      }
    },
    
    addSelectizeIconObserver = function(){
      self$selectizeIconObserver <- observeEvent(input[[self$getSelectizeIconShapeId()]],{
        newIconShape <- input[[self$getSelectizeIconShapeId()]]
        staticLogger$info("\t \t ", "new iconeShape : ", newIconShape, " for ", self$getSelectizeIconShapeId() )
        private$iconeShape <- newIconShape
        self$removeMarkerLayer()
        self$addMarkerLayer()
      })
    },
    
    addMarkerObserver = function(){
      if(!is.null(self$markerObserver)){
        self$markerObserver$destroy()
      }
      markerInput <- paste0(GLOBALmapId, "_marker_click")
      self$markerObserver <- observeEvent(input[[markerInput]],{
        markerId <- input[[markerInput]]$id
        cat(markerId,"clicked \n")
        if (markerId %in% self$pointsCoordinate$layerId){
          bool <- self$pointsCoordinate$layerId == markerId
          self$pointsCoordinate$isSelected[bool] <- !self$pointsCoordinate$isSelected[bool]
          self$reMakeMarker(markerId)
          self$boolUpdating <- T
          self$updateSelectizeChoices()
          return(NULL)
        } else {
          return(NULL)
        }
        
      })
    },
    
    removeCircleMarker = function(){
      leafletProxy(GLOBALmapId) %>%
        removeMarker(layerId = self$pointsCoordinate$layerIdCircle)
    },
    
    addCircleObserver = function(){
      self$circleObserver <- shiny::observeEvent(input[[self$getRadioButtonMarkerId()]], {
        if (!input[[self$getRadioButtonMarkerId()]]){
          staticLogger$info("\t \t ", "Removing circle marker: ", self$getRadioButtonMarkerId())
          self$removeCircleMarker()
        } else {
          staticLogger$info("\t \t ", "Adding circle marker: ", self$getRadioButtonMarkerId())
          radius <- 20 * (self$pointsCoordinate$N / max(self$pointsCoordinate$N))
          leafletProxy(GLOBALmapId) %>%
            addCircleMarkers(lng = self$pointsCoordinate$long,
                             lat = self$pointsCoordinate$lat,
                             label = paste0(radius),
                             layerId = self$pointsCoordinate$layerIdCircle,
                             radius = radius,
                             fillOpacity = T,
                             group = self$eventName)
        }
      })
    },
    
    destroy = function(){
      staticLogger$info("Destroying FilterSpatialPoint ", self$eventName)
      staticLogger$info("\t Destroying selectizeChoicesObserver ")
      if (!is.null(self$selectizeChoicesObserver)){
        self$selectizeChoicesObserver$destroy()
        staticLogger$info("\t Done ")
      }
      staticLogger$info("\t Destroying selectizeIconObserver ")
      if (!is.null(self$selectizeIconObserver)){
        self$selectizeIconObserver$destroy()
        staticLogger$info("\t Done ")
      }
      staticLogger$info("\t Destroying markerObserver ")
      if (!is.null(self$markerObserver)){
        self$markerObserver$destroy()
        staticLogger$info("\t Done ")
      }
      staticLogger$info("\t Destroying circleObserver ")
      if (!is.null(self$circleObserver)){
        self$circleObserver$destroy()
        staticLogger$info("\t Done ")
      }
      
      staticLogger$info("\t Removing UI Controller")
      self$removeUIcontrollerMap()
      
      staticLogger$info("\t Removing UISeeMap")
      self$removeUIseeMap()
      
      staticLogger$info("\t Removing Circle Markers")
      self$removeCircleMarker()
      
      staticLogger$info("\t Removing Markers")
      self$removeMarkerLayer()
      
      staticLogger$info("\t Removing Filter from mapObject")
      GLOBALmapObject$removeSpatialFilter(self$eventName)
      
      staticLogger$info("End Destroying FilterSpatialPoint ", self$eventName)
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
                                label = GLOBALvoirlacarte,
                                onclick="$(\"[data-value='Carte']\").click()"
                                )
      jQuerySelector = paste0("#",self$parentId)
      insertUI(selector = jQuerySelector,
               where = self$where,
               ui = ui)
    },
    
    getUIseeMapId = function(){
      return(paste0("seeMap",self$eventName,self$parentId))
    }, 
    
    getSelectizeIconShapeId = function(){
      return(paste0("selectizeIconShape",self$eventName))
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
    checkPointsCoordinate = function(pointsCoordinate){
      print(self$dataFrame)
      print(pointsCoordinate)
      bool <- c("value","lat","long","label","N") %in% colnames(pointsCoordinate)
      if (!bool){
        staticLogger$error(colnames(pointsCoordinate))
        stop("Unfound colnames in spatialDataPoint pointsCoordinate")
      }
    },
    iconeShapes = c("h-square","ambulance","stethoscope","user-md","medkit","heart",
                    "plus-square","heart-o"),
    iconeShape = "h-square",
    selectedColor = "green",
    selectedIcone = function(){
      icon <- leaflet::awesomeIcons(icon = private$iconeShape, 
                                          library = "fa", 
                                          markerColor = private$selectedColor,
                                          iconColor = "white", 
                                          spin = F , 
                                          extraClasses = NULL,
                                          squareMarker = FALSE, 
                                          iconRotate = 0, 
                                          fontFamily = "monospace",
                                          text = NULL)
      return(icon)
      },
    unSelectedColor = "red",
    unSelectedIcone = function(){
      icon <- leaflet::awesomeIcons(icon = private$iconeShape, 
                                    library = "fa", 
                                    markerColor = private$unSelectedColor,
                                    iconColor = "white", 
                                    spin =F , 
                                    extraClasses = NULL,
                                    squareMarker = FALSE, 
                                    iconRotate = 0, 
                                    fontFamily = "monospace",
                                    text = NULL)
      return(icon)
      }
  )
)
