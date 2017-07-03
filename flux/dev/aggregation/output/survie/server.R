library(dplyr)
library(sqldf)
source("../../classes/eventOO.R")
source("../../classes/filtreOO.r")
source("../../classes/spatialOO.R")

## fonction : get_df_type_selected
source("../../output/tree/fonctions_tree.R")
load("../../hierarchy.rdata")

load("../../evenements.rdata")
evenements$type <- gsub("^(.*?)#","",evenements$type) ### retirer tout ce qu'il y a avant #
evenements <- evenements %>% group_by(patient) %>% mutate(num = row_number()) ## numéroter les évènements
evenements <- as.data.frame(evenements) ## sinon erreur bizarre

server <- shinyServer(function(input, output, session) {
  source("../../global_server.R", local=T)
  source("output_survie.R",local=T)
  
  ## création de l'event 0
  values[["selection0"]]$event <- new("Event",df_events = evenements,event_number=0)
  choix <- c("Appel")
  df_type_selected <- fonctions_tree$get_df_type_selected(hierarchy = hierarchy, choix = choix)
  values[["selection0"]]$event$set_df_type_selected(df_type_selected = df_type_selected)
  
  ## création de l'event 1 
  df_next <- values[["selection0"]]$event$set_df_nextprevious_events(boolnext=T)
  values[["selection1"]]$event <- new("Event",df_events = df_next,event_number=1)
  choix <- c("Traitement")
  df_type_selected <- fonctions_tree$get_df_type_selected(hierarchy = hierarchy, choix = choix)
  values[["selection1"]]$event$set_df_type_selected(df_type_selected = df_type_selected)
  
  # Création de tab patients :
  load("../tabpanel/df_patient.rdata")
  colonne_id <- "patient"
  colonnes_tableau <- c("age","sexe","categorieAge","domicile","depdomicile")
  type_colonnes_tableau <- c("numeric","factor","factor","factor","factor")
  metadf <- create_metadf(colonne_id, colonnes_tableau,type_colonnes_tableau)
  filtre_patient <- new("Filtre", df = df_patient, metadf = metadf, tabsetid=999)
})
