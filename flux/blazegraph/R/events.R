############### L'objectif de ce script est d'instancier les évènements fictifs en RDF.
### Ces évènements sont créés par le script "global.R" dans la version V3 (voir dossier server - V3)
### Ce sont des évènements du parcours de soins AVC
### Pour les transformer en RDF, on étend la CNTRO avec les concepts du domaine de l'AVC dans Protégé,
# puis on instancie dans ce script


rm(list=ls())

# Chargement des évènements
# load("listeevents.rdata")
load("listeevents_consultation.rdata") ### cette data.frame est obtenue par le scrip "global.R" 
# voir : parcoursdesoins/server/V3/V3/ pour comprendre comment ils sont créés



### compliquer le patient 1 : 
# patient1 <- subset (listeevents, patientid=="patient1" & group =="Hospitalisation")
# ajoutpatient1 <- patient1
# ajoutpatient1$start <- ajoutpatient1$start + (200*3600*24)
# ajoutpatient1$end <- ajoutpatient1$end + (200*3600*24)
# listeevents <- rbind (listeevents, ajoutpatient1)

### Transformation des variables avant instanciation :

## modification des champs time : 
listeevents$start <- gsub(" ","T",listeevents$start) ## pour etre conforme avec le type xsd:datetime
listeevents$idTimeInstantstart <- paste("time",listeevents$start,sep="") # il faut un id, une autre idée ?
listeevents$idTimeInstantstart <- gsub(":","-",listeevents$idTimeInstantstart) # : est reservé aux suffixes, on l'enlève

# pareil pour end
bool <- !is.na(listeevents$end)
listeevents$end <- ifelse (bool, gsub(" ","T",listeevents$end), NA)
listeevents$idTimeInstantend <- ifelse (bool, paste("time",listeevents$end,sep=""), NA)
listeevents$idTimeInstantend <- ifelse (bool, gsub(":","-",listeevents$idTimeInstantend), NA)
listeevents$idTimeInterval <- paste("Interval", listeevents$idTimeInstantstart,sep="")

#### events : 
## chaque évènement correspond à un type dans CNTROavc (l'extension de la CNTRO pour le domaine AVC)
# type d'events
eventstype <- read.table("eventstype.csv",sep="\t", header=T)
listeevents <- merge (listeevents, eventstype, by="nature", all.x=T)
bool <- is.na(listeevents$type)
sum(bool)
## ce sont les consultations 
listeevents$type <- as.character(listeevents$type)
listeevents$type[bool] <- "Consultation"
listeevents$type <- as.factor(listeevents$type)

listeevents$idevents <- paste (listeevents$type,listeevents$idTimeInterval, sep="") # id de l'event, une autre idée ?

## Si l'évènement est un séjourHospitalier, on mettra un attribut à l'évènement
bool <- grepl("Sejour",listeevents$type)
listeevents$etab <- ifelse (bool, paste("Etab",listeevents$finess,sep=""),NA)

## Si l'évènement est une consultation, on mettra un attribut à l'évènement
bool <- listeevents$type == "Consultation"
listeevents$consult <- ifelse (bool, paste("Medecin",listeevents$nature,sep=""),NA)


#### Création des triplets 
source("RDF.R") ## classe réalisée pour la génération de triplets
namespaces <- read.table("namespaces.csv",sep="\t", header=T, comment.char = "",
                         stringsAsFactors = F)
rdf <- new("RDF",namespaces = namespaces)

### TimeInstant et TimeInterval

patients <- unique(listeevents$patientid)
i <- "patient1"
for (i in patients){ ### les évènements de chaque patient sont traités séparément et donnent lieu à un fichier séparé
  ## les évènements de chaque patient sont stockés dans un "sous-graphe" séparé en base de données
  events <- subset (listeevents, patientid == i)
  ### StartTime :
  rdf$create_tripletspo(prefixe_sujet = "CNTROavc", sujet = events$idTimeInstantstart,
                        prefixe_predicat = "rdf", predicat = "type",
                        prefixe_objet = "CNTROavc",objet = "TimeInstant")
  
  rdf$create_tripletspl(prefixe_sujet = "CNTROavc", sujet = events$idTimeInstantstart,
                        prefixe_predicat = "CNTROavc", predicat = "hasNormalizedTime",
                        literal = events$start, typeliteral = "dateTime")
  
  ### EndTime
  rdf$create_tripletspo(prefixe_sujet = "CNTROavc", sujet = events$idTimeInstantend,
                        prefixe_predicat = "rdf", predicat = "type",
                        prefixe_objet = "CNTROavc",objet = "TimeInstant")
  
  rdf$create_tripletspl(prefixe_sujet = "CNTROavc", sujet = events$idTimeInstantend,
                        prefixe_predicat = "CNTROavc", predicat = "hasNormalizedTime",
                        literal = events$end, typeliteral = "dateTime")
  
  ### TimeInterval start
  rdf$create_tripletspo(prefixe_sujet = "CNTROavc", sujet = events$idTimeInterval,
                        prefixe_predicat = "CNTROavc", predicat = "hasStartTime",
                        prefixe_objet = "CNTROavc",objet = events$idTimeInstantstart)
  
  ### TimeInterval end 
  rdf$create_tripletspo(prefixe_sujet = "CNTROavc", sujet = events$idTimeInterval,
                        prefixe_predicat = "CNTROavc", predicat = "hasEndTime",
                        prefixe_objet = "CNTROavc",objet = events$idTimeInstantend)
  
  ### Events hasValidTime TimeInterval
  rdf$create_tripletspo(prefixe_sujet = "CNTROavc", sujet = events$idevents,
                        prefixe_predicat = "CNTROavc", predicat = "hasValidTime",
                        prefixe_objet = "CNTROavc",objet = events$idTimeInterval)
  
  ## Events rdf:type CNTROavc:Event
  rdf$create_tripletspo(prefixe_sujet = "CNTROavc", sujet = events$idevents,
                        prefixe_predicat = "rdf", predicat = "type",
                        prefixe_objet = "CNTROavc",objet = events$type)
  
  ## SejourHospitalier inEtab eig:Etab
  rdf$create_tripletspo(prefixe_sujet = "CNTROavc", sujet = events$idevents,
                        prefixe_predicat = "CNTROavc", predicat = "in",
                        prefixe_objet = "eig",objet = events$etab)
  
  ## SejourHospitalier inEtab eig:Etab
  rdf$create_tripletspo(prefixe_sujet = "CNTROavc", sujet = events$idevents,
                        prefixe_predicat = "CNTROavc", predicat = "in",
                        prefixe_objet = "eig",objet = events$consult)
  

  fichier <- paste0("../triplets/timelines/",i,".xml")
  rdf$serializeandwrite(fichier)
  rdf$resetMemory()
}


### Ces "timelines" au format RDF sont ensuite chargés dans un triplestore
# voir : chargement.R

########## partie ci-dessous est temporaire : supprimer si je n'y reviens pas
# ### je n'arrive pas à faire des constructs
# source("SPARQLqueries.R")
# queryString <- "prefix CNTROavc: <http://www.eigsante2017.fr/CNTROavc#>
# prefix eig: <http://www.eigsante2017.fr/>
# SELECT ?sejour1 ?sejour2 ?Etab1 ?Etab2 ?difftime
# {
# ?sejour1 CNTROavc:inEtab ?Etab1; # Un Sejour dans un etab
# CNTROavc:hasValidTime ?tsejour1 . # Durant une periode de temps
# ?tsejour1 CNTROavc:hasEndTime ?endsejour1 . # avec un date de fin 1
# ?endsejour1 CNTROavc:hasNormalizedTime ?dateendsejour1 . # dont la forme normalisée est
# ?sejour2 CNTROavc:inEtab ?Etab2; # Dans un Etab 2
# CNTROavc:hasValidTime ?tsejour2 . # Durant une periode de temps
# ?tsejour2 CNTROavc:hasStartTime ?startsejour2 . # avec un date de début 2
# ?startsejour2 CNTROavc:hasNormalizedTime ?datestartsejour2 . # dont la forme normalisée est
# bind( (?datestartsejour2  - ?dateendsejour1) as ?difftime ) # différence entre date de sortie 1 et date d'entrée en 2
# #FILTER(?difftime >= 0 && ?difftime < 100) # comprise entre 0 et 3 jours
# }    
# "
# query <- new("Query", rdf$world, queryString, base_uri=NULL, query_language="sparql", query_uri=NULL)
# queryResult <- executeQuery(query, rdf$model)
# result <- getNextResult(queryResult)
# result
# getQueryResultLimit(queryResult)
# redland::freeQueryResults(queryResult)
# 
# redland::executeQuery("SELECT * WHERE {?p ?s ?o}",rdf$model)



XMLtoTurtleCmmande <- "rapper -i rdfxml ../triplets/timelines/patient1.xml -o turtle > voir.ttl"
system(XMLtoTurtleCmmande)


### je devrais requeter le graphe 
# résultats => update le graphe
# je re-requête