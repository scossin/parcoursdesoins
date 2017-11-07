
rm(list=ls())

# Chargement des évènements
# load("listeevents.rdata")
load("listeevents_consultation.rdata") ### cette data.frame est obtenue par le scrip "global.R" 
# voir : parcoursdesoins/server/V3/V3/ pour comprendre comment ils sont créés


eventstype <- read.table("eventstype.csv",sep="\t", header=T)
listeevents <- merge (listeevents, eventstype, by="nature", all.x=T)

### date de début après date de fin ! : inversion
bool <- listeevents$start > listeevents$end & !is.na(listeevents$end)
sum(bool,na.rm = T)
SSR <- subset (listeevents,bool)
listeevents <- subset(listeevents,!bool)
colnames(SSR) <- c("nature","patientid","id","finess","end","start","group","type")
listeevents <- rbind(listeevents, SSR)

###
bool <- is.na(listeevents$type)
sum(bool)
listeevents$start <- format(listeevents$start, "%Y_%m_%d_%H_%M_%S")
listeevents$end <- format(listeevents$end, "%Y_%m_%d_%H_%M_%S")

## ce sont les consultations 
listeevents$type <- as.character(listeevents$type)
listeevents$type[bool] <- "Consultation"
listeevents$type <- as.factor(listeevents$type)
listeevents$patientid <- gsub("patient","p", listeevents$patientid)
table(listeevents$type)

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

## has price
listeevents$price <- NA
bool <- listeevents$group == "Hospitalisation"
listeevents$price[bool] <- sample(rnorm(100,2500,500),size=sum(bool),replace = T)
listeevents$price <- round(listeevents$price, 1)

bool <- is.na(listeevents$end)
listeevents$end <- ifelse(bool, listeevents$start, listeevents$end)

## hasEnd and hasBeginning
hasEnd <- addPredicateValue(listeevents, contexte,"end","hasEnd")
hasBeginning <- addPredicateValue(listeevents, contexte,"start","hasBeginning")

## description hospitalisation
hospit <- subset(listeevents, group=="Hospitalisation")
inEtab <- addPredicateValue(hospit, contexte,"finess","inEtab")
inEtab$value <- paste0("Etablissement",inEtab$value)

## prix des events : 
hasPrice <- addPredicateValue(hospit, contexte,"price","hasPrice")

## description consultation : 
consultation <- subset(listeevents, group=="Consultation")
inDoctor <- addPredicateValue(consultation, contexte,"nature","inDoctor")
inDoctor$value <- paste0("RPPS",inDoctor$value)
#write.table(inDoctor,"inDoctor.csv",sep="\t",col.names = F, row.names = F,quote=F)

hasDP <- subset (inEtab, type=="SejourMCO")
hasDP$predicate <- "hasDP"
codesCIM10 <- c("I61","I62","I63","A09","I10")
hasDP$value <- sample(codesCIM10,size=nrow(hasDP),replace = T)
allRelations <- rbind (hasEnd, hasBeginning, inEtab,inDoctor,hasPrice,hasDP)
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