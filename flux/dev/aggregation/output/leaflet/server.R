
source("global_leaflet.R")

### leaflet dépend du choix de l'event 0 de l'utilisateur
library(dplyr)
library(sqldf)
load("../../evenements.rdata")
source("fonctions_leaflet.R")
evenements$type <- gsub("^(.*?)#","",evenements$type) ### retirer tout ce qu'il y a avant #
evenements <- evenements %>% group_by(patient) %>% mutate(num = row_number()) ## numéroter les évènements
evenements <- as.data.frame(evenements) ## sinon erreur bizarre
source("../../classes/eventOO.R")
source("../../classes/filtreOO.r")
source("../../classes/spatialOO.R")
load("../../hierarchy.rdata")

## fonction : get_df_type_selected
source("../../output/tree/fonctions_tree.R")
load("../../output/tabpanel/df_patient.rdata")


function(input, output, session){
  values = list()
  
  ## créatoin de l'event 0 à l'initialisation
  values[["selection0"]]$event <- new("Event",df_events = evenements,event_number=0)
  ### L'utilisateur choisit les events à 0
  choix <- c("SejourMCO","SejourSSR")
  df_type_selected <- get_df_type_selected(hierarchy = hierarchy, choix = choix)
  values[["selection0"]]$event$set_df_type_selected(df_type_selected = df_type_selected)
  values[["selection0"]]$event$set_df_events_selected() ## cette fonction crée 
  
  source("output_leaflet.R",local = T)
}