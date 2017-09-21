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
    
    initialize = function(contextEnv, predicateName, dataFrame, parentId, where,pointsCoordinate){
      staticLogger$info("Creating a new FilterSpatialPoint object")
      super$initialize(contextEnv, predicateName, dataFrame, parentId, where)
      eventName <- paste0("event",contextEnv$eventNumber, "-",self$predicateName)
      self$pointsCoordinate <- pointsCoordinate
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
    
    setPointsCoordinate = function(){
      private$checkPointsCoordinate(self$pointsCoordinate)
      self$pointsCoordinate$layerId <- paste0(self$pointsCoordinate$lat, self$pointsCoordinate$long)
      self$pointsCoordinate$layerIdCircle <- paste0(self$pointsCoordinate$layerId,"circle")
      self$pointsCoordinate$isSelected <- F
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
    
    addMarkerLayer = function(){
      addMarker_ <- function(pointsCoordinate, newIcone){
        leafletProxy(GLOBALmapId) %>%
          addAwesomeMarkers(
            lng = pointsCoordinate$long, 
            lat = pointsCoordinate$lat,
            layerId = pointsCoordinate$layerId,
            label = pointsCoordinate$label,
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
                                    label="Add circles",
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
      leafletProxy(GLOBALmapId) %>%
        addAwesomeMarkers(icon = newIcon,
                          lng = line$long,
                          lat = line$lat,
                          label = line$label,
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
    
    addCircleObserver = function(){
      self$circleObserver <- shiny::observeEvent(input[[self$getRadioButtonMarkerId()]], {
        if (!input[[self$getRadioButtonMarkerId()]]){
          staticLogger$info("\t \t ", "Removing circle marker: ", self$getRadioButtonMarkerId())
          leafletProxy(GLOBALmapId) %>%
            removeMarker(layerId = self$pointsCoordinate$layerIdCircle)
        } else {
          staticLogger$info("\t \t ", "Adding circle marker: ", self$getRadioButtonMarkerId())
          radius <- 10 * (self$pointsCoordinate$N / max(self$pointsCoordinate$N))
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
                                label = "See Map" 
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
      bool <- c("lat","long","label","N") %in% colnames(pointsCoordinate)
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

