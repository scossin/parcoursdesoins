#### Exemple pour visualiser sous Leaflet un objet SpatialPolygonDataFrame R :
rm(list=ls())
EPSG <- make_EPSG()
bool <- grepl("Lambert",EPSG$note,ignore.case = T)
EPSG_lambert <- subset (EPSG, bool)
RGF93 <- EPSG_lambert$prj4[EPSG_lambert$code==2154 & !is.na(EPSG_lambert$code)]
# création d'un objet CRS 
RGF93prj4 <- CRS(RGF93)
library(leaflet)
load("../CouchesPMSI/codesgeo2014/couchegeoPMSI2014.rdata")
load("../Rapport/R/parcours.rdata")
dep33 <- subset (couchegeoPMSI2014, substr(couchegeoPMSI2014$codgeo,1,2) == 33)
### transformation nécessaire dans un autre référentiel
dep33 <- spTransform(dep33, CRS("+init=epsg:4326"))
m <- leaflet(dep33) %>%
  addPolygons(
    stroke = TRUE, fillOpacity = 2, smoothFactor = 2,color ="black",fillColor="white"
  )
m
## ajout d'une popup
df <- data.frame(X = x1, Y = y1)
coordinates(df) <- ~ X + Y
proj4string(df) <- RGF93prj4
dfwgs84 <- spTransform(df, CRS("+proj=longlat +ellps=WGS84"))
m <- addMarkers(m, lng=coordinates(dfwgs84)[1], lat=coordinates(dfwgs84)[2], popup="UNV CH d'Arcachon")
m