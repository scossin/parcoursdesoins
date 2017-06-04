
function(input,output, session){
  #source("output/output_leaflet.R",local = T)
  
  output$tree <- renderTree({ 
    hierarchyliste
  })
  
  
  # Choix réalisées par l'utilisateur
  dfagregation <- eventReactive(input$go, {
    cat("bouton appuyée")
    tree <- input$tree
    if (is.null(tree)){
      cat("tree is null \n")
      return(NULL)
    } else{
      cat("tree is not null \n")
      selection <- unlist(get_selected(tree))
      #selection <- c("Etablissement","MCO")
      dfagregation <- get_dfagregation(hierarchyliste, selection)
      return(dfagregation)
    }
  })
  ##
  
  output$selTxt <- renderText({
    # tree <- input$tree
    # if (is.null(tree)){
    #   "None"
    # } else{
    #   selection <- unlist(get_selected(tree))
    #   print(selection)
    #   return(selection)
    # }
    return(nrow(dfagregation()))
  })
  
  source("output_network.R",local = T)

}


