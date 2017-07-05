library(shiny)
library(shinyTree)
library(sqldf)
library(dplyr)
library(stringr)
library(leaflet)


# Important! : creationPool should be hidden to avoid elements flashing before they are moved.
#              But hidden elements are ignored by shiny, unless this option below is set.
output$creationPool_tree <- renderUI({})
outputOptions(output, "creationPool_tree", suspendWhenHidden = FALSE)

# Important! : creationPool should be hidden to avoid elements flashing before they are moved.
#              But hidden elements are ignored by shiny, unless this option below is set.
output$creationPool_tabpanel <- renderUI({})
outputOptions(output, "creationPool_tabpanel", suspendWhenHidden = FALSE)


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

### retirer TreeButton et sa hiérarchie : 
removeEvents <- function(values, event_number, boolitself=NULL){
  remove_tabpanel <- function(filtres){
    ## retirer les tabset si créés : 
    if (length(filtres) != 0){
      for (i in 1:length(filtres)){
        jslink$remove_tabset(filtres[[i]]$tabsetid) ### fonction JS
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
      remove_tabpanel(values[[selection]]$event$filtres) ## private fonction def au dessus
      values[[selection]] <<- NULL ## retire de values
      jslink$remove_treebutton(treebouttonvalue = i) ## retire le treeboutton
    }
    return(NULL)
  }
  
  # s'il faut supprimer lui même :
  if (!is.null(boolitself)){
    selection <- paste0("selection",event_number)
    remove_tabpanel(values[[selection]]$event$filtres)
    values[[selection]] <<- NULL
    jslink$remove_treebutton(treebouttonvalue = event_number)
  }
  
  bool <- event_number < 0    ### cas ou event_number est négatif (all previous)
  if (bool){
    bool2 <- event_numbers < event_number
    for (i in event_numbers[bool2]){
      cat("\t suppression de ", "via < du boutton", event_number, "\n")
      selection <- paste0("selection",i)
      remove_tabpanel(values[[selection]]$event$filtres)
      values[[selection]] <<- NULL
      jslink$remove_treebutton(treebouttonvalue = i)
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
      jslink$remove_treebutton(treebouttonvalue = i)
    }
    return(NULL)
  }
}
