## en attendant de mettre en place la base
load("evenements.rdata") ### voir : /flux/blazegraph/R/requete.R pour la création du fichier
evenements$type <- gsub("^(.*?)#","",evenements$type) ### retirer tout ce qu'il y a avant #
evenements <- evenements %>% group_by(patient) %>% mutate(num = row_number()) ## numéroter les évènements
evenements <- as.data.frame(evenements) ## sinon erreur bizarre
load("output/leaflet/tab_spatial.rdata")

