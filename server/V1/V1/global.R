####################### Pour leaflet : ##########################
# rm(list=ls())
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
load("couchegeoPMSI2014.rdata")
# chargement des UNV et des SSR
load("parcours.rdata")
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

### table PMSI : table de simulation crée dans le script leaflet.R :
# fichier temporaire : à remplacer par des données réelles
load("table_pmsi.rdata")
# un identifiant parcours unique pour savoir quand un utilisateur clique dessus 
table_pmsi$idparcours <- paste (table_pmsi$nofinesset, table_pmsi$codgeo,sep="_")
