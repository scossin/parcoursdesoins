######################## Codes pour visualiser les codes géographiques sous R
############## Mettre les établissements géolocalisés
############ Afficher des parcours sous forme de flèches. 

rm(list=ls())

library(rgdal)
library(maptools)

EPSG <- make_EPSG()
# le code de notre référentiel : RGF93
bool <- EPSG$code == 2154 & !is.na(EPSG$code)
RGF93 <- EPSG$prj4[bool]
RGF93prj4 <- CRS(RGF93)

load("../CouchesPMSI/codesgeo2014/couchegeoPMSI2014.rdata")
## calcul des centroides
dep33 <- subset (couchegeoPMSI2014, substr(couchegeoPMSI2014$codgeo,1,2) == 33)
plot(dep33)
centroides <- rgeos::gCentroid(dep33,byid = T)
points(centroides,col="red",pch=19) 

####### visualiser les établissements en gironde :
load("../FINESS/locEtab.rdata")
# transform cette dataframe de coordonnées en objet SpatialPoints 
locEtab$X <- as.numeric(as.character(locEtab$X))
locEtab$Y <- as.numeric(as.character(locEtab$Y))
coordinates(locEtab) <- ~ X + Y
proj4string(locEtab) <- RGF93prj4

### sélection des centres hospitaliers en gironde
locEtab33 <- subset (locEtab, substr(locEtab$INSEE_COM,1,2) == 33)
locEtab33CH <- subset (locEtab33, categetab == "355")

### UNV : 
unv <- read.table("../FINESS/UNV/ars_metropole_unv_t.csv",sep=",",header=T,
                  fileEncoding = "ISO-8859-1")
bool <- unv$finess_site %in% locEtab$nofinesset
sum(bool) ## 3 unités UNV ne figurent pas dans locEtab !

bool <- locEtab33$nofinesset %in% unv$finess_site
sum(bool)
locEtab33UNV <- subset (locEtab33, bool)
class(locEtab33UNV)
points(locEtab33UNV,col="blue",pch=18)

### SSR : 
locEtab33SSR <- subset (locEtab33, categetab == 109)
points(locEtab33SSR,col="green",pch=20)


######### Réaliser un lien (transfert) entre établissements : 
x0 <- 371348.5
y0 <- 6401264
x1 <- 412463.6 
y1 <- 6455044
#plot(geoPMSI33,col="#f2f2f2",lwd=0.1)
fleche <- arrows(x0, y0,x1,y1,length=0.1)
points(locEtab33CH,col="blue",pch=18)

## départ du code géo Arcachon pour aller au CH d'Arcachon
bool <- (couchegeoPMSI2014$libgeo == "ARES")
any(bool)
x0 <- couchegeoPMSI2014$x[bool]
y0 <- couchegeoPMSI2014$y[bool]
x1 <- 371348.5
y1 <- 6401264
arrows(x0, y0,x1,y1,length=0.1,lwd = 2)
locEtab33CH[1,]
## départ du CH d'Arcachon pour aller en SSR
x2 <- 417571.1
y2 <- 6418302

save(list = c("dep33","centroides","locEtab33SSR","locEtab33UNV",
              "x0","y0","x1","y1","x2","y2"),file="../Rapport/R/parcours.rdata")

