fichier <- "atih_metropole_fondpmsi2014_z.shp"
library(rgdal)
EPSG <- make_EPSG()
# le code de notre référentiel : RGF93
bool <- EPSG$code == 2154 & !is.na(EPSG$code)
RGF93 <- EPSG$prj4[bool]
RGF93prj4 <- CRS(RGF93)

library(maptools)
## chargement du fichier GeoFla avec la projection RGF93
couchegeoPMSI2014 <- readShapePoly(fichier,proj4string = RGF93prj4)
save(couchegeoPMSI2014, file="couchegeoPMSI2014.rdata")
