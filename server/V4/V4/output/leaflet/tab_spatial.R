library(dplyr)
#rm(list=ls())

############ Création de la tab_spatial
### Cette table est précalculée et stockée
## elle contient la séquence spatiale des évènements pour l'affichage cartographique

## fonction qui détermine la séquence spatiale à partir d'une liste d'events : 
# à réfléchir ce qu'on veut afficher spatialement
# choix arbitaire : algo : si plus de 2 jours entre 2 évènements alors le patient est rentré à domicile
load("../../evenements.rdata")
evenements$type <- gsub("^(.*?)#","",evenements$type) ### retirer tout ce qu'il y a avant #
evenements <- evenements %>% group_by(patient) %>% mutate(num = row_number()) ## numéroter les évènements
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

### récupérer les types : domicile / etablissement 
colnames(sequencespatial3)
car <- table(nchar(sequencespatial3$to))
bool <- nchar(sequencespatial3$to) == 5
sequencespatial3$typeto <- ifelse (bool, "dom","etab")
bool <- nchar(sequencespatial3$from) == 5
sequencespatial3$typefrom <- ifelse (bool, "dom","etab")
sequencespatial3$typedeparcours <- paste(sequencespatial3$typeto, sequencespatial3$typefrom,sep="-")
table(sequencespatial3$typedeparcours)
# sequencespatial3$typeto <- NULL
# sequencespatial3$typefrom <- NULL
# sequencespatial3$to <- NULL
# sequencespatial3$from <- NULL
sequencespatial3 <- sequencespatial3[with(sequencespatial3,order(patient,num)),]

tab_spatial <- sequencespatial3
# save(tab_spatial, file="tab_spatial.rdata")
