############### L'objectif de ce script est de transformer en RDF la géolocalisation des centroïdes des codes géographiques
### Le domicile de chaque patient est représenté par un code géoPMSI
### Pour la visualisation cartographique, le domicile est géocodé par le centroïde du code géo PMSI

library(sp)
#### Transformation codeGeo en triplets RDF : 
rm(list=ls())

### voir le dossier
# géolocalisation des codes géographiques PMSI en 2014
load("../../../CouchesPMSI/codesgeo2014/couchegeoPMSI2014.rdata")
couchegeoPMSI2014 <- spTransform(couchegeoPMSI2014, CRS("+init=epsg:4326"))
coordonnees <- data.frame(coordinates(couchegeoPMSI2014))
meta <- couchegeoPMSI2014@data
colnames(meta) <- c("code","label","long","lat")
## rempalce les coordonnées par le référentiel WGS84
meta$long <- coordonnees$X1
meta$lat <- coordonnees$X2
meta$id <- paste("centroide",meta$code,sep="")

########################### RDF avec Redland
library(redland)
source("RDF.R") ### classe pour la création de triplets

## les namespaces sont stockés dans un fichier 
namespaces <- read.table("namespaces.csv",sep="\t", header=T, comment.char = "",
                         stringsAsFactors = F)

rdf <- new("RDF",namespaces=namespaces)
colnames(meta)

###
rdf$create_tripletspl(sujet = meta$id, prefixe_sujet = "eig",
                      prefixe_predicat = "geo", predicat = "long",
                      literal = meta$long, typeliteral = "float")

rdf$create_tripletspl(sujet = meta$id, prefixe_sujet = "eig",
                      prefixe_predicat = "geo", predicat = "lat",
                      literal = meta$lat, typeliteral = "float")

rdf$create_tripletspl(sujet = meta$id, prefixe_sujet = "eig",
                      prefixe_predicat = "rdfs", predicat = "label",
                      literal = meta$label, typeliteral = "string")

rdf$create_tripletspl(sujet = meta$id, prefixe_sujet = "eig",
                      prefixe_predicat = "eig", predicat = "hasCode",
                      literal = meta$code, typeliteral = "string")

rdf$serializeandwrite("../triplets/codesGEO.rdf")

XMLtoTurtleCmmande <- "rapper -i rdfxml codesGEO.rdf -o turtle > codesGEO.ttl"
system(XMLtoTurtleCmmande)


XMLtoTurtleCmmande <- "rapper -i rdfxml ../triplets/timelines/patient100.xml -o turtle > test.ttl"
system(XMLtoTurtleCmmande)

### simulation de codes geo pour 100 patients :
# bool <- grepl("33[0-9]{3}",meta$code)
# sum(bool)
# voir <- subset (meta, bool)
# domiciles <- sample(voir$code,1000,replace=T)
# domiciles <- data.frame(domicile=domiciles)
# domiciles$patient <- paste0("patient",1:1000)
# save(domiciles, file="domiciles.rdata")
