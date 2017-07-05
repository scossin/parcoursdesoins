rm(list=ls())
library(sqldf)
library(dplyr)
source("classes/eventOO.R")
source("classes/spatialOO.R")
source("global.R") ## contient les fonctions sur les hiérarchies
#source("global.R")
load("hierarchy.rdata")
load("evenements.rdata")

source("../../tabpanel/filtreOO.r")

###  chargement de données fictives de filtre : 

df_events <- evenements
df_events$type <- gsub("^(.*?)#","",df_events$type) ### retirer tout ce qu'il y a avant #
df_events <- df_events %>% group_by(patient) %>% mutate(num = row_number())
df_events <- as.data.frame(df_events) ## sinon erreur bizarre

event <- new("Event",df_events = df_events,event_number = 0)

### l'utilisateur doit sélectionner une liste d'events dans la hiérarchie
hierarchy ## hiérarchy
event$get_tree_events(hierarchy = hierarchy) ## hiérarchy avec le nombre d'évents
event$set_df_nextprevious_events() ## pas d'events sélectionnés encore
event$set_df_events_selected()

## choix dans la hiérarchie
choix <- c("SejourMCO","SejourSSR")
choix <- c("SejourSSR")
df_type_selected <- get_df_type_selected(hierarchy = hierarchy, choix = choix)

event$set_df_type_selected(df_type_selected = df_type_selected)
event$set_df_events_selected()
## 
load("output/leaflet/tab_spatial.rdata")
event$set_spatial()
event$spatial$df_transfert_entree
event$spatial$df_transfert_sortie
event$spatial$N_events_selected
event$spatial$N_transfert_sortie
event$spatial$N_transfert_entree
event$df_type_selected


event$set_df_nextprevious_events(boolnext = T)
event$df_next_events
event$set_df_nextprevious_events(boolnext = F)

## event$df_next_events
# events_selected <- event$get()
# type_selected <- events_selected


values <- list()
values[["selection0"]] <- event
values[["selection1"]] <- event
event$get_event_number()

event$df_previous_events <- data.frame(patient=character(), type=factor())
previousevent <- new("Event",df_events=event$df_previous_events,2)
previousevent$get_tree_events(hierarchy)
previousevent$df_events
