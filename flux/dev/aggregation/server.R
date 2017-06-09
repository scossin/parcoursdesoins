library(sqldf)
library(dplyr)
library(shiny)
library(shinyTree)

## ordonner les évènements par patient : 
#rm(list=ls())
source("eventOO.R")
#source("global.R")
load("hierarchy.rdata")
load("evenements.rdata")
evenements$type <- gsub("^(.*?)#","",evenements$type) ### retirer tout ce qu'il y a avant #
evenements <- evenements %>% group_by(patient) %>% mutate(num = row_number())
evenements <- as.data.frame(evenements) ## sinon erreur bizarre

server <- shinyServer(function(input, output, session) {

  removeEvents <- function(values, event_number, boolitself=NULL){
    event_numbers <- get_event_numbers(values)
    bool <- event_number == 0 ### cas ou event = 0 ; on retire tous les autres
    if (bool){
      for (i in event_numbers){
        if (i == 0){
          next
        }
        cat("suppression de ", i, "via 0")
        selection <- paste0("selection",i)
        values[[selection]] <<- NULL
        removeTree(treebouttonvalue = i)
      }
      return(NULL)
    }

    # s'il faut supprimer lui même :
    if (!is.null(boolitself)){
      selection <- paste0("selection",event_number)
      values[[selection]] <<- NULL
      removeTree(treebouttonvalue = event_number)
    }

    bool <- event_number < 0    ### cas ou event_number est négatif (all previous)
    if (bool){
      bool2 <- event_numbers < event_number
      for (i in event_numbers[bool2]){
        cat("suppression de ", i, "via <")
        selection <- paste0("selection",i)
        values[[selection]] <<- NULL
        removeTree(treebouttonvalue = i)
      }
      return(NULL)
    }

    bool <- event_number > 0
    if (bool){
      bool2 <- event_numbers > event_number
      for (i in event_numbers[bool2]){
        cat("suppression de ", i, "via >")
        selection <- paste0("selection",i)
        values[[selection]] <<- NULL
        removeTree(treebouttonvalue = i)
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
  # si pas null (n'importe quoi) alors l'element est placé en tout premier (prepend)
  # div : le div 
  addTree <- function(event,boolprevious=NULL){
    treebouttonid <- event$get_treebouttonid()
    div_treeboutton <- new_treeboutton(event) ## création de l'UI
    output$creationPool <- renderUI({div_treeboutton})
    session$sendCustomMessage(type = "moveTree", message = 
                                list(divtargetname = "alltrees", treebouttonid = treebouttonid,
                                     boolprevious=boolprevious)) ## alltrees : emplacement des treebouttons (voir ui.R)
  }
  
  ### treebouttonvalue : le numéro du div de treebouttonvalue : event$get_event_number()
  ## boolitself : faut-il retirer le div lui-même
  removeTree <- function(treebouttonvalue){
    session$sendCustomMessage(type = "remove_treebutton", message = 
                                list(value = treebouttonvalue))
  }
  
  # Important! : creationPool should be hidden to avoid elements flashing before they are moved.
  #              But hidden elements are ignored by shiny, unless this option below is set.
  output$creationPool <- renderUI({})
  outputOptions(output, "creationPool", suspendWhenHidden = FALSE)
  # End Important
  
  ## création du premier treeboutton : main_event
  values = list()
  
  ### chaque element de values contient des events
  # permet de récupérer le nombre de chaque event
  get_event_numbers <- function(values){
    event_numbers <- lapply(values, function(selection){
      unlist(lapply(selection, function(event){  
        return(event$get_event_number())
      }))
    })
    return(as.numeric(unlist(event_numbers)))
  }
  
  values[["selection0"]]$event <- new("Event",df_events = evenements,event_number=0)
  
  addTree(values[["selection0"]]$event)
  make_tree_in_treeboutton(values[["selection0"]]$event, hierarchy)

  add_observers_treeboutton <- function(event){
    ### lorsque l'utilisateur clique sur validate
    observeEvent(input[[event$get_validateid()]],{
      cat("Le boutton", event$get_validateid(), "a été cliqué \n")
      treenumber <- event$get_treeid()
      selection <- unlist(get_selected(input[[treenumber]]))
      if (is.null(selection)){
        cat(treenumber , " : aucun élément sélectionné pour valider.")
        return(NULL)
      }
      
      ## retire tous les treeboutton avant ou après
      
      cat("values : ", get_event_numbers(values),"\n")
      removeEvents(values, event$get_event_number())
      cat("values : ", get_event_numbers(values),"\n")
      
      #removeTree(treebouttonvalue = event$get_event_number, boolitself = NULL)
      #remove ### retirer les values aussi
      
      
      choix <- sapply(selection, function(x) gsub("[(][0-9]+[)]", "",x)) ### retirer les nombres entre parenthèses
      df_type_selected <- get_df_type_selected(hierarchy, choix)
      print (df_type_selected)
      event$set_df_type_selected(df_type_selected)
      cat ("création d'un filtre pour l'event ", event$get_event_number(), "\n")
    })
    
    
    #### quand je clic sur previous 
    ## 1) vérifier que l'utilisateur a réalisé une sélection
    ## 2) vérifier qu'un event previous n'existe pas déjà 
    ## 3) créer un event previous si les conditions plus haut sont réunis
    observeEvent(input[[event$get_addpreviousid()]], {
      cat("Le boutton", event$get_addpreviousid(), "a été cliqué \n")

      ## 1) 
      if (is.null(event$get_type_selected())){
        cat ("event", event$get_event_number(), "Aucun évènement sélectionné/validé \n")
        return(NULL)
      }
      
      ## 2) 
      event_numbers <- get_event_numbers(values)
      bool <- event$get_event_number() <= event_numbers ## il n'existe pas d'event plus petit que lui
      if (!all(bool)){
        cat ("event", event$get_event_number(), " : un event précédent existe déjà \n ")
        return(NULL)
      }
      
      ## 3) 
      
      n <- event$get_event_number() - 1 
      boolprevious <- T
      ## calculer le previous : 
      event$set_df_nextprevious_events(!boolprevious) ## calcule les events précédents

      previousevent <- new("Event",df_events = event$df_previous_events,event_number=n)
      
      values[[paste0("selection",n)]]$event <<- previousevent
      cat("values : ", get_event_numbers(values),"\n")
      
      addTree(previousevent,boolprevious)
      make_tree_in_treeboutton(previousevent, hierarchy)
      add_observers_treeboutton(previousevent)
      cat ("event",previousevent$get_event_number(), " créé ! ")
    }) ### fin ObserveEvent addprevious
    }
  
  add_observers_treeboutton(values[["selection0"]]$event)
  
    }) ## fin server


getRightUi <- function(n, h4){
  ui <- shinyTree(paste0("tree",n), checkbox = TRUE)
  ajoutdiv <- paste0("<div id=treeboutton",n," value='",n,"' class='box'>") ## value permet de savoir la position de l'event
  liste <- list(HTML(ajoutdiv),HTML("<h4>", h4,"</h4>"),ui, HTML("</div>"))
  return(do.call(tagList, liste))
}


