
  # Drop-down selection box for Sous-categorie
  output$sous <- renderUI({
    bool <- dfcategorie$categorie == input$categorie
    selected <- subset (dfcategorie, bool)
    #cat(as.character(selected$sous))
    selectInput(inputId = "sous", label = "Evènements groupés par :", 
                choices= as.character(unique(selected$sous)), multiple=T, size=5, selectize=FALSE)
  })
  
  output$details <- renderUI({
    if (is.null(input$sous)){
      bool <- dfcategorie$categorie == input$categorie
    } else {
      bool <- dfcategorie$categorie == input$categorie & dfcategorie$sous %in% input$sous
    }

    selected <- subset (dfcategorie, bool)
    #cat(as.character(selected$details))
    selectInput(inputId = "details", label = "Evènements :", multiple=T, size=5,
                choices= as.character(unique(selected$details)), selectize=FALSE)
    })
  
    choices <- eventReactive(eventExpr = c(input$AddEvent,input$AddMainEvent), {
      if (!is.null(input$details)){
        choices <- input$details
      } else if (!is.null(input$sous)){
        choices <- input$sous
      } else if (!is.null(input$categorie)){
        choices <- input$categorie
      } else {
        stop("Aucune catégorie, souscategorie ou event sélectionnés") ## ne peut pas arriver en théorie
      }
      choices <- unique(choices)
    })
    
    choixEvents <- eventReactive(input$AddEvent,{
      choixEvents <- choices()
    })
    
    choixMainEvent <- eventReactive(input$AddMainEvent,{
      choixMainEvent <- choices()
    })
  
    output$choix <- renderUI({
        isolate(
          ancienschoix <- local(input$choix)
        )
          choix <- unique(c(choixEvents(), ancienschoix))

     
        selectizeInput(inputId = "choix","Evènements sélectionnés :",
                         choices = choix,multiple=T,selected = choix,
                         options=list(plugins=list('drag_drop','remove_button')))
    })
     
    output$choixMain <- renderUI({
      isolate(
        ancienschoix <- local(input$choixMain)
      )  
      choix <- unique(c(choixMainEvent(), ancienschoix))
        
        selectizeInput(inputId = "choixMain","Evènements sélectionnés :",
                       choices = choix,multiple=T,selected = choix,
                       options=list(plugins=list('drag_drop','remove_button')))
    })


    sankeygraphique <- eventReactive(input$go,{
      choixMainEvent <- choices()
      maineventdf <- NULL
      if (!is.null(input$choixMain)){
        for (i in input$choixMain){
          maineventdf <- rbind(maineventdf,get_aggregation(dfcategorie, i))
        }
      }
      
      selectedeventsdf <- NULL
      if (!is.null(input$choix)){
        for (i in input$choix){
          selectedeventsdf <- rbind(selectedeventsdf,get_aggregation(dfcategorie, i))
        }
      }
      
      Navant <- input$Navant
      Napres <- input$Napres
      
      # graphique <- create_sankey(listeevents, maineventdf, 
      #                            selectedeventsdf, Navant, Napres)
      
      if ((is.null(maineventdf)|is.null(selectedeventsdf))){
        return(NULL)
      } else {
        evenements <- listeeventsselection()
        create_sankey(evenements, maineventdf, 
                      selectedeventsdf, Navant, Napres)
      }
    })
    
  output$sankey <- renderGvis({
        sankeygraphique()
    }) 
