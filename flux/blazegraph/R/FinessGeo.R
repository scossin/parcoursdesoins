############### L'objectif de ce script est de transformer en RDF la géolocalisation des établissements
### dans le département 33 pour le prototype

rm(list=ls())

#### FinessGeo: (voir le dossier FINESS pour comprendre comment cette table a été créée)
load("../../../FINESS/locEtab.rdata")

# sélection des établissements dans le 33 : 
locEtab$dep <- substr(locEtab$INSEE_COM,1,2)
table(locEtab$dep)
locEtab33 <- subset (locEtab, dep==33)
#save(file="MetaDonneesEtab33.rdata",locEtab33)
locEtab33 <- subset (locEtab33, select=c("nofinesset","rs","X","Y"))

# création d'un objet spatial
library(rgdal)
EPSG <- make_EPSG()
# le code de notre référentiel : RGF93
bool <- EPSG$code == 2154 & !is.na(EPSG$code)
RGF93 <- EPSG$prj4[bool]
RGF93prj4 <- CRS(RGF93)

# transform cette dataframe de coordonnées en objet SpatialPoints 
locEtab33$X <- as.numeric(as.character(locEtab33$X))
locEtab33$Y <- as.numeric(as.character(locEtab33$Y))
coordinates(locEtab33) <- ~ X + Y
proj4string(locEtab33) <- RGF93prj4 ## X Y sont dans la projection RGF93

## transforme les coordonnées RGF93 dans le référentiel WGS84 
locEtab33 <- spTransform(locEtab33, CRS("+init=epsg:4326"))
coordonnees <- data.frame(coordinates(locEtab33))
meta <- locEtab33@data
colnames(meta) <- c("code","label")
## rempalce les coordonnées par le référentiel WGS84
meta$long <- coordonnees$X
meta$lat <- coordonnees$Y
meta$idEtab <- meta$code

### Création de triplets : 
namespaces <- read.table("namespaces.csv",sep="\t", header=T, comment.char = "",
                         stringsAsFactors = F)
source("RDF.R")
rdf <- new("RDF",namespaces=namespaces)
rdf$create_tripletspl(prefixe_sujet = "datagouv", sujet = meta$idEtab,
                      prefixe_predicat = "geo", predicat = "long",
                      literal = meta$long, typeliteral = "float")

rdf$create_tripletspl(prefixe_sujet = "datagouv", sujet = meta$idEtab,
                      prefixe_predicat = "geo", predicat = "lat",
                      literal = meta$lat, typeliteral = "float")

rdf$create_tripletspl(sujet = meta$idEtab, prefixe_sujet = "datagouv",
                      prefixe_predicat = "rdfs", predicat = "label",
                      literal = meta$label, typeliteral = "string")

rdf$create_tripletspl(prefixe_sujet = "datagouv", sujet = meta$idEtab,
                      prefixe_predicat = "datagouv", predicat = "hasCode",
                      literal = meta$code, typeliteral = "string")

rdf$create_tripletspo(prefixe_sujet = "datagouv", sujet = meta$idEtab,
                      prefixe_predicat = "rdf", predicat = "type",
                      prefixe_objet = "datagouv", objet = "Etablissement")
rdf$serializeandwrite("codesFINESS.rdf")
## passage au format turtle car plus lisibles : 
XMLtoTurtleCmmande <- "rapper -i rdfxml codesFINESS.rdf -o turtle > codesFINESS.ttl"
system(XMLtoTurtleCmmande)

## chargement dans un triplestore ensuite ...

