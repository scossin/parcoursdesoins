
### Code récupéré sur StackOverflow ## lien entre le fichier js

# Important! : creationPool should be hidden to avoid elements flashing before they are moved.
#              But hidden elements are ignored by shiny, unless this option below is set.
# output$creationPool <- renderUI({})
# outputOptions(output, "creationPool", suspendWhenHidden = FALSE)
# End Important


# End Important 


addtabpanel <- function(df,metadf, tabsetid){
  
  ## création du filtre :
  values[[tabsetid]] <- list()
  values[[tabsetid]]$filtre <- new("Filtre",df=df, metadf,tabsetid)
  values[[tabsetid]]$checkbox = c() ## keep track de l'ordre des cliques dans la checkbox
  values[[tabsetid]]$deleted_last = logical() ## savoir si on a retiré ou enlevé un graphique
  
  ## création de l'UI : 
  newTabPanels <- list(
    new_tabpanel(values[[tabsetid]]$filtre)
  )
  
  ## création du contenu pour l'UI
  # make_checkbox(values[[tabsetid]]$filtre)
  make_tableau(values[[tabsetid]]$filtre)
  make_plots(values[[tabsetid]]$filtre)
  
  #make_tabset(values[[tabsetid]]$filtre)
  
  ### liste toutes les lignes (points...) pouvant être sélectionnées
  
  #### Observer la modification des lignes dans le tableau
  observe({
    ## je ne comprends pourquoi, quand je click checkbox ça appelle l'input suivant : 
    if (is.null(values[[tabsetid]])){
      return(NULL)
    }
    ligne <- input[[paste0(values[[tabsetid]]$filtre$get_tableauid(), "_rows_all")]]
    
    ## du coup je compare le nombre de ligne : 
    bool <- length(ligne) == nrow(values[[tabsetid]]$filtre$df_selectionid)
    isolate({ ## pas sur qu'isolate sert à quelque chose ici
      if (!is.null(ligne) && !is.null(values[[tabsetid]]) && !bool){
        # values[[tabsetid]]$filtre$set_selectionid(ligne)
        values[[tabsetid]]$filtre$set_selectionid(filtre$get_ids_fromrows(ligne))
        # cat (nrow(values[[tabsetid]]$filtre$df_selectionid)," lignes sélectionnés dans le tableau \n ")
        cat (nrow(values[[tabsetid]]$filtre$df_selectionid)," lignes sélectionnés dans le tableau \n ")
        make_plot(values[[tabsetid]]$filtre)
      }
    })
    
  })
  
  observe({
    # cat("columns : ", input$coche_graphique, "\n")
    if (is.null(values[[tabsetid]])){
      return(NULL)
    }
    usercheckbox <- input[[values[[tabsetid]]$filtre$get_checkboxid()]]
    trackcheckbox <- values[[tabsetid]]$checkbox
    # cat("usercheckbox : ", usercheckbox, "\n")
    # cat("trackcheckbox : ", trackcheckbox, "\n")
    
    if (length(trackcheckbox) < length(usercheckbox)){
      num <- which(!usercheckbox %in% trackcheckbox)
      ajout <- usercheckbox[num]
      values[[tabsetid]]$checkbox <- c(trackcheckbox,ajout)
      values[[tabsetid]]$deleted_last <- F
    }
    if (length(trackcheckbox) > length(usercheckbox)){
      retrait <- which(!trackcheckbox %in% usercheckbox)
      ## On retire le graphique de la liste
      # cat ("retirer : ", trackcheckbox[retrait])
      values[[tabsetid]]$filtre$remove_graphiques(trackcheckbox[retrait])
      values[[tabsetid]]$checkbox <<- trackcheckbox[-retrait] ## retire
      values[[tabsetid]]$deleted_last <- T
    }
  })
  
  ## ajout au bon endroit
  addTabToTabset(newTabPanels, "mainTabset")
  
  ## ajout d'un bouton pour retirer le tabpanel
  insertUI(
    selector = "#goCreate",
    where = "afterEnd",
    actionButton(paste0("boutton",tabsetid), paste0("Retirer ", tabsetid))
  )
  
  ## ajout de la fonction au bouton pour retirer le tabsetid
  add_remove_function(tabsetid)
}







### fonctions appelés par addtabpanel




add_remove_function = function(tabsetid){
  observeEvent(input[[paste0("boutton",tabsetid)]], {
    values[[tabsetid]] <- NULL ### retirer de values les valeurs concernant ce tabsetid
    bouttonid <- paste0("boutton",tabsetid)
    #tabsetid <- paste0("#tab-",tabsetid)
    session$sendCustomMessage(type = 'removeTabToTabset',
                              message = list(tabsetid = paste0("#tab-",tabsetid), bouttonid = bouttonid)) ### #tab- : Cf js
    
    get_values() ## affiche les valeurs restantes
  })
}