################### Exemples de scripts pour : 
######  1) lister les référentiels géodésiques
#####   2) transformer les données dans un autre référentiel
#####   3) réunion de plusieurs polygones
#####   4) calcul des centroides

rm(list=ls())
#### 1) Changement de référentiels géodésiques : 
## liste des référentiels :
EPSG <- make_EPSG()
bool <- grepl("Lambert",EPSG$note,ignore.case = T)
EPSG_lambert <- subset (EPSG, bool)
RGF93 <- EPSG_lambert$prj4[EPSG_lambert$code==2154 & !is.na(EPSG_lambert$code)]
# création d'un objet CRS 
RGF93prj4 <- CRS(RGF93)


### coordonnées de la première commune : Lourties-Monbrun
df <- data.frame(X = 500820, Y = 6264958)
# transform cette dataframe de coordonnées en objet SpatialPoints 
coordinates(df) <- ~ X + Y
class(df)
# fournit la projection de ces coordonnées
proj4string(df) <- RGF93prj4
# transforme dans le référentiel WGS84
dfwgs84 <- spTransform(df, CRS("+proj=longlat +ellps=WGS84"))
dfwgs84
# possible de vérifier la bonne transformation avec GoogleMaps

### Réunion de plusieurs polygones
fichier <- "GEOFLA_2-2_COMMUNE_SHP_LAMB93_FXX_2016-06-28/GEOFLA/1_DONNEES_LIVRAISON_2016-06-00236/GEOFLA_2-2_SHP_LAMB93_FR-ED161/COMMUNE/COMMUNE.shp"
library(maptools)
## chargement du fichier GeoFla avec la projection RGF93
communes <- readShapePoly(fichier,proj4string = RGF93prj4)
# choix du département 33 pour montrer la fusion des polygones :
dep33 <- subset (communes, CODE_DEPT =="33")
plot(dep33) ## les communes de la Gironde
arrond33 <- unionSpatialPolygons(dep33, IDs = dep33$CODE_ARR) 
plot(arrond33) ### les arrondissements
centroides <- rgeos::gCentroid(arrond33,byid = T)
points(centroides)

