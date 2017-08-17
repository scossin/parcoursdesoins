
rm(list=ls())

# Chargement des évènements
# load("listeevents.rdata")
load("listeevents_consultation.rdata") ### cette data.frame est obtenue par le scrip "global.R" 
# voir : parcoursdesoins/server/V3/V3/ pour comprendre comment ils sont créés


eventstype <- read.table("eventstype.csv",sep="\t", header=T)
listeevents <- merge (listeevents, eventstype, by="nature", all.x=T)
bool <- is.na(listeevents$type)
listeevents$start <- format(listeevents$start, "%Y_%m_%d_%H_%M_%S")
listeevents$end <- format(listeevents$end, "%Y_%m_%d_%H_%M_%S")
sum(bool)
## ce sont les consultations 
listeevents$type <- as.character(listeevents$type)
listeevents$type[bool] <- "Consultation"
listeevents$type <- as.factor(listeevents$type)
listeevents$patientid <- gsub("patient","p", listeevents$patientid)
colnames(listeevents)

### sélection d'un seul patient : 
addPredicateValue <- function(df, contexte, variable, relation){
  ajout <- subset (df, patientid %in% contexte, select=c("patientid", "type", "start", variable))
  ajout$predicate <- relation
  ajout <- ajout[,c(1,2,3,5,4)]
  colnames(ajout)[5] <- "value"
  ajout[,5] <- as.character(ajout[,5])
  return(ajout)
}

contexte <- paste0("p",1:1000)

bool <- is.na(listeevents$end)
listeevents$end <- ifelse(bool, listeevents$start, listeevents$end)

## hasEnd and hasBeginning
hasEnd <- addPredicateValue(listeevents, contexte,"end","hasEnd")
hasBeginning <- addPredicateValue(listeevents, contexte,"start","hasBeginning")

## description hospitalisation
hospit <- subset(listeevents, group=="Hospitalisation")
inEtab <- addPredicateValue(hospit, contexte,"finess","inEtab")

## description consultation : 
consultation <- subset(listeevents, group=="Consultation")
inDoctor <- addPredicateValue(consultation, contexte,"nature","inDoctor")
write.table(inDoctor,"inDoctor.csv",sep="\t",col.names = F, row.names = F,quote=F)


allRelations <- rbind (hasEnd, hasBeginning, inEtab,inDoctor)
write.table(allRelations,"allRelations.csv",sep="\t",col.names = F, row.names = F,quote=F)

####

## description 
table(listeevents$group)
table(hasEnd$type)

## description 
allRelations <- rbind (hasEnd, hasBeginning, inEtab)
write.table(hospitToCSV,"hospitToCSV.csv",sep="\t",col.names = F, row.names = F,quote=F)

table(hasEnd$patientid)

p1 <- rbind(hasEnd, hasBeginning)
p1 <- subset (p1, !is.na(value))
write.table(p1,"p1.csv",sep="\t",col.names = F, row.names = F,quote=F)

temp <- subset (listeevents,select=c("patientid","type","start","start"))
temp$predicat <- "hasBeginning"
colnames(temp)[4] <- "value"
temp <- subset (temp, select=c("patientid","type","start","predicat","value"))
table(temp$type)

temp <- subset (temp, type %in% c("SejourMCO","Consultation"))
temp <- temp[sample(1:nrow(temp),100,replace=F),]

str(temp)
write.table(temp,"test.csv",sep="\t",col.names = F, row.names = F,quote=F)
table(temp$patientid)