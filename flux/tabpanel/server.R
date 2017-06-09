source("filtreOO.r")

###  chargement de données fictives : 
date1 <- as.Date("1970-1-1", format="%Y-%m-%d")
dates <- seq(date1, date1+99, by="day")
dates[2:10] <- NA
df <- data.frame(id = 1:100, age = 1:100, sexe=c("H","F"),dates=dates)
df2 <- df[1:50,]

metadf <- data.frame(colonnes = colnames(df), isid=c(1,0,0,0), type=c(NA,"integer","factor",NA),
                     intableau = c(0,1,1,1), ingraphique = c(0,1,1,0))

server <- function(input, output, session){
  
  # From here: Just for demonstration
  output$creationInfo <- renderText({
    paste0("The next tab will be named NewTab", input$goCreate + 1)
  })
  
  ######## Ma partie 
  ## stock dans values la liste des tabpanels créés par l'utilisateur
  values <- reactiveValues(
    #filtre = list()
  )
  
  source("addtabpanel.R",local = T)
  
  ######## Si click sur le bouton
  observeEvent(input$goCreate, {

    nr <- input$goCreate
    tabsetid <- paste0("tabset",nr)
    
    addtabpanel(df,metadf, tabsetid)
    
    get_values() ## print dans la console le contenu de values
  })
  
  

  
  

  ### affiche le contenu de values (liste des filtres)
get_values = function(){
  isolate({
    valeurs_names <- names(reactiveValuesToList(values))
    valeurs_names_non_null <- c()
    for (i in valeurs_names){
      if (!is.null(values[[i]])){
        valeurs_names_non_null <- append(valeurs_names_non_null,i)
      }
    }
    valeurs_names_non_null <- paste(valeurs_names_non_null, collapse=";")
    afficher <- paste0("valeurs contient : ", valeurs_names_non_null)
    print(afficher)
    cat("\n")
  })
}  

}

