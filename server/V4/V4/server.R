
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
  
  ## Survie : 
  source("output/survie/output_survie.R",local=T)

  ## Prediction : 
  source("output/prediction/output_prediction.R",local=T)
  source("output/prediction/fonctions_prediction.R")
  
  
  # Création de tab patients :
  load("output/tabpanel/df_patient.rdata")
  colonne_id <- "patient"
  colonnes_tableau <- c("age","sexe","categorieAge","domicile","depdomicile")
  type_colonnes_tableau <- c("numeric","factor","factor","factor","factor")
  metadf <- create_metadf(colonne_id, colonnes_tableau,type_colonnes_tableau)
  filtre_patient <- new("Filtre", df = df_patient, metadf = metadf, tabsetid=999)
  
  tabpanel <- list(fonctions_tabpanel$new_tabpanel(filtre_patient))
  fonctions_tabpanel$addPatientsToTabset(tabpanel)
  jslink$moveTabpatient(tabsetName="mainTabset")
  fonctions_tabpanel$make_tableau(filtre_patient)
  fonctions_tabpanel$addplots_tabpanel(filtre_patient)
  fonctions_tabpanel$make_plots_in_tabpanel(filtre_patient)
  fonctions_tabpanel$add_observers_tabpanel(filtre_patient)
  
  observeEvent(input$addmotif,{
    cat("boutton addmotif cliqué\n")
    nom_variable <- input$newvariable
    if (nom_variable == ""){ ## améliorer cette vérification
      cat("\t libellé de la nouvelle variable : format incorrect")
      return(NULL)
    }
    
    bool <- nom_variable %in% colnames(filtre_patient$df)
    if (bool){
      cat(nom_variable, " déjà présente dans la table patient \n")
      return(NULL)
    }
    
    ### ceux qui ont le motif temporel = ceux qui ont tous les évènements : 
    
    if (length(values) == 0){
      cat("Aucun évènement sélectionné \n")
      return(NULL)
    }
    
    id_parcours <- NULL
    for (i in 1:length(values)){
      values[[i]]$event$set_df_events_selected()
      df_events_selected <- values[[i]]$event$df_events_selected
      if (!is.null(df_events_selected)){
        id_parcours <- append(id_parcours,as.character(df_events_selected$patient))
      }
    }
    if (is.null(id_parcours)){
      cat("id_parcours is null")
      return(NULL)
    }
    id_parcours <- table(id_parcours) ### si un patinet a tous les évènements il doit etre présent length(values) fois
    bool <- id_parcours == length(values)
    id_parcours <- subset (id_parcours, bool)
    if (length(id_parcours) == 0){
      cat("id parcours : aucun patient n'a tous les évènements")
      return(NULL)
    }
    bool <- filtre_patient$df$patient %in% names(id_parcours)
    n_colonnes <- length(filtre_patient$df)
    filtre_patient$df[,n_colonnes+1] <- ifelse (bool, "oui","non")
    filtre_patient$df[,n_colonnes+1] <- as.factor(filtre_patient$df[,n_colonnes+1])
    colnames(filtre_patient$df)[n_colonnes+1] <- nom_variable
    print(colnames(filtre_patient$df))
    filtre_patient$metadf$colonnes_tableau <- c(filtre_patient$metadf$colonnes_tableau,nom_variable)
    filtre_patient$metadf$type_colonnes_tableau <- c(filtre_patient$metadf$type_colonnes_tableau,"factor")
    fonctions_tabpanel$make_tableau(filtre_patient)
    updateCheckboxGroupInput(session, inputId = filtre_patient$get_checkboxid(),
                             label="Cocher pour afficher les graphiques:", 
                             choices  = filtre_patient$metadf$colonnes_tableau,
                             selected = NULL,inline=T)
  })
  
  ##### Création de l'event 0 !
  observeEvent(input$firstevent,{
    ## selon la sélection des patients : 
    patients_selection <- unique(filtre_patient$get_df_selection()$patient)
    firstevent <- subset (evenements, patient %in% patients_selection)
    values[["selection0"]]$event <<- new("Event",df_events = firstevent,event_number=0) ## création de l'objet sur le serveur
    output_tree$addTree(values[["selection0"]]$event) ## crétaion de l'ui
    treebouttonid <- values[["selection0"]]$event$get_treebouttonid()
    jslink$moveTree (treebouttonid, boolprevious=NULL)
    output_tree$make_tree_in_treeboutton(values[["selection0"]]$event, hierarchy) ## plot : création du contenu de l'ui
    jslink$hide_boutton(values[["selection0"]]$event) ## retirer certains bouttons (event 0 : boutton supprimer)
    output_tree$add_observers_treeboutton(values[["selection0"]]$event, jslink=jslink)
  })
  
})