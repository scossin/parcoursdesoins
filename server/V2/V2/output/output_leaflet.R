


## carte leaflet initialisation
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
  i <- 1
  #afficher_parcours(m,trajectoires)
  for (i in 1:nrow(trajectoires)){
    poids <- trajectoires$poids[i] ## entre 1 et 10
    longitudes <- c(getcoordinates(tabgeo, trajectoires$from[i])$x,
                    getcoordinates(tabgeo, trajectoires$to[i])$x)
    latitudes <- c(getcoordinates(tabgeo, trajectoires$from[i])$y,
                   getcoordinates(tabgeo, trajectoires$to[i])$y)
    
    m <- addPolylines(m,lng=longitudes, lat=latitudes,color = trajectoires$couleur[i],
                      weight = poids,opacity = 1, 
                      label=paste(trajectoires$N[i]),
                      
                      layerId=trajectoires$id[i])
  }
  return(m)
})



## fonction permettant de changer la carte leaflet 
# 
afficher_parcours <- function(map, trajectoires, finess){
  bool <- trajectoires$from %in% finess | trajectoires$to %in% finess
  if (!any(bool)){
    cat("afficher_parcours : ", finess, " non trouvé \n")
    return(NULL)
  }
  
  subsettrajectoires <- subset (trajectoires, bool) ## si c'est un établissement
  
  ### retirer les trajectoires précédentes
  for (i in 1:nrow(trajectoires)){
    leafletProxy("map") %>%
      removeShape(layerId = trajectoires$id[i])
  }
  
  ### ajout des nouvelles trajectoires
  for (i in 1:nrow(subsettrajectoires)){
    poids <- subsettrajectoires$poids[i] ## entre 1 et 10
    longitudes <- c(getcoordinates(tabgeo, subsettrajectoires$from[i])$x,
                    getcoordinates(tabgeo, subsettrajectoires$to[i])$x)
    latitudes <- c(getcoordinates(tabgeo, subsettrajectoires$from[i])$y,
                   getcoordinates(tabgeo, subsettrajectoires$to[i])$y)
    
    leafletProxy(map) %>% addPolylines(lng=longitudes, lat=latitudes,color = subsettrajectoires$couleur[i],
                                       weight = poids,opacity = 1, 
                                       label=paste(subsettrajectoires$N[i]),
                                       layerId=subsettrajectoires$id[i])
  }
}



############################## Events : 

## Bouton reset : 
observeEvent(input$button, {
  leafletProxy("map") %>% clearPopups()
  # tous les finess : 
  finesses <- c(trajectoires$from, trajectoires$to)
  afficher_parcours("map",trajectoires,finesses)
})

## Event : clique sur checkbox pour faire apparaître / disparaître les UNV ici
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

# Event : clique sur marker (établissement) 
observe({
  # if (is.null(event))
  #   return()
  
  event <- input$map_marker_click
  leafletProxy("map") %>% clearPopups()
  # 
  cat("marker cliqué sur carte Leaflet : ",event$id, "\n")
  
    
  ### Modification carte :
  afficher_parcours("map",trajectoires,event$id) ## afficher les parcours de ce subset
    
  ### Modification tableau : 
  DT::selectRows(DT::dataTableProxy("tableau"), get_etabrow(event$id))
    
  ### Modification network
  visSelectNodes(visNetworkProxy("network"),id = event$id)
  
  })


# Event : clique sur zone géographique pour afficher des informations spécifiques
observe({
  # if (is.null(event))
  #   return()
  event <- input$map_shape_click
  leafletProxy("map") %>% clearPopups()
  cat("shape cliquée : ",event$id, "\n")
  
  ## Modification carte : 
  afficher_parcours("map",trajectoires,event$id) ## afficher les parcours de ce subset
})


