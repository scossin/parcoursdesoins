observeEvent(input$goprediction,{
  cat("Bouton prediction cliqué \n")
  
  # values ne devrait pas etre null car il est initialisé
  if (length(values) < 2 | length(values) > 2){
    cat("\n prediction impossible à calculer : sélectionner 2 évènements \n")
    return(NULL)
  }
  
  # i <- 2
  # y <- 1
  df_prediction <- NULL
  events_name <- NULL
  ### jointure pour faire un difftime 
  for (i in 1:length(values)){
    filtres <- values[[i]]$event$filtres
    events_name <- append(events_name, unique(as.character(values[[i]]$event$df_type_selected$agregat)))
    if (length(filtres) == 0){
      next
    }
    
    values[[i]]$event$set_df_events_selected()
    df_events_selected <- values[[i]]$event$df_events_selected
    
    ### revoir mon objet filtre qui est mal fait 
    # for (y in 1:length(filtres)){
    ### check : un seul evenement par id
    #colonne_id <- filtres[[y]]$metadf$colonne_id
    #colonne <- which(colnames(filtres[[y]]$df) == colonne_id)
    colonne_id <- "patient"
    valeurs_id <- df_events_selected$patient
    bool <- length(valeurs_id) == length(unique(valeurs_id))
    if (!bool){
      cat("Event ", i, " : plusieurs évènements par patient")
      return(NULL)
    }
    
    colonnes <- c(colonne_id, "datestartevent")
    ajout <- subset (df_events_selected, select=colonnes)
    if (is.null(df_prediction)){ ## si c'est la première itération
      df_prediction <- ajout
    } else {
      colnames(ajout) <- c(colonne_id,"datestartevent2") ## change 
      df_prediction <- merge (df_prediction, ajout, by=colonne_id, all.x=T)
    }
  }
  
  bool <- c("datestartevent","datestartevent2") %in% colnames(df_prediction)
  if (!all(bool)){
    stop("\t Problème pour prediction : datestartevent et datestartevent2 non présents dans df_prediction")
  }
  
  ## datestartevent2 est NA lors la jointure si un patient n'a pas d'evévènement
  bool <- !is.na(df_prediction$datestartevent2)
  df_prediction$event <- ifelse(bool, 1, 0)
  
  if (length(table(df_prediction$event)) == 1){
    cat("\t prédiction : tous les patients ont l'évènement")
    return(NULL)
  }
  
  # groupe <- "sexe"
  groupe <- input[["prediction_radiobutton_0"]]
  if (is.null(groupe) || groupe == "aucun"){
    cat("\t Aucun évènement sélectionné")
    return(NULL)
  }
  
  cat("\t", groupe, "choisit pour l'analyse de prédiction \n")
  ## récupère la colonne :
  colonnes <- c("patient",groupe)
  ###### dans tab patient ? 
  bool <- groupe %in% colnames(filtre_patient$df)
  if (bool){
    ajout <- subset (filtre_patient$df, select=c(colonnes))
  } else {
    df_events_selected <- values[[1]]$event$df_events_selected
    ajout <- subset (df_events_selected, select=colonnes)
  }
  df_prediction <- merge (df_prediction, ajout, by="patient", all.x=T)
  
  colonne_x <- which(colnames(df_prediction) == groupe)
  if (is.factor(df_prediction[,colonne_x])){
    df_prediction[,colonne_x] <- as.factor(as.character(df_prediction[,colonne_x] ))
    x <- df_prediction[,colonne_x] 
    if (length(table(x)) ==1){
      cat("\t une seule catégorie pour la variable x en prédiction")
      return(NULL)
    }
    if (length(table(x)) > 4){
      cat("\t maximum 4 catégories pour la variable x en prédiction")
      return(NULL)
    }
  }
 
  output$courbeprediction <- renderPlot({
    fonctions_prediction$graphiques_comparaison(df_prediction, df_prediction$event, colonne_x)
  })
})


observeEvent(input$updateprediction,{
  ### fonctionnalités similaires à celle du Sankey
  cat("Bouton update de prediction cliqué \n")
  liste <- NULL
  
  # values ne devrait pas etre null car il est initialisé
  if (length(values) == 0){
    cat("\n Values de longueur NULL \n")
    return(NULL)
  }
  
  ## colonnes de la tab_patient
  colonnes_patient <- filtre_patient$metadf$colonnes_tableau
  bool <- filtre_patient$metadf$type_colonnes_tableau %in% c("factor", "numeric")
  colonnes_patient <- colonnes_patient[bool]
  
  ## récupère les colonnes de chaque filtre :
  # type_event <- unique(as.character(values[[1]]$event$df_type_selected$agregat))
  filtres <- values[[1]]$event$filtres
  if (length(filtres) == 0){
    next
  }
  for (y in 1:length(filtres)){
    event_number <- filtres[[y]]$tabsetid
    colonnes_tableau <- filtres[[y]]$metadf$colonnes_tableau
    ## que les colonnes factors sur le sankey : 
    type_colonnes_tableau <- filtres[[y]]$metadf$type_colonnes_tableau
    bool <- type_colonnes_tableau %in% c("factor", "numeric")
    colonnes_tableau <- colonnes_tableau[bool]
    colonnes_tableau <- c(colonnes_tableau, colonnes_patient)
    ## ajout : aucun : 
    # colonnes_tableau <- c("aucun",colonnes_tableau)
    if (length(colonnes_tableau) != 0){
      liste <- c(liste, create_prediction_radiobutton(colonnes_tableau,event_number)) 
    }
  }
  if (is.null(liste)){
    cat ("\t Aucune sélection d'event réalisée pour créer un sankey \n")
    return(NULL)
  }
  
  shiny::removeUI(selector = "#prediction_explication > div")
  insertUI(selector = "#prediction_explication",ui = do.call(tagList, liste),where = "beforeEnd")
})

create_prediction_radiobutton <- function(colonnes_tableau, event_number){
  id <- paste0("prediction_radiobutton_0")
  ui <- shiny::radioButtons(id, label="",choices = colonnes_tableau, inline = T)
  #ajoutdiv <- paste0("<div id=treeboutton",n," value='",n,"' class='box'>") ## value permet de savoir la position de l'event
  liste <- list(HTML("<div><h4> Choisissez un groupe pour l'analyse de prediction : </h4>"), ui , HTML("</div>"))
  return(liste)
}