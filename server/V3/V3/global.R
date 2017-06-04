####################### Pour leaflet : ##########################
# rm(list=ls())
library(maptools)
library(rgdal)
library(leaflet)
library(DT)
library(visNetwork)
library(shiny)
library(timevis)
library(reshape2)
library(stringr)
library(DT)
library(plyr)

library(dplyr)
library(radarchart)
library(plotly)
library(googleVis)
library(d3Tree)
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
# load("table_pmsi.rdata")
# # un identifiant parcours unique pour savoir quand un utilisateur clique dessus 
# table_pmsi$idparcours <- paste (table_pmsi$nofinesset, table_pmsi$codgeo,sep="_")

### table de localisation géographique : 
tabgeo <- NULL
centroides <- spTransform(centroides, CRS("+init=epsg:4326"))
tabgeo <- data.frame(centroides@coords)
tabgeo$id <- as.character(dep33@data$codgeo)

ajoutMCO <- data.frame(locEtab33UNV@coords)
ajoutMCO$id <- as.character(locEtab33UNV@data$nofinesset)
colnames(ajoutMCO) <- colnames(tabgeo)
tabgeo <- rbind(tabgeo, ajoutMCO)

ajoutSSR <- data.frame(locEtab33SSR@coords)
ajoutSSR$id <- as.character(locEtab33SSR@data$nofinesset)
colnames(ajoutSSR) <- colnames(tabgeo)
tabgeo <- rbind(tabgeo, ajoutSSR)

getcoordinates <- function(tabgeo, id){
  bool <- tabgeo$id %in% id
  if (!any(bool)){
    stop("id inconnu dans tabgeo : mauvais code geographique ou numero Finess ?")
  }
  selectiongeo <- subset (tabgeo, bool)
  return(selectiongeo)
}


#### données simulées de trajectoires
load("trajectoires.rdata")
colnames(trajectoires)
trajectoires$id <- paste (trajectoires$from, trajectoires$to, sep="_")
types <- names(table(trajectoires$type))
couleurs <- data.frame(type = types, 
                       couleur = c("blue","green"))
trajectoires <- merge (trajectoires, couleurs, by="type")
## poids entre 1 et 10 :
trajectoires$poids <- ceiling(trajectoires$N *10 / max(trajectoires$N))






############################## Pour timelines ##########################################
### Création de timelines fake
## Etablissements de Gironde : UNV et SSR
#load("/home/cossin/Documents/EIG/parcoursdesoins/Rapport/R/parcours.rdata")
libetab <- rbind(locEtab33UNV@data, locEtab33SSR@data)
colnames(libetab)
libetab <- subset (libetab, select=c("nofinesset","rs"))
finessUNV <- locEtab33UNV@data$nofinesset
finessSSR <- locEtab33SSR@data$nofinesset

## nature : centre15, scanner...
create_event <- function(patientid, finess, nature, start, end, group){
  datedebut <- as.Date(start, format="%Y-%m-%d")
  id <- paste(patientid, datedebut, finess, nature,sep="_")
  data <- data.frame(
    patientid=patientid,
    id = id,
    finess=finess,
    nature=nature,
    #content=content, ## : ajout ensuite pour permettre des modifs
    start = start,
    end = end,
    group=group,
    stringsAsFactors = F
  )
  return(data)
}

## 10 timelines de patients
library(lubridate) ## pour additionner des durées à une date
jour2009 <- seq(as.Date("1/1/2009 00:00", format="%d/%m/%Y %M:%S"),as.Date("31/12/2009 00:00", format="%d/%m/%Y %M:%S"),
                by="day")

### Création de timelines fake
## Etablissements de Gironde : UNV et SSR
#load("/home/cossin/Documents/EIG/parcoursdesoins/Rapport/R/parcours.rdata")
libetab <- rbind(locEtab33UNV@data, locEtab33SSR@data)
colnames(libetab)
libetab <- subset (libetab, select=c("nofinesset","rs"))
finessUNV <- locEtab33UNV@data$nofinesset
finessSSR <- locEtab33SSR@data$nofinesset

listeevents <- NULL
set.seed(67)
### création des évènements :
i <- 2
for (i in 1:100){
  patientid <- paste("patient",i,sep="")
  finess <- 999
  ## symptome
  datesymptome <- sample(jour2009,1)
  symptomes <- c("aphasie","hémiplégie","coma")
  symptome <- sample(symptomes,1)
  datesymptome<- as.POSIXct(datesymptome)
  unevent <- create_event(patientid = patientid,
                          finess=finess,
                          nature=symptome,
                          start=datesymptome,
                          end=NA,
                          group="Symptôme")
  listeevents <- rbind (listeevents,unevent)

  ## appel
  tempsappel <- abs(round(rnorm(1,10,10),0))*60
  dateappel <- datesymptome + tempsappel
  finess <- sample (c(15,18),1)
  unevent <- create_event(patientid = patientid,
                          finess=finess,
                          nature=finess,
                          start=dateappel,
                          end=NA,
                          group="Appel")
  listeevents <- rbind (listeevents,unevent)

  ## hospit
  finess <- sample(finessUNV,1)
  tempshospit <- abs(round(rnorm(1,60,10),0))*60
  datehospit <-  dateappel + tempshospit
  dureehospit <-  abs(round(rnorm(1,4,2),0)+1)*60*60*24
  datesortie <- datehospit + dureehospit
  unevent <- create_event(patientid = patientid,
                          finess=finess,
                          nature=finess,
                          start=datehospit,
                          end=datesortie,
                          group="Hospitalisation")
  listeevents <- rbind (listeevents,unevent)

  ### imagerie
  dateimagerie <- datehospit + 60*60
  imagerie <- sample (c("scanner","irm"),1)
  bool <- rbinom(1,1,0.8) == 1
  if (bool){
    unevent <- create_event(patientid = patientid,
                            finess=finess,
                            nature=imagerie,
                            start=dateimagerie,
                            end=NA,
                            group="Imagerie")
    listeevents <- rbind (listeevents,unevent)
  }


  ## thrombolyse
  datethrombolyse <- dateimagerie + 30*60
  bool <- rbinom(1,1,0.5) == 1
  if (bool){
    unevent <- create_event(patientid = patientid,
                            finess=finess,
                            nature="thrombolyse",
                            start=datethrombolyse,
                            end=NA,
                            group="Médicaments")
    listeevents <- rbind (listeevents,unevent)
  }

  ## date transfert SSR
  finess <- sample(finessSSR,1)
  dureehospit <- abs(round(rnorm(1,20,10),0))*60*60*24
  dureetransfert <- abs(round(rnorm(1,0,2),0))*60*60*24
  dateentreeSSR <- datesortie + dureetransfert ## datesortie : MCO
  datesortieSSR <- datehospit + dureehospit

  unevent <- create_event(patientid = patientid,
                          finess=finess,
                          nature=finess,
                          start=dateentreeSSR,
                          end=datesortieSSR,
                          group="Hospitalisation")
  listeevents <- rbind (listeevents,unevent)

}

listeevents$end <- as.POSIXct(listeevents$end, origin = "1970-01-01") ## car NA présents

### Ajout content : contenu (image ou texte) de chaque item
libnature <- data.frame(nature=c("hémiplégie",
                                 "coma",
                                 "aphasie",
                                 "irm",
                                 "scanner",
                                 "thrombolyse",
                                 "15",
                                 "18"),
                        content=c("hémiplégie",
                                  "Imagemalade.png",
                                  "aphasie",
                                  "IRM",
                                  "ImageCT.jpeg",
                                  "thrombolyse",
                                  "Image15.png",
                                  "Pompiers"
                        ))

### remplacer image par leur chemin relatif :
libnature$content <- sapply(as.character(libnature$content), function(x){
  bool <- grepl("^Image",x)
  if (!bool){
    return(x)
  }
  x <- gsub("^Image","",x)
  x <- paste ('<img src="images/',x, '" height="48px" width="48px">',sep="")
  return(as.character(x))
})


colnames(libetab) <- colnames(libnature)
libnature <- rbind (libetab,libnature)
listeevents <- merge (listeevents, libnature,by="nature")

### Contenu des groupes :
groupes <- names(table(listeevents$group))
groupes <- data.frame(
  id = groupes,
  content=groupes
)





#################################### D3 Tree #############################################
### table de patients pour la sélection :
colnames(listeevents)
dfpatients <- data.frame(patientid=unique(listeevents$patientid))
dfpatients$Sex <- c("Homme","Femme")
dfpatients$Age <- round(abs(rnorm(nrow(dfpatients), mean=75, sd=50)),0)
bool <- dfpatients$Age > 100
dfpatients$Age[bool] <- dfpatients$Age[bool] - 50 
bool <- dfpatients$Age < 18
dfpatients$classeAge <- ifelse (bool, "enfants","adultes")

## calcul à partir des timeslines (ici : fake)
temp <- subset (listeevents, group=="Imagerie")
bool <- dfpatients$patientid %in% temp$patientid
dfpatients$delaiSymptomeImagerie <- abs(round(rnorm(nrow(dfpatients),20,10),0))
dfpatients$imagerie <- ifelse (bool, "oui","non")
# entre 15
bool <- dfpatients$imagerie == "oui"
dfpatients$centre15 <- ifelse(bool, rbinom(sum(bool),size = 1, prob = 0.9),
                              rbinom(sum(!bool),size = 1, prob = 0.1))
dfpatients$centre15 <- as.factor(dfpatients$centre15)
levels(dfpatients$centre15) <- c("non","oui")
dfpatients$NEWCOL <- NA
dfpatients=dfpatients%>%data.frame%>%mutate(NEWCOL=NA)
factorscolonnes <- NULL

dfpatients$Sex <- as.factor(dfpatients$Sex)
dfpatients$classeAge <- as.factor(dfpatients$classeAge)
dfpatients$imagerie <- as.factor(dfpatients$imagerie)

## pour un rapport : modifier imagerie et centre15 par AVCsevere et AVCthrombolyse
colonnes <- which(colnames(dfpatients) %in% c("imagerie","centre15"))
colnames(dfpatients)[colonnes] <- c("AVCsevere", "AVCthrombolyse")

#################################### Indicateurs #############################################


#### Création d'indicateurs 
set.seed(seed = 67)
finessetab <- c(330000555,330000555 - c(1:9))
nometab <- paste("Etablissement", toupper(letters[1:10]))
pourcentageThrombolyse <- round(rnorm(10, 50, 20),0)
Npatients <- round(rnorm(10, 500, 300),0)
pourcentageExpertise <- abs(round(rnorm(10, 50, 30),0))
pourcentageAAP <- round(rnorm(10, 90, 5),0) ## antiagrégant plaquettaire
pourcentageDeces <- round(rnorm(10, 90, 5),0) ## antiagrégant plaquettaire


indicateurs <- data.frame(finess = finessetab, Npatients=Npatients, pourcentageAAP=pourcentageAAP,
                          pourcentageExpertise=pourcentageExpertise, nometab = nometab,
                          pourcentageThrombolyse=pourcentageThrombolyse)


create_plotly <- function(indicateurs, labelindicateur,labelprecis){
  bool <- colnames(indicateurs) == labelindicateur
  if (!any(bool)){
    stop("labelindicateur non trouvé dans la dataframe indicateurs")
  }
  
  colonne <- which(bool)
  variable <- indicateurs[,colonne]
  
  ### 
  f <- list(
    family = "Courier New, monospace",
    size = 12,
    color = "#7f7f7f"
  )
  x <- list(
    title = "Nombre de patients",
    titlefont = f,
    range = c(0, 1.1*max(indicateurs$Npatients))
  )
  y <- list(
    title = labelprecis,
    titlefont = f,
    range = c(0, 100)
  )
  
  graphe <- plot_ly(indicateurs, x = indicateurs$Npatients, y=variable,
                    mode="markers", size=indicateurs$Npatients, type="scatter",
                    text=nometab) %>%
    layout(
      xaxis = x,
      yaxis = y)
  return(graphe)
}



indicateurs <- indicateurs[order(-indicateurs$Npatients),]

### radarchart :
## modifier la dataframe :
tindicateurs <- as.data.frame(t(indicateurs))
colnames(tindicateurs) <- indicateurs$nometab
bool <- rownames(tindicateurs) %in% c("pourcentageAAP","pourcentageExpertise","pourcentageThrombolyse")
tindicateurs <- tindicateurs[bool,]
for (i in 1:length(tindicateurs)){
  tindicateurs[,i] <- as.numeric(as.character(tindicateurs[,i]))
}
tindicateurs$Q25 <- NA
tindicateurs$Q75 <- NA
for (i in 1:nrow(tindicateurs)){
  tindicateurs$Q25[i] <- fivenum(as.numeric(tindicateurs[i,]))[2]
  tindicateurs$Q75[i] <- fivenum(as.numeric(tindicateurs[i,]))[4]
}
labels <- rownames(tindicateurs)


#### sankey
dfcategorie <- read.table("sankey/categories.csv",sep = "\t",header=T)
categories <- as.character(unique(dfcategorie$categorie))


