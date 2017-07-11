rm(list=ls())
library(dplyr)

## en attendant de mettre en place la base
load("../evenements.rdata")
evenements$type <- gsub("^(.*?)#","",evenements$type) ### retirer tout ce qu'il y a avant #
evenements <- evenements %>% group_by(patient) %>% mutate(num = row_number()) ## numéroter les évènements
evenements <- as.data.frame(evenements) ## sinon erreur bizarre
event <- subset (evenements, select=c("patient","num","lieu"))
event$lieu <- gsub("eig:Medecin","",event$lieu)



load("consultation33selection.rdata")
consultation33selection <- unique(consultation33selection)
length(unique(consultation33selection$RPPS))
consultation33selection <- consultation33selection %>% group_by(RPPS) %>% mutate(id = row_number()) ## numéroter les évènements
consultation33selection <- consultation33selection[with(consultation33selection, order(RPPS,id)),]
consultation33selection <-subset (consultation33selection, id == 1)
consultation33selection$id <- NULL
ATTR_Consultation <- merge (consultation33selection, event, by.x="RPPS", by.y="lieu")
ATTR_Consultation <- as.data.frame(unclass(ATTR_Consultation))
ATTR_Consultation$num <- as.numeric(as.character(ATTR_Consultation$num))
# save(ATTR_Consultation,file="ATTR_Consultation.rdata")
# load("ATTR_Consultation.rdata")
str(ATTR_Consultation)
