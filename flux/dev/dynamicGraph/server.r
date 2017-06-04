library(DT)
source("filtreOO.r")



### 
date1 <- as.Date("1970-1-1", format="%Y-%m-%d")
dates <- seq(date1, date1+99, by="day")
dates[2:10] <- NA

df <- data.frame(id = 1:100, age = 1:100, sexe=c("H","F"),dates=dates)
df2 <- df[1:50,]



## faire une hiérarchie avec les classes d'âges
metadf <- data.frame(colonnes = colnames(df), isid=c(1,0,0,0), type=c(NA,"integer","factor",NA),
                     intableau = c(0,1,1,1), ingraphique = c(0,1,1,0))


#filtre <- new("Filtre",df=df, metadf)

shinyServer(function(input, output) {
  
  values <- reactiveValues(
    #filtre = list()
  )
  
  ### paramètres : 
  filtreid <- "filtre1"
  checkboxeid <- "box1"
  tableauid <- "tableau1"
  
  values[[filtreid]] <- new("Filtre",df=df, metadf)
  
  output[[checkboxeid]] <- renderUI({
    values[[filtreid]]$getCheckBox()
  })
  
  ### pour conserver l'ordre des graphiques : 
  # je note l'ordre des cliques (des colonnes)

  output[[tableauid]] <-  DT::renderDataTable({
    if (!is.null(values[[filtreid]])){
      values[[filtreid]]$getDT()
    }

  })
  
  ### liste toutes les lignes (points...) pouvant être sélectionnées
  observe({
    
    ligne <- input[[paste0(tableauid, "_rows_all")]]
    if (!is.null(ligne)){
      values[[filtreid]]$set_selectionid(ligne)
      cat (nrow(values[[filtreid]]$df_selectionid)," lignes sélectionnés dans le tableau \n ")
    }
  })


## keep track of elements inserted and not yet removed
# inserted <- c()
# 
# observe({
#   
#   ## si ajout d'un filtre : length(inserted) < length(input$columns)
#   ## sinon length(inserted) > length(input$columns)
#   cat("inserted : ", inserted, "\n")
#   cat("columns : ", input$columns, "\n")
#   
#   if (input$go){
#     # ajout <- which(!input$columns %in% inserted)
#     # id <- input$columns[ajout]
#     # label <- id
#     # cat ("demande ajout filtre : ", id, "\n ")
#     id <-"test"
#     label <- "test2"
#     insertUI(
#       selector = "#go",
#       where = "afterEnd",
#       #ui = textInput(id, paste0("id : ", id))
#       getRightUi(id, label)
#     )
#     inserted <<- c(id, inserted)
#   }
  
  # if (length(inserted) > length(input$columns)){
  #   retrait <- which(!inserted %in% input$columns)
  #   id <- inserted[retrait]
  #   cat ("demande retrait filtre : ", id, "\n ")
  #   removeUI(
  #     ## pass in appropriate div id
  #     selector = paste0("#",id,"ajout")
  #     #selector = paste0("div:has([name='for'].val('mpg'))")
  #   )
  #   inserted <<- inserted[-retrait]
  # }
})


})


getRightUi <- function(id, label){
  x <- rnorm(1,mean=0,sd=1)
  bool <- x > 0
  if (bool){
    ui <- textInput(id, label)
  } else {
    ui <- selectInput(id, label,choices = 1:10)
  }
  
  ui <- tabPanel("test",
                 selectInput("test1",label="choix",choices=c(1:10)))
  ### important : englober l'ui dans un div car certains ui ont un ou plusieurs div
  # ce qui rend le removeUI difficile en Jquery
  # ajoutdiv <- paste0("<div id=",id,"ajout>")
  # liste <- list(HTML(ajoutdiv),ui, HTML("</div>"))
  # return(do.call(tagList, liste))
  return(ui)
}
