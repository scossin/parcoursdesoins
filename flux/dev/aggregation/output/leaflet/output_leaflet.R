### leaflet: 

  output$map <- leaflet::renderLeaflet({
    #voir <- dep33@data
    # couleurs <- rainbow(nrow(dep33@data))
    # couleurs <- c("blue","red","orange","black","pink")
    # couleurs <- sample(couleurs, nrow(dep33@data),replace = T)
    m <- leaflet(dep33)  %>%
      addPolygons(popup=as.character(dep33$libgeo), stroke=T,opacity=0.5,weight=1,color="grey",
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
  
  observeEvent(input$affichermap,{
    ### on commence par vérifier que l'event 0 existe :
    cat ("bouton leaflet afficher cliqué \n")
    event <- values[["selection0"]]$event
    if (is.null(event$get_type_selected())){
      cat ("\t event", event$get_event_number(), "aucun évènement sélectionné/validé pour le main event\n")
      return(NULL)
    }
    
    event$set_spatial()
    
    if (exists("spatial")){
      ## si déjà créés, retirer les ids des polylines existants
      ids <- c(spatial$df_transfert_entree$id, spatial$df_transfert_sortie$id)
      remove_polylines_id("map",ids)
    }
    
    spatial <<- event$spatial
    
    #undebug(spatial$get_zone_chalandise)
    ## calcul : rapport patients sélectionnés et patients de df selection
    rapport <- spatial$get_zone_chalandise(df_patient = df_patient, 
                                           df_selection = event$df_events_selected)
    #rapport$pourcentage <- runif(nrow(rapport),min=0, max=1)
    pal <- colorNumeric(palette = "Blues",domain = rapport$pourcentage)
    rapport$couleur <- pal(rapport$pourcentage)
    colnames(rapport) <- c("codgeo","denom","frequence","pourcentage","couleur")
    cloropeth("map",dep33, rapport)
    
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
  
  
  ### Améliorer ce code : je répète ce qui est plus haut
  # ne pas recalculer la dataframe spatial
  observeEvent(input$checkbox_transfert, {
    cat("checkbox_transfert cliqué \n")
    if (!exists("spatial")){
      cat("\t Spatial n'a pas été initialisé \n")
      return(NULL)
    }
    isolate(entree_sortie_checkbox <- input$checkbox_transfert)
    
    bool <- "entree" %in% entree_sortie_checkbox & nrow(spatial$df_transfert_entree) != 0
    if (bool){
      cat ("\t", nrow(spatial$df_transfert_entree), "transfert entree à afficher \n")
      afficher_parcours("map",spatial$df_transfert_entree)
    } else {
      remove_polylines_id("map",spatial$df_transfert_entree$id)
    }
    
    bool <- "sortie" %in% entree_sortie_checkbox & nrow(spatial$df_transfert_sortie) != 0
    if (bool){
      cat ("\t", nrow(spatial$df_transfert_sortie), "transfert sortie à afficher \n")
      afficher_parcours("map",spatial$df_transfert_sortie)
    } else {
      remove_polylines_id("map",spatial$df_transfert_sortie$id)
    }
  },ignoreNULL = F)

  ### fonction 
    remove_polylines_id <- function(map, polylines_id){
      for (i in polylines_id){
        leafletProxy(map) %>%
          removeShape(layerId = i)
      }
    }

    ## map : leaflet map
    # SPdf : de la carte (la meme lors de l'initialisation)
    # couleur : de chaque polygone
    cloropeth = function(map, SPdf, rapport){
      # metadata <- dep33@data
      if (!class(SPdf) == "SpatialPolygonsDataFrame"){
        stop("SPdf n'est pas une spatialpolygondataframe")
      }

      bool <- "codgeo" %in% colnames(SPdf@data)
      if (!bool){
        stop("la table metadata ne contient pas la colonne codgeo")
      }
      
      bool <- "codgeo" %in% colnames(rapport)
      if (!bool){
        stop("la table rapport ne contient pas la colonne codgeo")
      }
      
      metadata <- merge (SPdf@data, rapport, by="codgeo", all.x=T)
      ## lors de la jointure : perte de l'ordre 
      metadata <- metadata[match(SPdf@data$codgeo,metadata$codgeo),] ## remettre l'ordre
      ## couleur quand c vide
      bool <- is.na(metadata$frequence)
      metadata$couleur[bool] <- "grey"
      ## libellé à afficher : le nom ou le nom + la fréquence et le dénom
      libgeo <- ifelse(bool, as.character(metadata$libgeo),
                       paste0(metadata$libgeo, "<br>",metadata$frequence,"/",metadata$denom))
      
      leafletProxy(map)  %>%
        addPolygons(data=SPdf, popup=as.character(libgeo), stroke=T,opacity=0.5,weight=1,color=metadata$couleur,
                    #"grey",
                    layerId=SPdf$codgeo)
      return(NULL)
    }
    
    
    ### afficher ou pas les UNV
    afficherUNVSSR <- function(map,groupe,bool_afficher){
      if (bool_afficher){
        leafletProxy(map) %>% showGroup(groupe)
      } else {
        leafletProxy(map) %>% hideGroup(groupe)
      }
      
    }
    observe({
      afficherUNVSSR("map","UNV",input$UNV)
    })
    
    observe({
      afficherUNVSSR("map","SSR",input$SSR)
    })