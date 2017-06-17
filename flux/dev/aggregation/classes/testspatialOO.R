rm(list=ls())
load("output/leaflet/tab_spatial.rdata")
source("classes/spatialOO.R")
df_selection <- tab_spatial[1:20,]
df_selection <- unique(df_selection)

##
spatial <- new("spatial", tab_spatial = tab_spatial, df_selection=df_selection)

spatial$df_transfert_entree
spatial$df_transfert_sortie
spatial$N_transfert_entree
spatial$N_transfert_sortie
spatial$N_events_selected

load("output/tabpanel/df_patient.rdata")
spatial$get_zone_chalandise(df_patient = df_patient, df_events_selected = df_patient)