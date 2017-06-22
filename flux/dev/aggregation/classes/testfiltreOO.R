rm(list=ls())
load("../output/tabpanel/df_patient.rdata")
source("../output/tabpanel/create_metadf.R")
source("filtreOO.r")

colonne_id <- "patient"
colonnes_tableau <- c("age","sexe","categorieAge","domicile","depdomicile")
type_colonnes_tableau <- c("numeric","factor","factor","factor","factor")

metadf <- create_metadf(colonne_id, colonnes_tableau,type_colonnes_tableau)

filtre <- new("Filtre", df = df_patient, metadf = metadf, tabsetid=0)


###
checkbox_clics <- filtre$checkbox_clics
ajout <- "age"
filtre$set_checkbox_clics(c(checkbox_clics,ajout)) ## ajout de la checkbox cliqué
filtre$set_deleted_last(FALSE)

filtre$get_plot_output_list()
filtre$graphiques




