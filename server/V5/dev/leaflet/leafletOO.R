MapObject <- R6::R6Class(
  "MapObject",
  
  public = list(
    currentProvider = "OpenStreetMap",
    spatialFilterList = list(),
    
    initialize = function(){
      self$renderMap()
      self$addSelectizeProvider()
      self$addObserverSelectizeProvider()
      self$addAddObserver()
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
    
    addAddObserver = function(){
      observeEvent(input$add, {
        if (length(self$spatialFilterList) ==0){
          dataFrame2 <- data.frame(lat=c(46,47), long = c(0,-0.1),
                                   label=c("test3","test4"))
          spatialFilter <- SpatialFilterPoint$new("event2",dataFrame2)
          self$addSpatialFilter("event2",spatialFilter)
        } else {
          dataFrame <- data.frame(lat=c(44.8672714490391,44.9), long = c(-0.617864221255729,-0.62),
                                  label=c("test1","test2"))
          spatialFilter <- SpatialFilterPoint$new("event1",dataFrame)
          self$addSpatialFilter("event1",spatialFilter)
        }
        self$updateRadioButtonChoice()
        self$updateLayerControl()
      })
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
          UIcontrollerId <- spatialFilter$getUIcontrollerId()
          if (spatialFilterName == choice){
            self$showId(UIcontrollerId)
          } else {
            self$hideId(UIcontrollerId)
          }
        }
      })
    },
    
    showId = function(objectId){
      #staticLogger$info("Sending Js function to hide ",self$getHideShowId())
      session$sendCustomMessage(type = "displayHideId",
                                message = list(objectId = objectId))
    },
    hideId = function(objectId){
      #staticLogger$info("Sending Js function to show ",self$getHideShowId())
      session$sendCustomMessage(type = "displayShowId",
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
               where = "beforeEnd",ui = ui
                )
    },
    
    getRadioButtonChoiceId = function(){
      return("radioButtonChoiceId")
    },
    
    addSpatialFilter = function(eventName, spatialFilter){
      lengthList <- length(self$spatialFilterList)
      namesList <- names(self$spatialFilterList)
      self$spatialFilterList[[lengthList + 1 ]] <- spatialFilter
      namesList <- append(namesList, eventName)
      names(self$spatialFilterList) <- namesList
      return(NULL)
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

