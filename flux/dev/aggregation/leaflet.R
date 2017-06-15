library(dplyr)
library(shiny)
library(leaflet)
#rm(list=ls())

## fonction qui détermine la séquence spatiale à partir d'une liste d'events : 
# à réfléchir ce qu'on veut afficher spatialement
# choix arbitaire : algo : si plus de 2 jours entre 2 évènements alors le patient est rentré à domicile
load("evenements.rdata")
evenements$type <- gsub("^(.*?)#","",evenements$type) ### retirer tout ce qu'il y a avant #
evenements <- evenements %>% group_by(patient) %>% mutate(num = row_number())
evenements <- as.data.frame(evenements) ## sinon erreur bizarre
i <- evenements$patient[100]
patients <- unique(evenements$patient)
sequencespatial <- NULL
bool <- is.na(evenements$dateendevent)
evenementsfinis <- subset (evenements, !bool)
for (i in patients){
  temp <- subset (evenementsfinis, patient == i)
  temp <- temp[order(temp$datestartevent),]
  dom <- unique(as.character(temp$domicile))
  diff <- as.numeric(temp$datestartevent[2:(nrow(temp))] - temp$dateendevent[1:(nrow(temp)-1)])
  bool <- diff < 3
  fromlieu <- ifelse (bool, temp$lieu[-nrow(temp)], dom)
  fromlieu <- append(dom, fromlieu)
  tolieu <- ifelse (bool, temp$lieu[-1],dom)
  tolieu <- append(tolieu, dom)
  ajout <- data.frame(fromlieu = fromlieu, tolieu = tolieu)
  sequencespatial <- rbind(sequencespatial, ajout)
}

sequencespatial2 <- cbind(evenementsfinis, sequencespatial) ## dataframe qui sera utilisé pour afficher sur une carte
colnames(sequencespatial2)
sequencespatial2 <- subset (sequencespatial2, select=c("patient","num","lieu","fromlieu","tolieu"))
head(sequencespatial2)
sequencespatial2[] <- apply(sequencespatial2, 2, function(x){
  x <- gsub("^(.*?):","",x)
  x <- gsub ("^Etab","",x)
}### retirer tout ce qu'il y a avant :
)
## retirer aussi Etab : 

## 2 colonnes : from to pour chaque event : 
temp1 <- subset (sequencespatial2, select=c("patient","num","lieu","fromlieu"))
colnames(temp1) <- c("patient","num","to","from")
temp1$cat <- "provenance"
temp2 <- subset (sequencespatial2, select=c("patient","num","lieu","tolieu"))
colnames(temp2) <- c("patient","num","from","to")
temp2$cat <- "destination"
sequencespatial3 <- rbind(temp1, temp2)

## ajouter des coordonnées géographiques :
load("coordonneesGeo.rdata") ###  voir requeteGeo.R
sequencespatial3 <- merge (sequencespatial3, coordonneesGeo, by.x="from",by.y="code")
num_colonnes <- colnames(sequencespatial3) %in% c("lat","long")
colnames(sequencespatial3)[num_colonnes] <- c("fromlat","fromlong")
sequencespatial3 <- merge (sequencespatial3, coordonneesGeo, by.x="to",by.y="code")
num_colonnes <- colnames(sequencespatial3) %in% c("lat","long")
colnames(sequencespatial3)[num_colonnes] <- c("tolat","tolong")

### il aurait fallu récupérer les types : domicile / etablissement 
colnames(sequencespatial3)
car <- table(nchar(sequencespatial3$to))
bool <- nchar(sequencespatial3$to) == 5
sequencespatial3$typeto <- ifelse (bool, "dom","etab")
bool <- nchar(sequencespatial3$from) == 5
sequencespatial3$typefrom <- ifelse (bool, "dom","etab")
sequencespatial3$typedeparcours <- paste(sequencespatial3$typeto, sequencespatial3$typefrom,sep="-")
table(sequencespatial3$typedeparcours)
sequencespatial3$typeto <- NULL
sequencespatial3$typefrom <- NULL
sequencespatial3$to <- NULL
sequencespatial3$from <- NULL
sequencespatial3 <- sequencespatial3[with(sequencespatial3,order(patient,num)),]

## ajout d'une couleur pour les différents types de parcours
tab <- table (sequencespatial3$typedeparcours)
couleurs <- data.frame (typedeparcours = names(tab), couleur = rainbow(length(tab)))
sequencespatial3 <- merge (sequencespatial3, couleurs, by="typedeparcours")

colnames(sequencespatial3)

get_trajectoires = function(sequencespatial3){
  
}

trajectoires <- sequencespatial3
trajectoires$patient <- NULL
trajectoires$num <- NULL

grp_cols <- names(trajectoires)
dots <- lapply(grp_cols, as.symbol)
trajectoires <- trajectoires %>% group_by_(.dots=dots) %>% summarise(N=n())
## poids entre 1 et 10 :
trajectoires <- data.frame(trajectoires)
trajectoires$poids <- ceiling(trajectoires$N *10 / max(trajectoires$N))

library(leaflet)

## chargement : 
# projection RGF93
library(rgdal)
EPSG <- make_EPSG()
bool <- grepl("Lambert",EPSG$note,ignore.case = T)
EPSG_lambert <- subset (EPSG, bool)
RGF93 <- EPSG_lambert$prj4[EPSG_lambert$code==2154 & !is.na(EPSG_lambert$code)]
# création d'un objet CRS 
RGF93prj4 <- CRS(RGF93)

# couches des codes géographiques PMSI 2014
load("couchegeoPMSI2014.rdata")
dep33 <- subset (couchegeoPMSI2014, substr(couchegeoPMSI2014$codgeo,1,2) == 33)
### transformation nécessaire dans un autre référentiel
dep33 <- spTransform(dep33, CRS("+init=epsg:4326"))


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




