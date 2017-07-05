library(survival)
library(shiny)
observeEvent(input$gosurvie,{
  cat("Bouton survie cliqué \n")

  # values ne devrait pas etre null car il est initialisé
  if (length(values) < 2 | length(values) > 2){
    cat("\n Survie impossible à calculer : sélectionner 2 évènements \n")
    return(NULL)
  }
  
  # i <- 2
  # y <- 1
  df_survie <- NULL
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
      if (is.null(df_survie)){ ## si c'est la première itération
        df_survie <- ajout
      } else {
        colnames(ajout) <- c(colonne_id,"datestartevent2") ## change 
        df_survie <- merge (df_survie, ajout, by=colonne_id, all.x=T)
      }
  }
  
    bool <- c("datestartevent","datestartevent2") %in% colnames(df_survie)
    if (!all(bool)){
      stop("\t Problème pour survie : datestartevent et datestartevent2 non présents dans df_survie")
    }
    
    ## datestartevent2 est NA lors la jointure si un patient n'a pas d'evévènement
    bool <- !is.na(df_survie$datestartevent2)
    df_survie$event <- ifelse(bool, 1, 0)
   
    date_last_event <- as.POSIXct(max(evenements$dateendevent, na.rm = T)) ## 
    df_survie$datestartevent2 <- ifelse (bool, df_survie$datestartevent2,
                                         date_last_event) ## date du dernier event dans la base
    df_survie$datestartevent2 <- as.POSIXct(df_survie$datestartevent2, origin = "1970-01-01") ## car NA présents
    
    df_survie$diff_time <- as.numeric(difftime (df_survie$datestartevent2, df_survie$datestartevent,units = "days"))
  
    surv_objet <- Surv(df_survie$diff_time, event=df_survie$event)
    

    ## analyse de survie par groupe ?
    
    groupe <- input[["survie_radiobutton_0"]]
    if (is.null(groupe) || groupe == "aucun"){ # premier cas de figure : aucun groupe sélectionné :
      my.fit <- survfit(surv_objet~1)
      if (length(events_name) != 2){
        stop("events_name longueur différent de 2 pour courbe de survie")
      }
      titre <- paste0("Délai de survenue de \"", events_name[2], "\" à partir de \"", events_name[1], "\"")
      ylab_name <- paste0("Pourcentage de patients sans ", events_name[2])
      
      output$courbesurvie <- renderPlot({
        plot(my.fit, xlab="jours", ylab=ylab_name, col="blue",
             main=titre,conf.int = T,mark.time = T)
      })
      
#      tab <- read.table(textConnection(capture.output(my.fit)),skip=2,header=TRUE)
      
    } else {  # 2ème cas de figure : un groupe sélectionné :
      cat("\t", groupe, "choisit pour l'analyse de survie \n")
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
      df_survie <- merge (df_survie, ajout, by="patient", all.x=T)
      palette <- c("blue","red","green","orange")
      
      nom_variable <- colnames(df_survie)[length(df_survie)]
      x <- df_survie[,length(df_survie)]
      x <- as.factor(as.character(x))
      n <- length(table(x))
      if (n > 4){
        cat("\t Nombre de catégories limitées à 4 pour la survie \n")
        return(NULL)
      }
      my.fit <- survfit(surv_objet ~ x)
      couleurs <- palette[1:n]
      if (length(events_name) != 2){
        stop("events_name longueur différent de 2 pour courbe de survie")
      }
      titre <- paste0("Délai de survenue de \"", events_name[2], "\" à partir de \"", events_name[1], "\"",
                      "\n en fonction de \"", groupe, "\"")
      ylab_name <- paste0("Pourcentage de patients sans ", events_name[2])
      output$courbesurvie <- renderPlot({
        
      plot(my.fit, col=couleurs, xlab="jours", ylab=ylab_name,
           main=paste0(titre, "(NA=",sum(is.na(x)),")"),mark.time = T)
      legend("bottomleft",legend=levels(x), col=palette,
             bty="n", lty=1)
      })
      
      ### test de logrank
      if (n > 1){ ## test seulement si plus de 2 catégories
        test <- survdiff(surv_objet ~ x)
        # tab$variable <- nom_variable
        dof <- n - 1
        logrank <- paste ("(log-rank, p = ", signif (1 - pchisq (test$chisq, df=dof), 3), ")",sep="")
      }

    } ## fin else : groupe choisit
    
    cat ("\t Survie ploté \n")

    # save(my.fit, file="my.fit.rdata")
    #load("my.fit.rdata")
    ### afficher le tableau : 
    tab <- summary(my.fit)$table
    if (length(dimnames(tab)) == 0){ ## étape intermédiaire si aucun groupe pour transformation df
     colonnes <- names(tab)
     tab <- matrix(as.numeric(tab), nrow=1)
     tab <- as.data.frame(tab)
     colnames(tab) <- colonnes
    }
    tab <- subset (tab, select=c("records","events","median","0.95LCL","0.95UCL"))
    tab[] <- apply(tab,2, function(x) round(x,0))
    rownames(tab) <- gsub("^x=","",rownames(tab))
    colnames(tab)[1] <- "N"
    cat ("Tableau affiché")
    legende_tableau <- ifelse(exists("logrank"), logrank, "")
    output$tablesurvie <- renderTable(tab,rownames = T, caption=legende_tableau)

})


observeEvent(input$updatesurvie,{
  ### fonctionnalités similaires à celle du Sankey
  cat("Bouton update de survie cliqué \n")
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
      bool <- type_colonnes_tableau == "factor"
      colonnes_tableau <- colonnes_tableau[bool]
      colonnes_tableau <- c(colonnes_tableau, colonnes_patient)
      ## ajout : aucun : 
      colonnes_tableau <- c("aucun",colonnes_tableau)
      if (length(colonnes_tableau) != 0){
        liste <- c(liste, create_survie_radiobutton(colonnes_tableau,event_number)) 
      }
    }
  if (is.null(liste)){
    cat ("\t Aucune sélection d'event réalisée pour créer un sankey \n")
    return(NULL)
  }

  shiny::removeUI(selector = "#survie_explication > div")
  insertUI(selector = "#survie_explication",ui = do.call(tagList, liste),where = "beforeEnd")
})

create_survie_radiobutton <- function(colonnes_tableau, event_number){
  id <- paste0("survie_radiobutton_0")
  ui <- shiny::radioButtons(id, label="",choices = colonnes_tableau, selected = "aucun", inline = T)
  #ajoutdiv <- paste0("<div id=treeboutton",n," value='",n,"' class='box'>") ## value permet de savoir la position de l'event
  liste <- list(HTML("<div><h4> Choisissez un groupe pour l'analyse de survie : </h4>"), ui , HTML("</div>"))
  return(liste)
}