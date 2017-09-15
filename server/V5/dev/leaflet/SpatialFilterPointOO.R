SpatialFilterPoint <- R6::R6Class(
  "SpatialFilterPoint",
  
  public = list(
    eventName = character(),
    dataFrame = data.frame(),
    
    initialize = function(eventName, dataFrame){
      self$eventName <- eventName
      dataFrame$layerId <- paste0(dataFrame$lat, dataFrame$long)
      self$dataFrame <- dataFrame
      self$dataFrame$isSelected <- T
      self$insertUIController()
      self$addSpatialLayer()
      cat ("new SpatialFilterPoint !")
    },
    
    addSpatialLayer = function(){
      # iconsList <- lapply (self$dataFrame$isSelected, function(x){
      #   if (x){
      #     return(private$selectedIcone())
      #   } else {
      #     return(private$unSelectedIcone())
      #   }})
      cat("adding Spatial Layer")
      newIcon <- private$selectedIcone()
      leafletProxy(GLOBALmapId) %>%
        addAwesomeMarkers(
                          lng = self$dataFrame$long, 
                          lat = self$dataFrame$lat,
                          layerId = self$dataFrame$layerId,
                          label = self$dataFrame$label,
                          group = self$eventName,
                          icon = newIcon)
      self$addMarkerObserver()
      return(NULL)
    },
    
    getUIcontroller = function(){
      ui <- div(id=self$getUIcontrollerId(),
                shiny::selectizeInput(inputId = self$getSelectizeChoicesId(),
                                      label="",
                                      choices = NULL,
                                      selected = NULL,
                                      multiple = T,
                                      width = "100%",
                                      options = list(hideSelected = T,
                                                     plugins=list('remove_button'))),
                
                shiny::radioButtons(inputId = self$getRadioButtonMarkerId(),
                                    label="",
                                    choices = c("marker","circle"),
                                    selected = "marker",inline = T
                                    )
                )
    },
    
    insertUIController = function(){
      jQuerySelector = paste0("#",GLOBALlayerControl)
      insertUI(
        selector = jQuerySelector,
        where = "beforeEnd",
        ui = self$getUIcontroller()
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
    
    addMarkerObserver = function(){
      markerInput <- paste0(GLOBALmapId, "_marker_click")
      observeEvent(input[[markerInput]],{
        markerId <- input[[markerInput]]$id
        cat(markerId,"clicked \n")
        if (markerId %in% self$dataFrame$layerId){
          bool <- self$dataFrame$layerId == markerId
          self$dataFrame$isSelected[bool] <- ifelse (self$dataFrame$isSelected[bool],
                                                       F,
                                                       T)
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
          return(NULL)
        } else {
          return(NULL)
        }
        
      })
    }
  ),
  
  private = list(
    iconeShape = "circle",
    selectedColor = "green",
    selectedIcone = function(){
      icon <- leaflet::awesomeIcons(icon = private$iconeShape, 
                                          library = "fa", 
                                          markerColor = "lightgray",
                                          iconColor = private$selectedColor, 
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
                                            markerColor = "lightgray",
                                            iconColor = private$unSelectedColor, 
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

