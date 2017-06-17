### leaflet: 

  output$map <- leaflet::renderLeaflet({
    #voir <- dep33@data
    couleurs <- rainbow(nrow(dep33@data))
    couleurs <- c("blue","red","orange","black","pink")
    couleurs <- sample(couleurs, nrow(dep33@data),replace = T)
    m <- leaflet(dep33)  %>%
      addPolygons(popup=as.character(dep33$libgeo), stroke=T,opacity=0.5,weight=1,color=couleurs,
                    #"grey",
                   layerId=dep33$codgeo) %>%
      addProviderTiles("Stamen.TonerLite")   %>%
      # markers UNV
      addMarkers(lng=coordinates(locEtab33UNV)[,1],
                 lat=coordinates(locEtab33UNV)[,2],
                 popup=as.character(locEtab33UNV$rs),
                 group = "UNV",layerId=locEtab33UNV$nofinesset,icon=UNVicon) %>%
      # markers SSR
      addMarkers(lng=coordinates(locEtab33SSR)[,1],
                 lat=coordinates(locEtab33SSR)[,2],
                 popup=as.character(locEtab33SSR$rs),icon=SSRicon,
                 group = "SSR",layerId=locEtab33SSR$nofinesset)
    m
  })
  
  observeEvent(input$button,{
    ### on commence par vérifier que l'event 0 existe :
    cat ("bouton leaflet afficher cliqué \n")
    event <- values[["selection0"]]$event
    if (is.null(event$get_type_selected())){
      cat ("\t event", event$get_event_number(), "aucun évènement sélectionné/validé pour le main event\n")
      return(NULL)
    }
    
    event$set_spatial()
    
    if (exists("spatial")){
      ids <- c(spatial$df_transfert_entree$id, spatial$df_transfert_sortie$id)
      remove_polylines_id("map",ids)
    }
    
    spatial <<- event$spatial
    
    ## si objet exist, faire un remove ID avant 
    
    ## appelé afficher map selon la sélection
    isolate(entree_sortie_checkbox <- input$checkbox_transfert)
    bool <- "entree" %in% entree_sortie_checkbox & nrow(spatial$df_transfert_entree) != 0
    if (bool){
      spatial$df_transfert_entree$couleurs <- "blue"
      spatial$df_transfert_entree$id <- paste0("entree",1:nrow(spatial$df_transfert_entree))
      cat ("\t", nrow(spatial$df_transfert_entree), "transfert entree à afficher \n")
      afficher_parcours("map",spatial$df_transfert_entree)
    }
    
    bool <- "sortie" %in% entree_sortie_checkbox & nrow(spatial$df_transfert_sortie) != 0
    if (bool){
      spatial$df_transfert_sortie$couleurs <- "green"
      spatial$df_transfert_sortie$id <- paste0("sortie",1:nrow(spatial$df_transfert_sortie))
      cat ("\t", nrow(spatial$df_transfert_sortie), "transfert sortie à afficher \n")
      afficher_parcours("map",spatial$df_transfert_sortie)
    }
    
    # couleurs <- c("blue","red","orange","black","pink")
  })
  
  
  ### finir ici : remove ou add id selon la sélection
  observeEvent(input$checkbox_transfert, {
    cat("checkbox_transfert cliqué \n")
    if (!exists("spatial")){
      cat("\t Spatial n'a pas été initialisé \n")
      return(NULL)
    }
    isolate(entree_sortie_checkbox <- input$checkbox_transfert)
    bool <- "entree" %in% entree_sortie_checkbox & nrow(spatial$df_transfert_entree) != 0
    if (bool){
      cat ("\t", nrow(df_transfert_entree), "transfert entree à afficher \n")
      afficher_parcours("map",df_transfert_entree)
    }
  },ignoreNULL = F)

    remove_polylines_id <- function(map, polylines_id){
      for (i in polylines_id){
        leafletProxy(map) %>%
          removeShape(layerId = i)
      }
    }
