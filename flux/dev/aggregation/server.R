
server <- shinyServer(function(input, output, session) {
  ## variables et fonctions locales propres à la gestion du fonctionnement de l'application
  source("global_server.R",local=T)
  source("global_data.R")
  
  ## hiérarchie des évènements issus de l'ontologie
  load("hierarchy.rdata")
  
  source("www/js/jslink.R",local = T) ### sendCustomessages
  
  ## classes utilisées : 
  source("classes/eventOO.R")
  source("classes/filtreOO.r")
  source("classes/spatialOO.R")

  ### leaflet :
  source("output/leaflet/fonctions_leaflet.R")
  source("output/leaflet/global_leaflet.R")
  source("output/leaflet/output_leaflet.R",local = T)
  
  ### tabpanel :
  source("output/tabpanel/fonctions_tabpanel.R",local = T)
  source("output/tabpanel/fonctions_graphiques.R")
  
  ### tree : 
  source("output/tree/output_tree.R",local=T)
  source("output/tree/fonctions_tree.R")
  
  ## Sankey
  source("output/sankey/output_sankey.R",local=T)
  source("output/sankey/fonctions_sankey.R")
  
  ##### Création de l'event 0 !
  values[["selection0"]]$event <- new("Event",df_events = evenements,event_number=0) ## création de l'objet sur le serveur
  addTree(values[["selection0"]]$event) ## crétaion de l'ui
  treebouttonid <- values[["selection0"]]$event$get_treebouttonid()
  moveTree (treebouttonid, boolprevious=NULL)
  make_tree_in_treeboutton(values[["selection0"]]$event, hierarchy) ## plot : création du contenu de l'ui
  hide_boutton(values[["selection0"]]$event) ## retirer certains bouttons (event 0 : boutton supprimer)
  add_observers_treeboutton(values[["selection0"]]$event)
  
  
  
  # Création de tab dess patients :
  load("output/tabpanel/df_patient.rdata")
  colonne_id <- "patient"
  colonnes_tableau <- c("age","sexe","categorieAge","domicile","depdomicile")
  type_colonnes_tableau <- c("numeric","factor","factor","factor","factor")
  metadf <- create_metadf(colonne_id, colonnes_tableau,type_colonnes_tableau)
  filtre <- new("Filtre", df = df_patient, metadf = metadf, tabsetid=999)
  tabpanel <- list(new_tabpanel(filtre))
  addPatientsToTabset(tabpanel)
  session$sendCustomMessage(type = "addPatientsToTabset", message = list(tabsetName = "mainTabset"))
  make_tableau(filtre)
  addplots_tabpanel(filtre)
  make_plots_in_tabpanel(filtre)
  add_observers_tabpanel(filtre)
})