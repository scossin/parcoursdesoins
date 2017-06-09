library(DT)
source("filtreOO.r")



### 
date1 <- as.Date("1970-1-1", format="%Y-%m-%d")
dates <- seq(date1, date1+99, by="day")
dates[2:10] <- NA

df <- data.frame(id = 1:100, age = 1:100, sexe=c("H","F"),dates=dates)
df2 <- df[1:50,]

data_sets <- c("df","df2")




## faire une hiérarchie avec les classes d'âges
metadf <- data.frame(colonnes = colnames(df), isid=c(1,0,0,0), type=c(NA,"integer","factor",NA),
                     intableau = c(0,1,1,1), ingraphique = c(0,1,1,0))


shinyServer(function(input, output) {
  
  output$choose_columns <- renderUI({
    values$filtre$getCheckBox()
  })
  
  # Drop-down selection box for which data set
  output$choose_dataset <- renderUI({
    selectInput("dataset", "Data set", as.list(data_sets))
  })
  
  ### pour conserver l'ordre des graphiques : 
  # je note l'ordre des cliques (des colonnes)
  values <- reactiveValues(
    checkbox = c(), ## keep track de l'ordre des cliques dans la checkbox
    deleted_last = logical() # derniere modif : ajout ou suppression d'un élément (permet de savoir s'il faut générer un nouveau graphique ou pas)
    #filtre <- list()
  )

  values$filtre <- new("Filtre",df=df, metadf)
  
  observe({
    # cat("columns : ", input$coche_graphique, "\n")
    if (length(values$checkbox) < length(input$coche_graphique)){
      num <- which(!input$coche_graphique %in% values$checkbox)
      ajout <- input$coche_graphique[num]
      values$checkbox <- c(values$checkbox,ajout)
      values$deleted_last <- F
    }
    if (length(values$checkbox) > length(input$coche_graphique)){
      retrait <- which(!values$checkbox %in% input$coche_graphique)
      ## On retire le graphique de la liste
      # cat ("retirer : ", values$checkbox[retrait])
      values$filtre$remove_graphiques(values$checkbox[retrait])
      values$checkbox <<- values$checkbox[-retrait] ## retire
      
      values$deleted_last <- T
    }
  })
  
  # inserted2 <- reactive({
  #   input$coche_graphique
  #   return(inserted)
  # })
  
  output$tableau <-  DT::renderDataTable({
    values$filtre$getDT()
  })
  
  ### liste toutes les lignes (points...) pouvant être sélectionnées
  observe({
    ligne <- input$tableau_rows_all
    if (!is.null(ligne)){
      values$filtre$set_selectionid(ligne)
      cat (nrow(values$filtre$df_selectionid)," lignes sélectionnés dans le tableau \n ")
      make_plot()
    }
  })
  
  
  # observe({
  #   e <- event_data("plotly_selected",source="delai")
  #   if (is.null(e) | !is.data.frame(e)) {
  #     cat("Sélectionner un point !")} 
  #   else{
  #     cat(nrow(e), "point sélectionnés")
  #     cat(e$pointNumber) ## +1 car R débute à 1, Js à 0 l'index des tableaux :-)
  #   }

  
### pour les piecharts
  # observe({
  #   e <- event_data("plotly_relayout",source="test")
  #   if (is.null(e)) {
  #     cat("Sélectionner un point !")}
  #   else{
  #     cat(class(e))
  #     cat(str(e))
  #   }
  #   
  #   ### "plotly_relayout" => deselected 
  # })
  
  
  ## choix_colonnes reactives ici selon la sélection des colonnes
  
  output$plots <- renderUI({
    ## si un element est cliqué dans la checkbox, les graphiques à afficher sont calculés :
    output <- values$filtre$get_plot_output_list(colonnes_cocher = values$checkbox)

    if (length(values$deleted_last) == 1 && !values$deleted_last){ ## si ce n'est pas un suppression ; alors on calcule les graphiques
        make_plot()
    }
    #print(output)
    return(output)
  })
  
  # Call renderPlot for each one. Plots are only actually generated when they
  # are visible on the web page.
  make_plot <- function(){
    idplots <- as.character(values$filtre$graphiques$idHTML)
    cat("make_plot() - idHTML des plots à réaliser : ", idplots, "\n")
    # i <- c("ageplotly")
    for (idHTML in idplots) {
      # Need local so that each item gets its own number. Without it, the value
      # of i in the renderPlot() will be the same across all instances, because
      # of when the expression is evaluated.
      local({
        #idHTML <- i
        output[[idHTML]] <- values$filtre$getRightPlot(idHTML = idHTML)
      })
    }
  }
  
})


