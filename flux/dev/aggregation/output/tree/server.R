source("fonctions_tree.R")
## classes utilisées : 
source("../../classes/eventOO.R")
source("../../classes/filtreOO.r")
source("../../classes/spatialOO.R")
## hiérarchie des évènements issus de l'ontologie
load("../../hierarchy.rdata")

## en attendant de mettre en place la base
library(dplyr)
load("../../evenements.rdata")
evenements$type <- gsub("^(.*?)#","",evenements$type) ### retirer tout ce qu'il y a avant #
evenements <- evenements %>% group_by(patient) %>% mutate(num = row_number()) ## numéroter les évènements
evenements <- as.data.frame(evenements) ## sinon erreur bizarre
load("../../output/leaflet/tab_spatial.rdata")

server <- shinyServer(function(input, output, session) {
  source("../../global_server.R",local=T)
  source("../../www/js/jslink.R",local = T) ### sendCustomessages
  source("output_tree.R",local=T)
  
  ##### Création de l'event 0 !
  values[["selection0"]]$event <- new("Event",df_events = evenements,event_number=0) ## création de l'objet sur le serveur
  addTree(values[["selection0"]]$event) ## crétaion de l'ui 
  make_tree_in_treeboutton(values[["selection0"]]$event, hierarchy) ## plot : création du contenu de l'ui
  hide_boutton(values[["selection0"]]$event) ## retirer certains bouttons (event 0 : boutton supprimer)
  add_observers_treeboutton(values[["selection0"]]$event)
})
