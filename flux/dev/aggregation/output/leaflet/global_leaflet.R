## vérifie sur le fichier existe sinon modifie le chemin
change_file_directory = function(dossier, fichier){
  if (!file.exists(fichier)){
    fichier <- paste0(dossier, fichier)
  }
  return(fichier)
}
dossier_leaflet <- "output/leaflet/"

library(leaflet)
library(sp)
library(rgdal)

### séquence des évènements spatiale
## doit etre mis dans une base de données 
fichier_tab_spatial <- change_file_directory(dossier_leaflet,"tab_spatial.rdata")
load(fichier_tab_spatial)

## chargement : 
# projection RGF93
EPSG <- rgdal::make_EPSG()
bool <- grepl("Lambert",EPSG$note,ignore.case = T)
EPSG_lambert <- subset (EPSG, bool)
RGF93 <- EPSG_lambert$prj4[EPSG_lambert$code==2154 & !is.na(EPSG_lambert$code)]

# création d'un objet CRS 
RGF93prj4 <- CRS(RGF93)

# couches des codes géographiques PMSI 2014
fichier_couche <- "couchegeoPMSI2014.rdata"
load(change_file_directory(dossier_leaflet,fichier_couche))

# chargement des UNV et des SSR
fichier_parcours <- "parcours.rdata"
load(change_file_directory(dossier_leaflet,fichier_parcours))


dep33 <- subset (couchegeoPMSI2014, substr(couchegeoPMSI2014$codgeo,1,2) == 33)
### transformation nécessaire dans un autre référentiel
dep33 <- spTransform(dep33, CRS("+init=epsg:4326"))

locEtab33SSR <- spTransform(locEtab33SSR, CRS("+init=epsg:4326"))
locEtab33UNV <- spTransform(locEtab33UNV, CRS("+init=epsg:4326"))





## Icons
# fait avec : https://www.canva.com/
UNVicon <- leaflet::makeIcon(
  iconUrl = change_file_directory(dossier_leaflet,"UNV3.png"),
  iconWidth = 40, iconHeight = 70,
  iconAnchorX = 0, iconAnchorY = 0
)
SSRicon <- leaflet::makeIcon(
  iconUrl = change_file_directory(dossier_leaflet,"SSR.png"),
  iconWidth = 40, iconHeight = 70,
  iconAnchorX = 22, iconAnchorY = 22
)




