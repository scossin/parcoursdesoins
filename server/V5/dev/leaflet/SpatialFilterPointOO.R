SpatialFilterPoint <- R6::R6Class(
  "SpatialFilterPoint",
  
  public = list(
    eventName = character(),
    dataFrame = data.frame(),
    boolUpdating = F, ## when updating SelectizeInput : first NULL then Selected => first NULL is boolUpdating
    
    initialize = function(eventName, dataFrame){
      self$eventName <- eventName
      self$dataFrame <- dataFrame
      self$dataFrame$layerId <- paste0(dataFrame$lat, dataFrame$long)
      self$dataFrame$layerIdCircle <- paste0(self$dataFrame$layerId,"circle")
      self$dataFrame$isSelected <- F
      self$insertUIController()
      self$addSpatialLayer()
      cat ("new SpatialFilterPoint !")
      self$addObserverCircle()
      self$addSelectizeIconObserver()
      self$updateSelectizeChoices()
      self$addSelectizeChoicesObserver()
    },
    
    addSpatialLayer = function(){
      self$addMarkerLayer()
      self$addMarkerObserver()
      return(NULL)
    },
    
    removeMarkerLayer = function(markerId = NULL){
      if (is.null(markerId)){
        leafletProxy(GLOBALmapId) %>% removeMarker(layerId = self$dataFrame$layerId)
      } else {
        leafletProxy(GLOBALmapId) %>% removeMarker(layerId = markerId)
      }
    },
    
    addMarkerLayer = function(){
      # iconsList <- lapply (self$dataFrame$isSelected, function(x){
      #   if (x){
      #     return(private$selectedIcone())
      #   } else {
      #     return(private$unSelectedIcone())
      #   }})
      addMarker <- function(dataFrame, newIcone){
        leafletProxy(GLOBALmapId) %>%
          addAwesomeMarkers(
            lng = dataFrame$long, 
            lat = dataFrame$lat,
            layerId = dataFrame$layerId,
            label = dataFrame$label,
            group = self$eventName,
            icon = newIcon)
      }
      cat("adding Spatial Layer")
      selectedDf <- subset (self$dataFrame, isSelected == T)
      newIcon <- private$selectedIcone()
      if (nrow(selectedDf) != 0){
        addMarker(selectedDf, newIcon)
      }
      unselectedDf <- subset (self$dataFrame, isSelected == F)
      newIcon <- private$unSelectedIcone()
      if (nrow(unselectedDf) != 0){
        addMarker(unselectedDf, newIcon)
      }
    },
    
    updateSelectizeChoices = function(){
      cat("updating Selectize Choices \n")
      choices <- as.character(self$dataFrame$label)
      bool <- self$dataFrame$isSelected
      selected <- self$dataFrame$label[bool]
      shiny::updateSelectizeInput(session,
                                  inputId = self$getSelectizeChoicesId(),
                                  choices = choices,
                                  selected = selected,
                                  server = T
                                  )
    },
    
    getUIcontroller = function(){
      ui <- div(id=self$getUIcontrollerId(),
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
                                    label="circle",
                                    value = F
                                    )
                )
    },
    
    addSelectizeChoicesObserver = function(){
      observeEvent(input[[self$getSelectizeChoicesId()]],{
        if (self$boolUpdating == T){
          self$boolUpdating <- F
          return(NULL)
        }
        cat("Selectize Choice change ! \n")
        bool <- self$dataFrame$isSelected
        choices <- as.character(self$dataFrame$label[bool])
        vector1 <- choices
        vector2 <- input[[self$getSelectizeChoicesId()]]
        cat("vector1 : ",vector1,"\n")
        cat("vector2 : ",vector2,"\n")
        diffChoice <- union(setdiff(vector1, vector2), setdiff(vector2, vector1))
        cat("diffChoice : ",diffChoice,"\n")
        if (!is.null(diffChoice) && length(diffChoice) == 1){
          cat("diffChoice : ", diffChoice, "\n")
          bool <- self$dataFrame$label == diffChoice
          isSelected <- self$dataFrame$isSelected[bool]
          self$dataFrame$isSelected[bool] <- !isSelected
          markerId <- self$dataFrame$layerId[bool]
          cat("markerId : ", markerId, "\n")
          self$reMakeMarker(markerId)
        }
        return(NULL)
      },ignoreNULL = F,ignoreInit = T)
    },
    
    addSelectizeIconObserver = function(){
      observeEvent(input[[self$getSelectizeIconShapeId()]],{
        newIconShape <- input[[self$getSelectizeIconShapeId()]]
        private$iconeShape <- newIconShape
        self$removeMarkerLayer()
        self$addMarkerLayer()
      })
    },
    
    getSelectizeIconShapeId = function(){
      return(paste0("selectizeIconShape",self$eventName))
    },
    
    addObserverCircle = function(){
      shiny::observeEvent(input[[self$getRadioButtonMarkerId()]], {
        if (!input[[self$getRadioButtonMarkerId()]]){
          cat("removing circle marker \n")
          leafletProxy(GLOBALmapId) %>%
            removeMarker(layerId = self$dataFrame$layerIdCircle)
        } else {
          cat("adding circle marker \n")
          radius <- 10 * (self$dataFrame$N / max(self$dataFrame$N))
          leafletProxy(GLOBALmapId) %>%
            addCircleMarkers(lng = self$dataFrame$long,
                             lat = self$dataFrame$lat,
                             label = paste0(radius),
                             layerId = self$dataFrame$layerIdCircle,
                             radius = radius,
                             fillOpacity = T,
                             group = self$eventName)
        }
      })
    },
    
    insertUIController = function(){
      jQuerySelector = paste0("#",GLOBALlayerControl)
      insertUI(
        selector = jQuerySelector,
        where = "beforeEnd",
        ui = self$getUIcontroller(),
        immediate = T
      )
    },
    
    getUIcontrollerId = function(){
      return(paste0("UIcontrollerId",self$eventName))
    },
    
    getSelectizeChoicesId = function(){
      return(paste0("selectizeChoicesId",self$eventName))
    },
    
    getRadioButtonMarkerId = function(){
      return(paste0("radioButtonMarkerId",self$eventName))
    },
    
    reMakeMarker = function(markerId){
      line <- subset (self$dataFrame, layerId == markerId)
      newIcon <- NULL
      if (line$isSelected){
        cat("new selected Icon \n")
        newIcon <- private$selectedIcone()
      } else {
        cat("new unselected Icon \n")
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
    
    addMarkerObserver = function(){
      markerInput <- paste0(GLOBALmapId, "_marker_click")
      observeEvent(input[[markerInput]],{
        markerId <- input[[markerInput]]$id
        cat(markerId,"clicked \n")
        if (markerId %in% self$dataFrame$layerId){
          bool <- self$dataFrame$layerId == markerId
          self$dataFrame$isSelected[bool] <- !self$dataFrame$isSelected[bool]
          self$reMakeMarker(markerId)
          self$boolUpdating <- T
          self$updateSelectizeChoices()
          return(NULL)
        } else {
          return(NULL)
        }
        
      })
    }
  ),
  
  private = list(
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

