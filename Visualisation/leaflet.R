#### Exemple pour visualiser sous Leaflet un objet SpatialPolygonDataFrame R :
rm(list=ls())
library(maptools)
library(rgdal)
library(leaflet)
# projection RGF93
EPSG <- make_EPSG()
bool <- grepl("Lambert",EPSG$note,ignore.case = T)
EPSG_lambert <- subset (EPSG, bool)
RGF93 <- EPSG_lambert$prj4[EPSG_lambert$code==2154 & !is.na(EPSG_lambert$code)]
# création d'un objet CRS 
RGF93prj4 <- CRS(RGF93)

# couches des codes géographiques PMSI 2014
load("../CouchesPMSI/codesgeo2014/couchegeoPMSI2014.rdata")
# chargement des UNV et des SSR
load("../Rapport/R/parcours.rdata")
dep33 <- subset (couchegeoPMSI2014, substr(couchegeoPMSI2014$codgeo,1,2) == 33)
### transformation nécessaire dans un autre référentiel
dep33 <- spTransform(dep33, CRS("+init=epsg:4326"))
locEtab33SSR <- spTransform(locEtab33SSR, CRS("+init=epsg:4326"))
locEtab33UNV <- spTransform(locEtab33UNV, CRS("+init=epsg:4326"))

## ajout d'une popup pour chaque UNV et SSR : 

## Icons
# fait avec : https://www.canva.com/
UNVicon <- makeIcon(
  iconUrl = "UNV3.png",
  iconWidth = 40, iconHeight = 70,
  iconAnchorX = 0, iconAnchorY = 0
)
SSRicon <- makeIcon(
  iconUrl = "SSR.png",
  iconWidth = 40, iconHeight = 70,
  iconAnchorX = 22, iconAnchorY = 22
)

makemap <-  function(){
  m <- leaflet(dep33) %>%
    addPolygons(popup=as.character(dep33$libgeo), stroke=T,opacity=0.5,weight=1,color="grey") %>%  
    addProviderTiles("Stamen.TonerLite")
  ## tester : Hydda.Full => affiche les principales villes 
  # OpenStreeMap : forets ...
  
  # geoloc SSR
  m <- addMarkers(m, lng=coordinates(locEtab33SSR)[,1], 
                  lat=coordinates(locEtab33SSR)[,2], 
                  popup=as.character(locEtab33SSR$rs),icon=SSRicon) %>% 
    # geoloc UNV
    addMarkers(m, lng=coordinates(locEtab33UNV)[,1], 
               lat=coordinates(locEtab33UNV)[,2], 
               popup=as.character(locEtab33UNV$rs), icon=UNVicon)
  return(m)
}
m <- makemap()

## création d'une dataframe parcours : 

# centroides des codes géographiques PMSI 
centroides <- rgeos::gCentroid(dep33,byid = T)

## calculer la distance avec GoogleMap : 
# http://nagraj.net/notes/calculating-geographic-distance-with-r/
# ggmap package : google map for R

### déterminer l'établissement le plus prêt : 
id_proche <- rep(0, length(centroides)) ## 0 par défaut
min_distance <- rep(1000000, length(centroides)) ## 1 000 km
i <- 1
for (i in 1:nrow(locEtab33UNV)){
  distance_i <-  geosphere::distCosine(centroides,locEtab33UNV[i,])
  bool <- min_distance - distance_i > 0 ## plus proche que min_distance ?
  id_proche[bool] <- as.character(locEtab33UNV[i,]$nofinesset)
  min_distance[bool] <-  distance_i[bool]
}

table_pmsi <- data.frame(nofinesset = id_proche, codegeo = centroides)
# Nb de séjours
set.seed(67)
table_pmsi$N <- round(runif(nrow(table_pmsi), 1,100),0)

# ajout geoloc codes finess : 
table_pmsi <- merge (table_pmsi, locEtab33UNV, by="nofinesset")
table_pmsi$Npercent <- table_pmsi$N / sum(table_pmsi$N)


for (i in 1:nrow(table_pmsi)){
  poids <- ceiling(100*table_pmsi$Npercent[i])
  longitudes <- c(table_pmsi$codegeo.x[i],table_pmsi$X[i])
  latitudes <-  c(table_pmsi$codegeo.y[i],table_pmsi$Y[i])
  m <- addPolylines(m, lng=longitudes, lat=latitudes,color = "blue",
                    popup = "test",weight = poids,opacity = 1,layerId=i)
}
m
# centroides
addCircles(m, lng = table_pmsi$codegeo.x,lat = table_pmsi$codegeo.y, radius=table_pmsi$N, color="red")

