new_tabpanel <- function(title, tabsetid){
  #number <- 1
  tableauid <- paste0("UItableau",tabsetid)
  boxid <- paste0("UIbox",tabsetid)
  
  tab <- tabPanel(title,
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
  return(tab)
}

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
  
  values <- reactiveValues(
    #filtre = list()
  )
  
  observeEvent(input$goCreate, {
    #isolate(print(reactiveValuesToList(values)))
    nr <- input$goCreate
    tabsetid <- paste0("tabset",nr)
    
    newTabPanels <- list(
      new_tabpanel(tabsetid,tabsetid)
    )
    
    make_tabset(df,metadf,tabsetid)
    # 
    # output[[paste0("Text", nr)]] <- renderText({
    #   if(input[[paste0("Button", nr)]] == 0){
    #     "Try pushing this button!"
    #   } else {
    #     paste("Button number", nr , "works!")
    #   }
    # })
    #cat(values))
    
    addTabToTabset(newTabPanels, "mainTabset")
    
    insertUI(
      selector = "#goCreate",
      where = "afterEnd",
      #ui = textInput(id, paste0("id : ", id))
      actionButton(paste0("boutton",tabsetid,"name"), "Remove")
    )
    
    add_remove_function(tabsetid)
    get_values()
  })
  
  
  ###### principale fonction 
  make_tabset <- function (df, metadf,tabsetid){
    values[[tabsetid]] <- list()
    
    # filtreid <- paste0 ("filtre", number)
    checkboxeid <- paste0 ("UIbox",tabsetid)
    tableauid <- paste0 ("UItableau",tabsetid)
    plotsid <- paste0 ("UIplots",tabsetid)
    
    values[[tabsetid]]$filtre <- new("Filtre",df=df, metadf)
    
    output[[checkboxeid]] <- renderUI({
      values[[tabsetid]]$filtre$getCheckBox()
    })
    
    ### pour conserver l'ordre des graphiques : 
    # je note l'ordre des cliques (des colonnes)
    
    output[[tableauid]] <-  DT::renderDataTable({
      if (!is.null(values[[tabsetid]]$filtre)){
        values[[tabsetid]]$filtre$getDT()
      }
      
    }) 
    
    ### plots via la checkbox : 
    # output[[plotsid]] <- renderUI({
    #   ## si un element est cliqué dans la checkbox, les graphiques à afficher sont calculés :
    #   output <- values[[tabsetid]]$filtre$get_plot_output_list(colonnes_cocher = values$checkbox)
    #   
    #   if (length(values$deleted_last) == 1 && !values$deleted_last){ ## si ce n'est pas un suppression ; alors on calcule les graphiques
    #     make_plot()
    #   }
    #   #print(output)
    #   return(output)
    # })
    
    ### liste toutes les lignes (points...) pouvant être sélectionnées
    observe({
      
      ligne <- input[[paste0(tableauid, "_rows_all")]]
      if (!is.null(ligne)){
        values[[tabsetid]]$filtre$set_selectionid(ligne)
        cat (nrow(values[[tabsetid]]$filtre$df_selectionid)," lignes sélectionnés dans le tableau \n ")
      }
    })
  } ### fin make_tabset
  
  add_remove_function = function(tabsetid){
    observeEvent(input[[paste0("boutton",tabsetid,"name")]], {
      values[[tabsetid]] <- NULL ### retirer de values les valeurs concernant ce tabsetid
      bouttonid <- paste0("boutton",tabsetid,"name")
      #tabsetid <- paste0("#tab-",tabsetid)
      session$sendCustomMessage(type = 'removeTabToTabset',
                                message = list(tabsetid = paste0("#tab-",tabsetid), bouttonid = bouttonid))
      
      get_values()
    })
  }

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

