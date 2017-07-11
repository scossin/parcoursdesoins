fonctions_tabpanel <- new.env()

### fonction pour créer l'ui
fonctions_tabpanel$new_tabpanel <- function(filtre){
  tab <- shiny::tabPanel(filtre$tabsetid, class="tabset",
                      fluidRow(
                        column(6,
                        HTML("<span class='Npatients' >Nombre de patients : <span>"),
                        shiny::textOutput(outputId = filtre$get_Npatientsid(),inline = T))
                      ),
                      fluidRow(
                        column(6,
                               h2("Filtre"),
                               DT::dataTableOutput(filtre$get_tableauid())
                        )),
                      fluidRow(
                        column(10,
                               h2("Graphiques"),
                               filtre$getCheckBox())
                      ),
                      fluidRow(
                        column(12,
                               uiOutput(filtre$get_plotsid()))
                      )
                  
  )
  return(tab)
}



# Important! : This is the make-easy wrapper for adding new tabPanels.
fonctions_tabpanel$addTabToTabset <- function(Panels){
  Panels <- lapply(Panels, function(Panel){Panel$attribs$title <- NULL; return(Panel)})
  output$creationPool_tabpanel <- renderUI({Panels})
}



fonctions_tabpanel$addPatientsToTabset <- function(Panels){
  titles <- lapply(Panels, function(Panel){return(Panel$attribs$title)})
  Panels <- lapply(Panels, function(Panel){Panel$attribs$title <- NULL; return(Panel)})
  output$creationPool_tabpanel <- renderUI({Panels})
}



fonctions_tabpanel$make_tableau <- function(filtre){
  output[[filtre$get_tableauid()]] <-  DT::renderDataTable({
    cat("make_tableau called \n")
    filtre$getDT()
  })
}

fonctions_tabpanel$make_Npatients <- function(filtre){
  output[[filtre$get_Npatientsid()]] <-  shiny::renderText({
    cat("make_Npatients called \n")
    return(length(unique(filtre$get_df_selection()$patient)))
  })
}


# 
fonctions_tabpanel$addplots_tabpanel <- function(filtre){
  output[[filtre$get_plotsid()]] <- renderUI({
    ## si un element est cliqué dans la checkbox, les graphiques à afficher sont calculés :
    plot_list <- filtre$get_plot_output_list()
    
    ## si ce n'est pas une suppression alors on calcule les graphiques
    if (length(filtre$deleted_last) == 1 && !filtre$deleted_last){ 
      cat ("graphique refait ! \n")
      fonctions_tabpanel$make_plots_in_tabpanel(filtre)
    }
    #print(output)
    return(plot_list)
  })
}

fonctions_tabpanel$make_plots_in_tabpanel <- function(filtre){
  idplots <- as.character(filtre$graphiques$idHTML)
  cat("make_plots_in_tabpanel() - idHTML des plots à réaliser : ", idplots, "\n")
  bool <- is.na(idplots)
  idplots <- idplots[!bool]
  if (length(idplots) == 0){
    return(NULL)
  }
  # i <- c("ageplotly")
  for (idHTML in idplots) {
      output[[idHTML]] <- filtre$getRightPlot(idHTML = idHTML)
  }
}

fonctions_tabpanel$add_observers_tabpanel <- function(filtre){
  
  ### lorsque le tableau est modifié : 
  observeEvent(input[[paste0(filtre$get_tableauid(), "_rows_all")]],{
    lignes <- input[[paste0(filtre$get_tableauid(), "_rows_all")]]
    filtre$set_lignes_selection(lignes)
    cat (length(filtre$lignes_selection)," lignes sélectionnées dans le tableau ",filtre$tabsetid, "\n")
    fonctions_tabpanel$make_plots_in_tabpanel(filtre) 
    fonctions_tabpanel$make_Npatients(filtre)
  })
  
  ### lorsqu'une checkbox est cliqué : 
  observeEvent(input[[filtre$get_checkboxid()]],{
    cat ("Checkbox",filtre$get_checkboxid(), " a été cliqué \n")
    usercheckbox <- input[[filtre$get_checkboxid()]]
    checkbox_clics <- filtre$checkbox_clics
    
    ## si c'est un ajout : 
    if (length(checkbox_clics) < length(usercheckbox)){
      num <- which(!usercheckbox %in% checkbox_clics)
      ajout <- usercheckbox[num]
      cat("\t ajout de",ajout, "\n")
      filtre$set_checkbox_clics(c(checkbox_clics,ajout)) ## ajout de la checkbox cliqué
      filtre$set_deleted_last(FALSE)
      ## grace à ces 2 dernières lignes, addplots_tabpanel qui est appelé après sait s'il faut refaire ou pas les plots
    }
    ## si c'est un retrait
    if (length(checkbox_clics) > length(usercheckbox)){ 
      retrait <- which(!checkbox_clics %in% usercheckbox)
      cat("\t retrait de",checkbox_clics[retrait], "\n")
      ##
      filtre$remove_graphiques(checkbox_clics[retrait]) ## retire le graphique à réaliser
      filtre$set_checkbox_clics(checkbox_clics[-retrait]) ## retire la checkbox
      filtre$set_deleted_last(TRUE)
    }
    
    ## plots à afficher :
    fonctions_tabpanel$addplots_tabpanel(filtre)
    
  }, ignoreNULL = FALSE) ## permet de savoir si aucun checkbox n'est cliqué 
  ## voir : https://stackoverflow.com/questions/33048189/shiny-observer-respond-to-all-checkboxes-being-unchecked
}
