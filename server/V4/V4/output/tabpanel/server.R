library(DT)

source("../../classes/filtreOO.r")
source("fonctions_graphiques.R")
load("df_patient.rdata")
colonne_id <- "patient"
colonnes_tableau <- c("age","sexe","categorieAge","domicile","depdomicile")
type_colonnes_tableau <- c("numeric","factor","factor","factor","factor")

metadf <- create_metadf(colonne_id, colonnes_tableau,type_colonnes_tableau)

filtre <- new("Filtre", df = df_patient, metadf = metadf, tabsetid=0)

options(shiny.trace=TRUE)

function(input, output, session){
  source("../../www/js/jslink.R",local=T)
  source("fonctions_tabpanel.R", local = T)
  tabpanel <- list(fonctions_tabpanel$new_tabpanel(filtre)) ## créer le tabpanel sur le serveur
  fonctions_tabpanel$addPatientsToTabset(tabpanel) ## envoie le tabpanel sur l'ui 
  jslink$moveTabpanel(event_number = filtre$tabsetid, tabsetName = "mainTabset") ## modif de place
  fonctions_tabpanel$make_tableau(filtre) ## fait le tableau
  fonctions_tabpanel$addplots_tabpanel(filtre) ## ajout les plots (ui) selon les sélections
  fonctions_tabpanel$make_plots_in_tabpanel(filtre) ## fait les plots
  fonctions_tabpanel$add_observers_tabpanel(filtre) ## observers sur tableau et checkbox
}
