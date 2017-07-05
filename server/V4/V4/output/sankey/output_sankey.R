############ L'utilisateur demande la réalisation du Sankey :
observeEvent(input$go,{
  cat("Bouton go de Sankey cliqué \n")
  
  ## récupérer le choix de l'utilisateur des radiobouttons : 
  numeros <- get_event_numbers(values) ## liste des events créés
  df_sankey <- NULL
  for (num_event in numeros){
    cat("\t num_event : ", num_event, "\n")
    radio_button <- paste0("sankey_radiobutton_",num_event)
    if (is.null(input[[radio_button]])){ ### pas de radio_button coché
      next
    } else {
      choix_colonne <- input[[radio_button]]
      ## récupère df_events_selected pour chaque event :
      event <- values[[paste0("selection",num_event)]]$event
      event$set_df_events_selected() ## mise à jour si filtre modifié
      
      ## colonne du filtre ou colonne patient ? 
      bool <- choix_colonne %in% colnames(filtre_patient$df)
      if (bool){
        df_events_selected <- subset (filtre_patient$df, select=c("patient",choix_colonne))
      } else {
        df_events_selected <- subset (event$df_events_selected, select=c("patient",choix_colonne))
      }
      
      colnames(df_events_selected) <- c("patient",paste0("event",num_event))
      if (is.null(df_sankey)){ ## si c'est la première itération
        df_sankey <- df_events_selected
      } else {
        df_sankey <- merge (df_sankey, df_events_selected, by="patient", all.x=T)
      }
    }
  }
  ### plusieurs types de sankey disponibles : 
  isolate ({
    bool <- input$sankey_type == "V1"
    if (bool){
      V1 <- T
      V2 <- F
    } else {
      V1 <- F
      V2 <- T
    }
  })
  if (is.null(df_sankey)){
    cat ("\t Sankey non réalisé : df_sankey is null \n")
    return(NULL)
  }
  df_sankey$patient <- NULL ## on ne garde que les évènements
  cat("\t colonnes de df_sankey : ", colnames(df_sankey), "\n")
  if (length(df_sankey)<2){
    cat ("\t Sankey non réalisé : df_sankey a moins de 2 colonnes \n")
    return(NULL)
  }
  output$sankey <- sankeyD3::renderSankeyNetwork({
    make_sankey(df_sankey, V1=V1, V2=V2)
  })
  #save(df_sankey, file="df_sankey2.rdata") ## pour le débogage
  cat("\t Sankey réalisé \n")
})



#### Offrir à l'utilisateur de choisir les variables à afficher sur le sankey :
## ces variables sont récupérées des filtres
observeEvent(input$update,{
  cat("Bouton update de Sankey cliqué \n")
  liste <- NULL
  
  # values ne devrait pas etre null car il est initialisé
  if (length(values) == 0){
    cat("\n Values de longueur NULL \n")
    return(NULL)
  }
  
  ## colonnes de la tab_patient
  colonnes_patient <- filtre_patient$metadf$colonnes_tableau
  bool <- filtre_patient$metadf$type_colonnes_tableau == "factor"
  colonnes_patient <- colonnes_patient[bool]
  
  ## récupère les colonnes de chaque filtre :
  for (i in 1:length(values)){
    type_event <- as.character(unique(values[[i]]$event$df_type_selected$agregat))
    filtres <- values[[i]]$event$filtres
    if (length(filtres) == 0){
      next
    }
    for (y in 1:length(filtres)){
      event_number <- filtres[[y]]$tabsetid
      colonnes_tableau <- filtres[[y]]$metadf$colonnes_tableau
      ## que les colonnes factors sur le sankey : 
      type_colonnes_tableau <- filtres[[y]]$metadf$type_colonnes_tableau
      bool <- type_colonnes_tableau == "factor"
      colonnes_tableau <- colonnes_tableau[bool]
      colonnes_tableau <- c(colonnes_tableau, colonnes_patient)
      if (length(colonnes_tableau) != 0){
        liste <- c(liste, create_sankey_radiobutton(colonnes_tableau,event_number, type_event)) 
      }
    }
  }
  if (is.null(liste)){
    cat ("\t Aucune sélection d'event réalisée pour créer un sankey \n")
    return(NULL)
  }
  liste <- liste[order(unlist(liste),decreasing=F)] ## ordonne la liste des events
  ## autant de removeUI que de filtres
  for (i in 1:length(values)){
    cat("on retire \n")
    shiny::removeUI(selector = "#sankey_explication > div")
  }
  insertUI(selector = "#sankey_explication",ui = do.call(tagList, liste),where = "beforeEnd")
})