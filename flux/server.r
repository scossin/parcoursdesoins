library(DT)
#### Sélection des différents flux qu'on voudrait visualiser
load("../server/V4/tableau/MetaDonneesEtab33.rdata")
str(locEtab33)
locEtab33$X <- as.numeric(as.character(locEtab33$X))
data_sets <- c("locEtab33","mtcars", "morley", "rock")

shinyServer(function(input, output) {

  # Drop-down selection box for which data set
  output$choose_dataset <- renderUI({
    selectInput("dataset", "Data set", as.list(data_sets))
  })

  # Check boxes
  output$choose_columns <- renderUI({
    # If missing input, return to avoid error later in function
    if(is.null(input$dataset))
      return()

    # Get the data set with the appropriate name
    dat <- get(input$dataset)
    colnames <- names(dat)

    # Create the checkboxes and select them all by default
    checkboxGroupInput("columns", "Choose columns", 
                        choices  = colnames,
                        selected = NULL)
  })

  # filtre ! : 
  
  ## keep track of elements inserted and not yet removed
  inserted <- c()
  
  observe({
    
    ## si ajout d'un filtre : length(inserted) < length(input$columns)
    ## sinon length(inserted) > length(input$columns)
    cat("inserted : ", inserted, "\n")
    cat("columns : ", input$columns, "\n")
    
    if (length(inserted) < length(input$columns)){
      ajout <- which(!input$columns %in% inserted)
      id <- input$columns[ajout]
      label <- id
      cat ("demande ajout filtre : ", id, "\n ")
      
      insertUI(
        selector = "#add",
        where = "afterEnd",
        #ui = textInput(id, paste0("id : ", id))
        getRightUi(id, label)
      )
      inserted <<- c(id, inserted)
    }
    
    if (length(inserted) > length(input$columns)){
      retrait <- which(!inserted %in% input$columns)
      id <- inserted[retrait]
      cat ("demande retrait filtre : ", id, "\n ")
      removeUI(
        ## pass in appropriate div id
        selector = paste0("#",id,"ajout")
        #selector = paste0("div:has([name='for'].val('mpg'))")
      )
      inserted <<- inserted[-retrait]
    }
  })
  
  observe(
  
    cat(input$columns, "modifié !!"))
  
  ##### ajouter un boutton pour recevoir les filtres mis en place par l'utilisateur
  observe(
    for (i in input$columns){
      cat(input[[i]])
    }
  )
  
  
  
  # Output the data
  output$data_table <-  DT::renderDataTable({
    # If missing input, return to avoid error later in function
    if(is.null(input$dataset))
      return()
    
    # Get the data set
    dat <- get(input$dataset)
    
    # Make sure columns are correct for data set (when data set changes, the
    # columns will initially be for the previous data set)
    if (is.null(input$columns) || !(input$columns %in% names(dat)))
      return()
    
    # Keep the selected columns
    dat <- dat[, input$columns, drop = FALSE]
    
    # Return first 20 rows
    # output$tableau <- DT::renderDataTable({
    #  
    # })
    DT::datatable(dat,rownames = F, caption="légende du tableau", filter="top", extensions="AutoFill",fillContaine=F,
                  style="bootstrap")
    #head(dat, 20)
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
  
  ### important : englober l'ui dans un div car certains ui ont un ou plusieurs div
  # ce qui rend le removeUI difficile en Jquery
  ajoutdiv <- paste0("<div id=",id,"ajout>")
  liste <- list(HTML(ajoutdiv),ui, HTML("</div>"))
  return(do.call(tagList, liste))
}
