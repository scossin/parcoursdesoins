library(sqldf)
library(dplyr)
library(shiny)
library(shinyTree)
library(stringr)
library(leaflet)

## ordonner les évènements par patient : 
#rm(list=ls())
source("eventOO.R")
#source("sankey.R")
source("../../tabpanel/filtreOO.r")
#source("global.R")
source("leaflet.R")
load("hierarchy.rdata")

### faire la dataframe sequence spatiale : 


server <- shinyServer(function(input, output, session) {

  source("www/js/jslink.R",local = T)
  source("newaddtabpanel.R",local=T)
  
  ### retirer TreeButton et sa hiérarchie : 
  removeEvents <- function(values, event_number, boolitself=NULL){
    remove_tabpanel <- function(filtres){
      ## retirer les tabset si créés : 
      if (length(filtres) != 0){
        for (i in 1:length(filtres)){
          remove_tabset(filtres[[i]]$tabsetid) ### fonction JS
        }
      }
      return(NULL)
    }
    
    event_numbers <- get_event_numbers(values)
    bool <- event_number == 0 ### cas ou event = 0 ; on retire tous les autres
    if (bool){
      for (i in event_numbers){
        if (i == 0){
          next
        }
        cat("\t suppression de ", i, "via le boutton 0 \n")
        selection <- paste0("selection",i)
        remove_tabpanel(values[[selection]]$event$filtres)
        values[[selection]] <<- NULL ## retire de values
        remove_treebutton(treebouttonvalue = i) ## retire le treeboutton
      }
      return(NULL)
    }

    # s'il faut supprimer lui même :
    if (!is.null(boolitself)){
      selection <- paste0("selection",event_number)
      remove_tabpanel(values[[selection]]$event$filtres)
      values[[selection]] <<- NULL
      remove_treebutton(treebouttonvalue = event_number)
    }

    bool <- event_number < 0    ### cas ou event_number est négatif (all previous)
    if (bool){
      bool2 <- event_numbers < event_number
      for (i in event_numbers[bool2]){
        cat("\t suppression de ", "via < du boutton", event_number, "\n")
        selection <- paste0("selection",i)
        remove_tabpanel(values[[selection]]$event$filtres)
        values[[selection]] <<- NULL
        remove_treebutton(treebouttonvalue = i)
      }
      return(NULL)
    }

    bool <- event_number > 0
    if (bool){
      bool2 <- event_numbers > event_number
      for (i in event_numbers[bool2]){
        cat("suppression de ", i, "via > du boutton", event_number, "\n")
        selection <- paste0("selection",i)
        values[[selection]] <<- NULL
        remove_treebutton(treebouttonvalue = i)
      }
      return(NULL)
    }
  }

  ## réaliser le tree dans un treeboutton
  make_tree_in_treeboutton <- function(event,hierarchy){
    output[[event$get_treeid()]] <- renderTree({ 
      event$get_tree_events(hierarchy)
    })
  }
  
  ## boolprevious : si NULL l'element est placé en tout dernier (append)
  # si pas null (n'importe quoi, meme False attention !) alors l'element est placé en tout premier (prepend)
  # div : le div 
  addTree <- function(event,boolprevious=NULL){
    treebouttonid <- event$get_treebouttonid()
    div_treeboutton <- new_treeboutton(event) ## création de l'UI
    output$creationPool <- renderUI({div_treeboutton})
    moveTree (treebouttonid, boolprevious)
    ## pas de display pour les bouttons suivants : 
    # boutton remove de l'event 0
    # bouttons previous ou bouttons next pour les events suivants et précédents respectivement :
    # ce display est retiré par une fonction JS appelé avec moveTree
  }
  
  
  # Important! : creationPool should be hidden to avoid elements flashing before they are moved.
  #              But hidden elements are ignored by shiny, unless this option below is set.
  output$creationPool <- renderUI({})
  outputOptions(output, "creationPool", suspendWhenHidden = FALSE)
  # End Important
  
  ## values contient la liste des objets events créés (treeboutton + filtre)
  values = list()
  id_treebutton <- 0   # numérotation des events : ne jamais répéter un même id sous shiny
                      ## même si l'id disparait
  id_tabset0 <- 0 ## numérotation du tabset 0 ! doit etre réalisé séparément car contrairement
        ## aux autres, la hiérarchie ne disparait jamais ; il faut changer l'id du tabset 
  
  ### chaque element de values contient des events
  # permet de récupérer l'id/numéro de chaque event
  get_event_numbers <- function(values){
    event_numbers <- lapply(values, function(selection){
      unlist(lapply(selection, function(event){  
        return(event$get_event_number())
      }))
    })
    return(as.numeric(unlist(event_numbers)))
  }
  
  
  
  ##### Création de l'event 0 !
  values[["selection0"]]$event <- new("Event",df_events = evenements,event_number=0)
  addTree(values[["selection0"]]$event)
  make_tree_in_treeboutton(values[["selection0"]]$event, hierarchy)
  hide_boutton(values[["selection0"]]$event)
  
  
  add_observers_treeboutton <- function(event){
    
    ### lorsque l'utilisateur clique sur validate
    observeEvent(input[[event$get_validateid()]],{
      cat("Le boutton", event$get_validateid(), "a été cliqué \n")
      treenumber <- event$get_treeid()
      selection <- unlist(get_selected(input[[treenumber]]))
      if (is.null(selection)){
        cat("\t",treenumber , " : aucun élément sélectionné pour valider.")
        return(NULL)
      }
      
      #### On n'a pas le droit de sélectionner s'il y a aucun event : 0 ou pas de parenthèse()
      Nselection <- sapply(selection, function(x) str_extract(x, pattern="[(][0-9]+[)]"))
      Nselection <- gsub("[()]","",Nselection)
      boolNselection <- sapply(Nselection, function(x) {is.na(x) || as.numeric(x)==0})
      if (all(boolNselection)){
        cat("\t",treenumber , " : tous les events sélectionnés ont 0 instances. \n")
        return(NULL)
      }
      
      ## retire tous les treeboutton avant ou après
      
      cat("\t values : ", get_event_numbers(values),"\n")
      removeEvents(values, event$get_event_number())
      cat("\t values : ", get_event_numbers(values),"\n")
      
      #remove_treebutton(treebouttonvalue = event$get_event_number, boolitself = NULL)
      #remove ### retirer les values aussi
      
      choix <- sapply(selection, function(x) gsub("[(][0-9]+[)]", "",x)) ### retirer les nombres entre parenthèses
      
      
      df_type_selected <- get_df_type_selected(hierarchy, choix)
      
      ## séparément le cas où un filtre (et donc un tabset) existe déjà : il faut updater
      # ou le cas où le filtre n'existe pas encore : il faut créer (tabset ...)
      bool <- length(event$filtres) > 0
      
      #print (df_type_selected)
      event$set_df_type_selected(df_type_selected)
      cat ("\t création d'un filtre pour l'event ", event$get_event_number(), "\n")
      
      if (!bool){
        for (i in 1:length(event$filtres)){
          # cat(length(event$filtres))
          tabpanel <- list(new_tabpanel(event$filtres[[i]]))
          addTabToTabset(tabpanel, "mainTabset")
          make_tableau(event$filtres[[i]])
          addplots_tabpanel(event$filtres[[i]])
          make_plots_in_tabpanel(event$filtres[[i]])
          add_observers_tabpanel(event$filtres[[i]])
        }
      } else {
        for (i in 1:length(event$filtres)){
          updateCheckboxGroupInput(session, event$filtres[[i]]$get_checkboxid(), 
                                   choices = event$filtres[[i]]$colonnes_graphiques,
                                   selected = NULL, inline=T)
          make_tableau(event$filtres[[i]])
          addplots_tabpanel(event$filtres[[i]])
          make_plots_in_tabpanel(event$filtres[[i]])
          add_observers_tabpanel(event$filtres[[i]])
        }
      }
      
    }) ## fin observe event validate
    
    ### Ce qui se passe quand l'utilisateur clique sur remove :
    observeEvent(input[[event$get_removeid()]],{
      ## l'event 0 ne peut être cliqué car j'ai retiré le boutton !
      cat("Le boutton", event$get_removeid(), "a été cliqué \n")
      cat("\t values : ", get_event_numbers(values),"\n")
      removeEvents(values, event$get_event_number(),boolitself = T)
      cat("\t values : ", get_event_numbers(values),"\n")
    })
    #### quand je clic sur previous 
    ## 1) vérifier que l'utilisateur a réalisé une sélection
    ## 2) vérifier qu'un event previous n'existe pas déjà 
    ## 3) créer un event previous si les conditions plus haut sont réunis
    observeEvent(input[[event$get_addpreviousid()]], {
      cat("Le boutton", event$get_addpreviousid(), "a été cliqué \n")

      ## 1) 
      if (is.null(event$get_type_selected())){
        cat ("\t event", event$get_event_number(), "Aucun évènement sélectionné/validé \n")
        return(NULL)
      }
      
      ## 2) 
      event_numbers <- get_event_numbers(values)
      bool <- event$get_event_number() <= event_numbers ## il n'existe pas d'event plus petit que lui
      if (!all(bool)){
        cat ("\t event", event$get_event_number(), " : un event précédent existe déjà \n ")
        return(NULL)
      }
      
      ## 3) 
      id_treebutton <<- id_treebutton + 1 ## on incrémente
      n <- - id_treebutton ## signe négatif car previous
      boolprevious <- T
      ## calculer le previous : 
      event$set_df_nextprevious_events(!boolprevious) ## calcule les events précédents

      previousevent <- new("Event",df_events = event$df_previous_events,event_number=n)
      
      values[[paste0("selection",n)]]$event <<- previousevent
      cat("\t values : ", get_event_numbers(values),"\n")
      
      addTree(previousevent,boolprevious)
      make_tree_in_treeboutton(previousevent, hierarchy)
      add_observers_treeboutton(previousevent)
      hide_boutton(previousevent)
      cat ("\t event",previousevent$get_event_number(), " créé ! \n ")
    }) ### fin ObserveEvent addprevious
    
    ## meme chose pour next event : voir algo pour previous
    observeEvent(input[[event$get_addnextid()]], {
      cat("Le boutton", event$get_addnextid(), "a été cliqué \n")
      
      ## 1) 
      if (is.null(event$get_type_selected())){
        cat ("\t event", event$get_event_number(), "Aucun évènement sélectionné/validé \n")
        return(NULL)
      }
      
      ## 2) 
      event_numbers <- get_event_numbers(values)
      bool <- event$get_event_number() >= event_numbers ## il n'existe pas d'event plus grand que lui
      if (!all(bool)){
        cat ("\t event", event$get_event_number(), " : un event suivant existe déjà \n ")
        return(NULL)
      }
      
      ## 3) 
      id_treebutton <<- id_treebutton + 1 ## on incrémente
      n <- id_treebutton ## signe négatif car previous
      boolprevious <- F
      ##  nextevent : 
      event$set_df_nextprevious_events(!boolprevious) ## calcule les events suivants
      
      nextevent <- new("Event",df_events = event$df_next_events,event_number=n)
      
      values[[paste0("selection",n)]]$event <<- nextevent
      cat("\t values : ", get_event_numbers(values),"\n")
      
      addTree(nextevent,boolprevious=NULL)
      make_tree_in_treeboutton(nextevent, hierarchy)
      add_observers_treeboutton(nextevent)
      hide_boutton(nextevent)
      cat ("\t event",nextevent$get_event_number(), " créé ! \n ")
    }) ### fin ObserveEvent addprevious
    
    } # fin add_observers_treeboutton
  
  add_observers_treeboutton(values[["selection0"]]$event)
  
  
  
  ## Sankey :
  observeEvent(input$update,{
    cat("Bouton update de Sankey cliqué \n")
    liste <- NULL
    if (length(values) == 0){
      return(NULL)
    }
    for (i in 1:length(values)){
      filtres <- values[[i]]$event$filtres
      if (length(filtres) == 0){
        next
      }
      for (y in 1:length(filtres)){
        df <- filtres[[y]]$df_selectionid
        liste <- c(liste, getRightUi(df,filtres[[y]]$tabsetid))
        print (colnames(df))
      }
    }
    if (is.null(liste)){
      return(NULL)
    }
    insertUI(selector = "#sankey_event0",ui = do.call(tagList, liste),where = "afterEnd")
  })
  
  
  observeEvent(input$go,{
    ## récupérer le choix de l'utilisateur des radiobouttons : 
    numeros <- get_event_numbers(values)
    df_sankey <- NULL
    for (num_event in numeros){
      cat("num_event : ", num_event, "\n")
      radio_button <- paste0("sankey_radiobutton_",num_event)
      if (is.null(input[[radio_button]])){
        next
      } else {
        choix_colonne <- input[[radio_button]]
        ## récupère df_events_selected pour chaque event :
        event <- values[[paste0("selection",num_event)]]$event
        event$set_df_events_selected() ## mise à jour si filtre

        df_events_selected <- event$df_events_selected
        df_events_selected <- subset (df_events_selected, select=c("patient",choix_colonne))
        colnames(df_events_selected) <- c("patient",paste0("event",num_event))
        if (is.null(df_sankey)){ ## si c'est la première itération
          df_sankey <- df_events_selected
        } else {
          df_sankey <- merge (df_sankey, df_events_selected, by="patient", all.x=T)
        }
      }
    }
    output$sankey <- sankeyD3::renderSankeyNetwork({
      make_sankey(df_sankey, V1=T, V2=F)
    }) 
    # save(df_sankey, file="df_sankey.rdata") ## pour le débogage
    cat("\t Sankey réalisé \n")
  })

  
 
  ### leaflet: 
  output$map <- renderLeaflet({
    m <- leaflet(dep33)  %>%
      addPolygons(popup=as.character(dep33$libgeo), stroke=T,opacity=0.5,weight=1,color="grey",
                   layerId=dep33$codgeo) %>%
      addProviderTiles("Stamen.TonerLite")   %>%
      # markers UNV
      addMarkers(lng=coordinates(locEtab33UNV)[,1],
                 lat=coordinates(locEtab33UNV)[,2],
                 popup=as.character(locEtab33UNV$rs),
                 group = "UNV",layerId=locEtab33UNV$nofinesset,icon=UNVicon) %>%
      # markers SSR
      addMarkers(lng=coordinates(locEtab33SSR)[,1],
                 lat=coordinates(locEtab33SSR)[,2],
                 popup=as.character(locEtab33SSR$rs),icon=SSRicon,
                 group = "SSR",layerId=locEtab33SSR$nofinesset)
    ### passer une matrice au lieu de faire une boucle
    i <- 1
    #afficher_parcours(m,trajectoires)
    # for (i in 1:nrow(trajectoires)){
    #   poids <- trajectoires$poids[i] ## entre 1 et 10
    #   longitudes <- c(trajectoires$fromlong, trajectoires$tolong)
    #   latitudes <- c(trajectoires$fromlat, trajectoires$tolat)
    # 
    #   m <- addPolylines(m,lng=longitudes, lat=latitudes,color = "green",
    #                     weight = trajectoires,opacity = 1,
    #                     label=paste(trajectoires$N[i]))
    # 
    #   #layerId=trajectoires$id[i])
    # }
    m
  })
  
  observeEvent(input$button,{
    afficher_parcours("map",trajectoires)
  })

  
    }) ## fin server


afficher_parcours <- function(map, trajectoires){
  ### ajout des nouvelles trajectoires
  for (i in 1:50){
    poids <- trajectoires$poids[i] ## entre 1 et 10
    longitudes <- c(trajectoires$fromlong[i], trajectoires$tolong[i])
    latitudes <- c(trajectoires$fromlat[i], trajectoires$tolat[i])
    
    leafletProxy(map) %>% addPolylines(lng=longitudes, lat=latitudes,color = trajectoires$couleur[i],
                                       weight = poids,opacity = 1, 
                                       label=paste(trajectoires$N[i]),
                                       layerId=trajectoires$id[i])
  }
}


### non utilisé : à supprimer 
getRightUi <- function(df, iter){
  id <- paste0("sankey_radiobutton_",iter)
  label <- paste0("event",iter)
  ui <- radioButtons(id, label=label, choices = colnames(df), selected = "type", inline = T)
  #ajoutdiv <- paste0("<div id=treeboutton",n," value='",n,"' class='box'>") ## value permet de savoir la position de l'event
  #liste <- list(HTML("<div><h4>",titre,"</h4>"),ui, HTML("</div>"))
  liste <- list(ui)
  return(liste)
  #return(do.call(tagList, liste))
}

# liste1 <- NULL
# liste2 <- list (HTML("test2"))
# c(liste1, liste2)
