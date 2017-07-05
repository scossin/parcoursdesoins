
### Table d'attributs temporaires pour une démo avant de mettre en place la base de données

library(dplyr)

## en attendant de mettre en place la base
load("../evenements.rdata")
evenements$type <- gsub("^(.*?)#","",evenements$type) ### retirer tout ce qu'il y a avant #
evenements <- evenements %>% group_by(patient) %>% mutate(num = row_number()) ## numéroter les évènements
evenements <- as.data.frame(evenements) ## sinon erreur bizarre

### Table temporaire : ATTR_SejourHospitalier
load("../output/leaflet/parcours.rdata")
SSR <- locEtab33SSR@data
UNV <- locEtab33UNV@data

etab_attr <- rbind(SSR, UNV)
etab_attr$dep <- as.numeric(substr(etab_attr$INSEE_COM,1,2))
etab_attr$categagretab <- NULL
etab_attr$categetab <- NULL
etab_attr$libcategagretab <- NULL
colnames(etab_attr)[3] <- "RaisonSociale"
etab_attr$siret <- NULL
etab_attr$nofinessej <- NULL


event <- subset (evenements, select=c("patient","num","lieu"))
event$lieu <- gsub("eig:Etab","",event$lieu)
ATTR_SejourHospitalier <- merge (etab_attr, event, by.x="nofinesset", by.y="lieu")
ATTR_SejourHospitalier$SSRadulte <- sample(c("oui","non"), nrow(ATTR_SejourHospitalier),replace = T)
ATTR_SejourHospitalier$SSRenfant <- sample(c("oui","non"), nrow(ATTR_SejourHospitalier),replace = T)
ATTR_SejourHospitalier$UNV <- "oui"

ATTR_SejourHospitalier$SSRadulte <- as.factor(ATTR_SejourHospitalier$SSRadulte)
ATTR_SejourHospitalier$SSRenfant <- as.factor(ATTR_SejourHospitalier$SSRenfant)
ATTR_SejourHospitalier$UNV <- as.factor(ATTR_SejourHospitalier$UNV)
ATTR_SejourHospitalier$INSEE_COM <- as.factor(ATTR_SejourHospitalier$INSEE_COM)

save(ATTR_SejourHospitalier,file="ATTR_SejourHospitalier.rdata")

# colonnes_SejourHospitalier <- c("nofinesset","RaisonSociale","libcategetab","dep","INSEE_COM")
# colonnes_SejourMCO <- c("UNV")
# colonnes_SSR <- c("SSRadulte","SSRenfant")
