library(DT)
source("../dynamicGraph/filtreOO.r")



### 
date1 <- as.Date("1970-1-1", format="%Y-%m-%d")
dates <- seq(date1, date1+99, by="day")
dates[2:10] <- NA

df <- data.frame(id = 1:100, age = 1:100, sexe=c("H","F"),dates=dates)
df2 <- df[1:50,]



## faire une hiérarchie avec les classes d'âges
metadf <- data.frame(colonnes = colnames(df), isid=c(1,0,0,0), type=c(NA,"integer","factor",NA),
                     intableau = c(0,1,1,1), ingraphique = c(0,1,1,0))

server <- function(input, output, session){
  
  # Important! : creationPool should be hidden to avoid elements flashing before they are moved.
  #              But hidden elements are ignored by shiny, unless this option below is set.
  output$creationPool <- renderUI({})
  outputOptions(output, "creationPool", suspendWhenHidden = FALSE)
  # End Important
  
  # Important! : This is the make-easy wrapper for adding new tabPanels.
  addTabToTabset <- function(Panels, tabsetName){
    titles <- lapply(Panels, function(Panel){return(Panel$attribs$title)})
    Panels <- lapply(Panels, function(Panel){Panel$attribs$title <- NULL; return(Panel)})
    
    output$creationPool <- renderUI({Panels})
    session$sendCustomMessage(type = "addTabToTabset", message = list(titles = titles, tabsetName = tabsetName))
  }
  # End Important 
  
  # From here: Just for demonstration
  output$creationInfo <- renderText({
    paste0("The next tab will be named NewTab", input$goCreate + 1)
  })
  
  # values <- reactiveValues(
  #   #filtre = list()
  # )
  
  observeEvent(input$goCreate, {
    nr <- input$goCreate
    
    # if (!is.null(nr)){
    #   newTabPanels <- list(
    #     new_tabpanel(1)
    #   )
    #   
    #   make_plot(df,metadf, 1)
    # }

  
    
    # output[[paste0("Text", nr)]] <- renderText({
    #   if(input[[paste0("Button", nr)]] == 0){
    #     "Try pushing this button!"
    #   } else {
    #     paste("Button number", nr , "works!")
    #   }
    # })
    
    
    
    addTabToTabset(newTabPanels, "mainTabset")
  })
}


new_tabpanel <- function(number){
  tableauid <- paste0("tableau",number)
  boxid <- paste0("box",number)
  
  tabPanel("Filtre",
           # div(class="outer",
               
               # tags$head(
               #   # Include our custom CSS
               #   includeCSS("style.css")
               # ),
               fluidRow(
                 column(6,
                        h2("Tableau"),
                        DT::dataTableOutput(tableauid)
                 )),
               fluidRow(
                 column(3,
                        uiOutput(boxid)))
                 
               )
           #)s
}
#new_tabpanel(2)



### paramètres : 
make_plot <- function (df, metadf,number){
  filtreid <- paste ("filtre", number)
  checkboxeid <- paste ("box",number)
  tableauid <- paste ("tableau",number)
  
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
}
