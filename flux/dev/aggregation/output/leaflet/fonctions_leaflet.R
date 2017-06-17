afficher_parcours <- function(map, trajectoires){
  ### ajout des nouvelles trajectoires
  for (i in 1:nrow(trajectoires)){
    # poids <- trajectoires$poids ## entre 1 et 10
    longitudes <- c(trajectoires$fromlong[i], trajectoires$tolong[i])
    latitudes <- c(trajectoires$fromlat[i], trajectoires$tolat[i])
    
    leaflet::leafletProxy(map) %>% leaflet::addPolylines(lng=longitudes, lat=latitudes,color = trajectoires$couleur[i],
                                       weight = trajectoires$poids[i],opacity = 1, 
                                       label=as.character(trajectoires$N[i]),
                                       layerId=trajectoires$id[i])
  }
}