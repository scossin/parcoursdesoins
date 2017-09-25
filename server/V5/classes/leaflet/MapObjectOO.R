MapObject <- R6::R6Class(
  "MapObject",
  
  public = list(
    currentProvider = "OpenStreetMap",
    spatialFilterList = list(),
    
    initialize = function(){
      self$renderMap()
      self$addSelectizeProvider()
      self$addObserverSelectizeProvider()
      self$addRadioButtonChoice()
      self$hideShowUIControllerObserver()
    },
    
    renderMap = function(){
      output[[GLOBALmapId]] <- leaflet::renderLeaflet({
        leaflet() %>% addProviderTiles(providers[[self$currentProvider]],
                                       layerId = self$getProviderLayerId()
                                      ) %>% 
          setView(lng = private$lngCenterFrance,
                  lat = private$latCenterFrance, 
                  zoom = private$initialZoom)
      })
    },
    
    addObserverSelectizeProvider = function(){
      observeEvent(input[[self$getSelectizeProviderId()]],{
        providerSelection <- input[[self$getSelectizeProviderId()]]
        if (providerSelection == self$currentProvider){
          return(NULL)
        }
        self$currentProvider <- providerSelection
        leafletProxy(GLOBALmapId) %>% removeTiles(layerId = self$getProviderLayerId())
        leafletProxy(GLOBALmapId) %>% addProviderTiles(
          providers[[self$currentProvider]],
          layerId = self$getProviderLayerId())
      })
    },
    
    updateLayerControl = function(){
      staticLogger$info("\t Updating Layer Control")
      namesList <- names(self$spatialFilterList)
      if (length(namesList) == 0){
        leafletProxy(GLOBALmapId) %>% 
          removeLayersControl()
      } else {
        leafletProxy(GLOBALmapId) %>% 
          addLayersControl(overlayGroups = namesList,
                           options = layersControlOptions((collapsed=T)))
      }
    },
    
    addSpatialFilter = function(spatialFilter){
      staticLogger$info("\t Adding spatialFilter to MapObject")
      lengthList <- length(self$spatialFilterList)
      namesList <- names(self$spatialFilterList)
      self$spatialFilterList[[lengthList + 1 ]] <- spatialFilter
      namesList <- append(namesList, spatialFilter$eventName)
      names(self$spatialFilterList) <- namesList
      self$updateRadioButtonChoice()
      self$updateLayerControl()
      return(NULL)
    },
    
    removeSpatialFilter = function(eventName){
      staticLogger$info("\t Removing SpatialFilter from MapObject")
      self$spatialFilterList[[eventName]] <- NULL
      self$updateRadioButtonChoice()
      self$updateLayerControl()
    },
    
    hideShowUIControllerObserver = function(){
      observeEvent(input[[self$getRadioButtonChoiceId()]], {
        choice <- input[[self$getRadioButtonChoiceId()]]
        cat ("new choice ! ", choice, "\n")
        if (choice == "aucun"){
          return(NULL)
        }
        for (spatialFilterName in names(self$spatialFilterList)){
          spatialFilter <- self$spatialFilterList[[spatialFilterName]]
          UIcontrollerId <- spatialFilter$getUIcontrollerMapId()
          if (spatialFilterName == choice){
            cat("showing ...")
            self$showId(UIcontrollerId)
          } else {
            cat("hidding ...")
            self$hideId(UIcontrollerId)
          }
        }
      })
    },
    
    showId = function(objectId){
      #staticLogger$info("Sending Js function to hide ",self$getHideShowId())
      session$sendCustomMessage(type = "displayShowId",
                                message = list(objectId = objectId))
    },
    hideId = function(objectId){
      #staticLogger$info("Sending Js function to show ",self$getHideShowId())
      session$sendCustomMessage(type = "displayHideId",
                                message = list(objectId = objectId))
    }, 
    
    updateRadioButtonChoice = function(){
      choices <- names(self$spatialFilterList)
      if (length(choices) == 0){
        choices <- "aucun"
      }
      lastChoice <- length(choices)
      shinyWidgets::updateAwesomeRadio(session = session,
                                      inputId = self$getRadioButtonChoiceId(),
                                       label="",
                                       choices= choices,
                                       selected = choices[lastChoice],
                                       inline = T)
      return(NULL)
    },
    
    addRadioButtonChoice = function(){
      ui <- shinyWidgets::awesomeRadio(inputId = self$getRadioButtonChoiceId(),
                                       label="",
                                       choices= "aucun",selected = "aucun",inline = T
                                       )
      jQuerySelector = paste0("#",GLOBALlayerControl)
      insertUI(selector = jQuerySelector,
               where = "beforeEnd",ui = ui,
              immediate = T
                )
    },
    
    getRadioButtonChoiceId = function(){
      return("radioButtonChoiceId")
    },
    
    addSelectizeProvider = function(){
      ui <- shiny::selectizeInput(inputId = self$getSelectizeProviderId(),
                            label="Tile",
                            choices = names(providers),
                            selected = self$currentProvider,
                            multiple = F)
      jQuerySelector = paste0("#",GLOBALmapObjectControls)
      insertUI(selector = jQuerySelector,
               where = "beforeEnd",
              ui = ui)
      return(NULL)
    },
    
    getSelectizeProviderId = function(){
      return("mapObjectSelectizeProvider")
    },
    
    getProviderLayerId = function(){
      return("providerLayerId")
    }
  ), 
  private = list(
    lngCenterFrance = 2.2137,
    latCenterFrance = 46.2276,
    initialZoom = 6
  )
)

