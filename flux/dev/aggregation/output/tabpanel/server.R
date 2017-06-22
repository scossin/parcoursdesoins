library(DT)

source("../../classes/filtreOO.r")
source("fonctions_graphiques.R")
load("df_patient.rdata")
colonne_id <- "patient"
colonnes_tableau <- c("age","sexe","categorieAge","domicile","depdomicile")
type_colonnes_tableau <- c("numeric","factor","factor","factor","factor")

metadf <- create_metadf(colonne_id, colonnes_tableau,type_colonnes_tableau)

filtre <- new("Filtre", df = df_patient, metadf = metadf, tabsetid=0)

function(input, output, session){
  source("fonctions_tabpanel.R", local = T)
  tabpanel <- list(new_tabpanel(filtre))
  addPatientsToTabset(tabpanel, "mainTabset")
  make_tableau(filtre)
  addplots_tabpanel(filtre)
  make_plots_in_tabpanel(filtre)
  add_observers_tabpanel(filtre)
}
