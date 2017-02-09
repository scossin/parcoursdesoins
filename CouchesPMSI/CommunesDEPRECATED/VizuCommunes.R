rm(list=ls())

library(rgdal)
library(maptools)

EPSG <- make_EPSG()
# le code de notre référentiel : RGF93
bool <- EPSG$code == 2154 & !is.na(EPSG$code)
RGF93 <- EPSG$prj4[bool]
RGF93prj4 <- CRS(RGF93)

# couche des communes : 
fichier <- "GEOFLA_2-2_COMMUNE_SHP_LAMB93_FXX_2016-06-28/GEOFLA/1_DONNEES_LIVRAISON_2016-06-00236/GEOFLA_2-2_SHP_LAMB93_FR-ED161/COMMUNE/COMMUNE.shp"
# chargement du fichier GeoFla avec la projection RGF93
communes <- readShapePoly(fichier,proj4string = RGF93prj4)

# ajout des informations sur les codes géographiques PMSI 
load("geoPMSIcommune.rdata")

## sélectionner la gironde pour commencer : 
dep33 <- subset (communes, CODE_DEPT =="33")
geoPMSIcommune33 <- subset (geoPMSIcommune, Code_commune_INSEE %in% dep33$INSEE_COM)
any(duplicated(geoPMSIcommune33$Code_commune_INSEE)) ## aucune commune appartient à plusieurs codes géo PMSI
dep33 <- merge (dep33, geoPMSIcommune33, by.x="INSEE_COM",by.y="Code_commune_INSEE")
geoPMSIcommune33 <- NULL 
bool <- dep33$INSEE_COM %in% geoPMSIcommune$Code_commune_INSEE
all(bool) ### tous les codes insee geofla sont connues de la table geoPMSI
length(unique(dep33$Code_geo)) ### 94 codes géographiques en Gironde

########## Metadonnées pour les codes geo : table codegeo
#### nombre d'habitants par codeGeoPMSI :
habitants <- tapply(dep33$POPULATION, as.character(dep33$Code_geo),sum)
boxplot(habitants)
habitants <- data.frame(Code_geo = names(habitants), habitants=as.numeric(habitants))
### villes triées par CodeGeo et population
voir <- dep33@data
voir <- voir[with(voir,order(Code_geo,-POPULATION)),]
communesjoined <- tapply(voir$NOM_COM, as.character(voir$Code_geo), function(x){
  paste (x, collapse=";")
})
communesjoined <- data.frame(Code_geo = names(communesjoined), 
                             communes=as.character(communesjoined))
communesjoined <- communesjoined[order(communesjoined$Code_geo),]
### jointure :
codegeo <- merge (communesjoined, habitants,by="Code_geo")
# menage : 
habitants <- NULL
communesjoined <- NULL
EPSG <- NULL
voir <- NULL

## regroupement des communes par code geo PMSI
geoPMSI33 <- unionSpatialPolygons(dep33, IDs = dep33$Code_geo) 
plot(geoPMSI33)
## calcul des centroides
centroides <- rgeos::gCentroid(geoPMSI33,byid = T)
points(centroides,col="red",pch=19) 

## ajout des métadonnées sur les codes geo PMSI : table codegeo
rownames(codegeo) <- codegeo$Code_geo
geoPMSI33 <- SpatialPolygonsDataFrame(geoPMSI33, codegeo)
bool <- grepl(";",geoPMSI33$communes)
sum(bool) ## 64 codes géo composés d'au moins 2 communes
geoPMSI33$couleurs <- ifelse(bool, "orange","skyblue")
plot(geoPMSI33, col=geoPMSI33$couleurs)



####### visualiser les établissements en gironde :
load("../../FINESS/locEtab.rdata")
### sélection des centres hospitaliers en gironde
locEtab33 <- subset (locEtab, substr(locEtab$INSEE_COM,1,2) == 33)
locEtab33CH <- subset (locEtab33, categetab == "355")
# transform cette dataframe de coordonnées en objet SpatialPoints 
locEtab33CH$X <- as.numeric(as.character(locEtab33CH$X))
locEtab33CH$Y <- as.numeric(as.character(locEtab33CH$Y))
coordinates(locEtab33CH) <- ~ X + Y
class(locEtab33CH)
# fournit la projection de ces coordonnées
proj4string(locEtab33CH) <- RGF93prj4


######### Réaliser un lien (transfert) entre établissements : 
x0 <- 371348.5
y0 <- 6401264
x1 <- 412463.6 
y1 <- 6455044
#plot(geoPMSI33,col="#f2f2f2",lwd=0.1)
fleche <- arrows(x0, y0,x1,y1,length=0.1)
points(locEtab33CH,col="red",pch=18)

