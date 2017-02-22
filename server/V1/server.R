

function(input,output, session){
  
  ## carte leaflet
  output$map <- renderLeaflet({
    m <- leaflet(dep33) %>%
      addPolygons(popup=as.character(dep33$libgeo), stroke=T,opacity=0.5,weight=1,color="grey",
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
    
    ### passer une matrice au lieu de faire une boucle
    for (i in 1:nrow(table_pmsi)){
      poids <- ceiling(100*table_pmsi$Npercent[i])
      longitudes <- c(table_pmsi$codegeo.x[i],table_pmsi$X[i])
      latitudes <-  c(table_pmsi$codegeo.y[i],table_pmsi$Y[i])
      print (longitudes)
      m <- addPolylines(m,lng=longitudes, lat=latitudes,color = "blue",
                        weight = poids,opacity = 1, 
                        layerId=table_pmsi$idparcours[i])
    }
    return(m)
  })
  
  ## fonction pour afficher les parcours :
  # map = "map" si on ne modifie pas plus haut
  # table_pmsi : un subset de table_pmsi (mêmes colonnes)
  afficher_parcours <- function(map, table_pmsi){
    for (i in 1:nrow(table_pmsi)){
      poids <- ceiling(100*table_pmsi$Npercent[i])
      longitudes <- c(table_pmsi$codegeo.x[i],table_pmsi$X[i])
      latitudes <-  c(table_pmsi$codegeo.y[i],table_pmsi$Y[i])
      leafletProxy (map) %>% addPolylines(lng=longitudes, lat=latitudes,color = "blue",
                        weight = poids,opacity = 1, 
                        layerId=table_pmsi$idparcours[i])
    }
  }

  ## Bouton reset : 
  observeEvent(input$button, {
    leafletProxy("map") %>% clearPopups()
    afficher_parcours("map",table_pmsi)
  })
  
  ## Event : clique sur checkbox pour faire apparaître / disparaître les UNV ici
  observe({
    variable <- input$UNV
    if (input$UNV){
      leafletProxy("map") %>%
        showGroup("UNV")
    } else {
      leafletProxy("map") %>%
        hideGroup("UNV")
    }
  })
  
  # Event : clique sur marker (établissement) pour afficher des informations spécifiques
  observe({
    event <- input$map_marker_click
    if (is.null(event))
      return()
    leafletProxy("map") %>% clearPopups()
    # 
    cat("marker cliqué : ",event$id, "\n")
    bool <- table_pmsi$nofinesset %in% event$id  
    if (any(bool)){ ## clique sur un établissement
      table_pmsi_subset <- subset (table_pmsi, bool)
      for (i in 1:nrow(table_pmsi)){
        leafletProxy("map") %>%
          removeShape(layerId = table_pmsi$idparcours[i])
      }
      afficher_parcours("map",table_pmsi_subset) ## afficher les parcours de ce subset
      output$summary <- renderPrint({
        coordonnees <- paste (table_pmsi_subset$codegeo.x, table_pmsi_subset$codegeo.y,sep="\t")
        cat("informations sur l'établissement : \n 
            numéro Finess : ",unique(table_pmsi_subset$nofinesset))
      })
      output$graphique <- renderPlot({
        x <- table_pmsi_subset$N
        boxplot(x, main="",
             xlab="",ylab="Nombre de patients")
      })
    }
    ### pour retirer : 
    # leafletProxy("map") %>%
    #   removeShape(layerId = id)
#     leafletProxy("map") %>%
#       removeMarker(layerId = id)
  })
  
  # Event : clique sur zone géographique pour afficher des informations spécifiques
  observe({
    event <- input$map_shape_click
    leafletProxy("map") %>% clearPopups()
    cat("shape cliquée : ",event$id, "\n")
    bool <- table_pmsi$codgeo %in% event$id  
    if (any(bool)){ ## clique sur une zone géographique
      table_pmsi_subset <- subset (table_pmsi, bool)
      for (i in 1:nrow(table_pmsi)){
        leafletProxy("map") %>%
          removeShape(layerId = table_pmsi$idparcours[i])
      }
      afficher_parcours("map",table_pmsi_subset) ## afficher les parcours de ce subset
      output$summary <- renderPrint({
        coordonnees <- paste (table_pmsi_subset$codegeo.x, table_pmsi_subset$codegeo.y,sep="\t")
        cat("informations sur la zone géographique : \n ",coordonnees)
      })
      output$graphique <- renderPlot({
        set.seed(table_pmsi_subset$codegeo) ### reproductible selon la zone cliquée
        x <- round(rnorm(1000,70,20),0)
        hist(x, main="",
             xlab="age",ylab="frequence")
      })
    }
    ### pour retirer : 
    # leafletProxy("map") %>%
    #   removeShape(layerId = id)
    #     leafletProxy("map") %>%
    #       removeMarker(layerId = id)
    if (is.null(event))
      return()
  })
  
  
  ## DT : afficher une table
  output$table_pmsi <- DT::renderDataTable({
    DT::datatable(locEtab33SSR@data)
  })

}