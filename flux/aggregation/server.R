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
event <- new("Event",evenements = evenements, hierarchy= hierarchy)

##### J'imagine 2 approches pour récupérer tous les évènements après un évènement
### et après un laps de temps 
# récupérer tous les évènements après puis calculer le temps entre tous ces events et le main event
# calculer le temps entre l'évènement suivant ; puis récupérer l'event encore suivant (ou 10 par 10 par exemple)
# prendre le milieu à chaque fois entre le num et le max ; 

## L'utilisateur choisit l'évèment principal : 
main_event <- "SejourMCO"

event$set_main_event(main_event) ## fige main_event et recherche les events apres


### Etape 1  : récupère dans la base de données tous les patients avec cet event principal :
# si un patient a plusieurs fois l'event, on prend l'event le plus récent (min num)
# num : numéro de l'évent, ordre en fonction de startime


server <- shinyServer(function(input, output, session) {

  moveTree <- function(treebouttonN){
    # titles <- lapply(Panels, function(Panel){return(Panel$attribs$title)})
    # Panels <- lapply(Panels, function(Panel){Panel$attribs$title <- NULL; return(Panel)})
    # output$creationPool <- renderUI({Panels})
    
  }
  
  
  values = reactiveValues(
    
  )
  output$tree1 <- renderTree({ 
    event$get_tree_mainevent()
  })
  

  # Important! : creationPool should be hidden to avoid elements flashing before they are moved.
  #              But hidden elements are ignored by shiny, unless this option below is set.
  output$creationPool <- renderUI({})
  outputOptions(output, "creationPool", suspendWhenHidden = FALSE)
  # End Important
  

  addTree <- function(ui, treebouttonN,bouttonafficher){
    output$creationPool <- renderUI({ui})
    session$sendCustomMessage(type = "moveTree", message = 
                                list(divtargetname = "alltrees", elementname = treebouttonN,
                                     bouttonafficher = bouttonafficher))
  }
  
  observeEvent(input$boutton1, {
    cat("bouton appuyée")
    tree <- input$tree1
    if (is.null(tree)){
      cat("tree is null \n")
      return(NULL)
    } else{
      cat("tree is not null \n")
      

      # 
      # insertUI(
      #   selector = "#tree2",
      #   where = "afterEnd",
      #   #ui = textInput(id, paste0("id : ", id))
      #   # getRightUi(id, label)
      #   actionButton("go2", "go2")
      # )
      # 
      # 
      # output$tree2 <- renderTree({ 
      #   event$get_tree_mainevent()
      # })
      selection <- unlist(get_selected(tree))
      selection <- sapply(selection, function(x) gsub("[(][0-9]+[)]", "",x))
      #cat(selection)
      #selection<-"SSR"
      values$dfagregation <- get_dfagregation(hierarchy, selection)
      #print(dfagregation)
      
      ui <- getRightUi(10)
      addTree(ui,paste0("treeboutton",10), "afficher")
      
      
      #make_ui()
      #Sys.sleep(1)
      #moveTree() ### important à changer avant de faire output
      ## sinon ça ne s'affiche pas
      #Sys.sleep()

      tree <- input$tree1
      cat(unlist(get_selected(tree)))
  }
    })
  
  observeEvent(input$afficher,{
    if (is.null(input$afficher)){
      return(NULL)
    }
    cat("afficher cliqué ! ")
    #Sys.sleep(5)
    output[[paste0("tree",10)]] <- renderTree({
      event$get_tree_mainevent()
    })
  })

  
  # make_ui <- function(){
  #   insertUI(
  #     selector = "#alltrees",
  #     where = "beforeEnd",
  #     #ui = textInput(id, paste0("id : ", id))
  #     # getRightUi(id, label)
  #     # getRightUi(2)
  #     ui = textInput("test","test")
  #   )
  # }
  # observeEvent(input$boutton1, {
  # 
  #   # output$tree2 <- renderTree({
  #   #   event$get_tree_mainevent()
  #   # })
  # })
  # 
  # dfagregation <- eventReactive(input$boutton1, {
  #   
  #     return(dfagregation)
  #   }
  # })
  ##
  
#   output$selTxt <- renderText({
#     # tree <- input$tree
#     # if (is.null(tree)){
#     #   "None"
#     # } else{
#     #   selection <- unlist(get_selected(tree))
#     #   print(selection)
#     #   return(selection)
#     # }
#     return(nrow(values$dfagregation))
#   })
# 
  })


getRightUi <- function(n){
  ui <- shinyTree(paste0("tree",n), checkbox = TRUE)
  ajoutdiv <- paste0("<div id=treeboutton",n," value='1' class='box'>")
  liste <- list(HTML(ajoutdiv),HTML("<h4> new tree</h4>"),ui, HTML("</div>"))
  return(do.call(tagList, liste))
}



#### ajouter ça : 




