setRefClass(
  # Nom de la classe
  "Filtre",
  # Attributs
  fields =  c(
    df = "data.frame", ## la dataframe
    metadf = "list", ## metadonnees sur df
    
    lignes_selection = "vector",
    
    graphiques = "data.frame", ### liste des graphiques disponibles
    
    num_colonneid = "numeric",  # numéro de la colonne contenant l'identifiant unique

    ## le filtre se place dans un tabset, celui-ci à un id :
    tabsetid = "numeric",
    
    checkbox_clics = "vector", ## eep track de l'ordre des clics dans la checkbox
    
    deleted_last = "logical" ## savoir si on a retiré ou enlevé un graphique
    
  ),
  
  # Fonctions :
  
  methods=list(
    
    set_lignes_selection = function(lignes){
      lignes_selection <<- lignes
    },
    
    get_df_selection = function(){
      return(df[lignes_selection,])
    },
    
    check_colnames = function(df, colonnes){
      bool <- colonnes %in% colnames(df)
      if (all(bool)){
        return(T)
      } else {
        stop(colonnes[!bool], " non trouvées dans df")
      }
    },
    
    ### Constructeur
    initialize = function(df, metadf, tabsetid){
      require(shiny)
      
      cat ("Création d'un nouveau filtre")
      ### vérification metadf et df
      bool <- is.list(metadf)
      if (!bool){
        stop("metadf n'est pas de type liste \n")
      }
    
      
      check_colnames(df, metadf$colonne_id)
      check_colnames(df, metadf$colonnes_tableau)
      
      bool <- length(metadf$type_colonnes_tableau) == length(metadf$colonnes_tableau)
      if (!bool){
        stop("metadf : type colonnes_tableau longueur différente de colonnes_tableau")
      }
      
      bool <- metadf$type_colonnes_tableau %in% c("numeric",NA,"factor","date") ## tout ce que je prend en charge pour l'instant
      if (!all(bool)){
        stop("type", metadf$type_colonnes_tableau[!bool], "non pris en charge")
      }
      
      ## fin verif
      df <<- df
      metadf <<- metadf
      tabsetid <<- tabsetid
      
      num_colonneid <<- which(colnames(df) == metadf$colonne_id)
      
      lignes_selection <<- 1:nrow(df) ## toutes les lignes sélectionnées à l'initialisation
      
      graphiques <<- data.frame(idHTML=factor(), colonne = character(), commande=character())
      ## idHTML : id du div HTML du graphique
      ## colonne : colonne de df 
      ## commande : graphique à réaliser pour cet id du divHTML avec cette colonne de df
    },
    
    
    getCheckBox = function(){
      # checkboxes pour selectionner les variables
      inputId <- get_checkboxid()
      shiny::checkboxGroupInput(inputId, "Cocher pour afficher les graphiques:", 
                         choices  = metadf$colonnes_tableau,
                         selected = NULL,inline=T)
    },
    
    getDT = function(){
      num_colonnes_tableau <- colnames(df) %in% metadf$colonnes_tableau
      ncolonnes <- sum(num_colonnes_tableau) - 1
      DT::datatable(df[,num_colonnes_tableau], width="auto",
                    rownames = F, caption="", filter="top", ## pas de rownames, ni de catpion, filter en haut
                    fillContainer =F, style="bootstrap",
                    options = list(
                      columnDefs = list(list(className = 'dt-center', targets = 0:ncolonnes))))
    },
    
    ## renvoie la liste (balises html) des plots à afficher
    get_plot_output_list = function(){
      plot_output_list <- vector(mode = "list")
      for (i in checkbox_clics){
        num <- which(colnames(df) == i) ## numéro de la colonne
        classe <- metadf$type_colonnes_tableau[metadf$colonnes_tableau == i] ## la classe de la colonne donne le type de plot à afficher
        plot_output_list[[i]] <- getRightUi(colonne_cocher = i, classe)
      }
      do.call(tagList, plot_output_list) ## nécessaire pour l'affichage HTML
    },
    
    ### fonction private pour get_plot_output_list : type d'Output à afficher selon la variable
    getRightUi = function(colonne_cocher, classe){
      if (classe == "factor") {
        ## 
        idbarplot <- paste0("barplot",colonne_cocher,"event",tabsetid)
        bool <- idbarplot %in% graphiques$id ## vérifie si le plot est connu ou pas
        if (!bool){
          ajout <- data.frame(idHTML = c(idbarplot), colonne = colonne_cocher, commande=c("factor_graphique"))
          graphiques <<- rbind(graphiques, ajout)
        }
        
        ## encapsuler pour permettre au CSS de mettre cote à cote les graphiques d'une meme variable
        ajoutdiv <- paste0("<div id=factor_graphics_", tabsetid, colonne_cocher,">")
        liste <- list(HTML(ajoutdiv),HTML("<h4>",colonne_cocher,"</h4>"),shiny::plotOutput(idbarplot,width = "50%"))
        return (do.call(tagList, liste))
        }
      # else if (classe == "integer") return (shiny::plotOutput(id))
      else if (classe == "numeric") {
        ## plusieurs graphiques pour la classe integer
        # l identifiant correspond à la colonne + le nom de la fonction
        idboxplot <- paste0("boxplot",colonne_cocher, "event",tabsetid) ## id du div HTML
        #idhisto <- paste0("histo",colonne_cocher, "event",tabsetid) ## id du div HTML
        #output <- list(plotlyOutput(idplotly), plotOutput(idhisto))
        
        ## ajout dans la data.frame graphique pour savoir ce qu'il faut plotter
        bool <- idboxplot %in% graphiques$id ## vérifie si le plot est connu ou pas
        if (!bool){
          #ajout <- data.frame(idHTML = c(idplotly, idhisto), colonne = colonne_cocher, commande=c("plotly_scatter","hist"))
          ajout <- data.frame(idHTML = c(idboxplot), colonne = colonne_cocher, commande=c("numerique_graphique"))
          graphiques <<- rbind(graphiques, ajout)
        }
        
        ## encapsuler pour permettre au CSS de mettre cote à cote les graphiques d'une meme variable
        ajoutdiv <- paste0("<div id=numeric_graphics_", tabsetid, colonne_cocher,">")
        # liste <- list(HTML(ajoutdiv),shiny::plotOutput(idplotly,width = '50%'),
        #               plotOutput(idhisto,width = '50%'), HTML("</div>"))
        liste <- list(HTML(ajoutdiv),HTML("<h4>",colonne_cocher,"</h4>"),shiny::plotOutput(idboxplot,width = "50%"),HTML("</div>"))
        return (do.call(tagList, liste))
      } else if (classe == "date") {
        iddates <- paste0("dates",colonne_cocher, "event",tabsetid) ## id du div HTML
        #idhisto <- paste0("histo",colonne_cocher, "event",tabsetid) ## id du div HTML
        #output <- list(plotlyOutput(idplotly), plotOutput(idhisto))
        
        ## ajout dans la data.frame graphique pour savoir ce qu'il faut plotter
        bool <- iddates %in% graphiques$id ## vérifie si le plot est connu ou pas
        if (!bool){
          #ajout <- data.frame(idHTML = c(idplotly, idhisto), colonne = colonne_cocher, commande=c("plotly_scatter","hist"))
          ajout <- data.frame(idHTML = c(iddates), colonne = colonne_cocher, commande=c("dates_graphique"))
          graphiques <<- rbind(graphiques, ajout)
        }
        
        ## encapsuler pour permettre au CSS de mettre cote à cote les graphiques d'une meme variable
        ajoutdiv <- paste0("<div id=numeric_graphics_", tabsetid, colonne_cocher,">")
        # liste <- list(HTML(ajoutdiv),shiny::plotOutput(idplotly,width = '50%'),
        #               plotOutput(idhisto,width = '50%'), HTML("</div>"))
        liste <- list(HTML(ajoutdiv),HTML("<h4>",colonne_cocher,"</h4>"),shiny::plotOutput(iddates,width = "50%"),HTML("</div>"))
        return (do.call(tagList, liste))
      } else {
        stop("classe : ", classe , "non trouvée \n")
      }
    },
    
    getRightPlot = function(idHTML){
      bool <- graphiques$idHTML == idHTML
      if (!any(bool)){
        stop(idHTML, "non trouvée dans les graphiques à réaliser \n")
      }
      temp <- subset (graphiques, bool)
      num <- which(colnames(df) == temp$colonne) ## quel est la variable concernée pour ce graphique ?
      initial_x <- df[,num]
      index_selection <- lignes_selection
      nom_variable <- colnames(df)[num]
      
      if (temp$commande == "numerique_graphique"){
        return(renderPlot(numerique_box_comparaison(initial_x, index_selection)))
      }
      if (temp$commande == "factor_graphique"){
        return(renderPlot(barplot_graphique_comparaison(initial_x, index_selection, nom_variable)))
      }
      
      if (temp$commande=="dates_graphique"){
        return(renderPlot(dates_graphique_comparaison(initial_x, index_selection, nom_variable)))
      }
      
      ## quel graphique réalisé ?
      # if (temp$commande == "plotly_scatter"){
      #   return(renderPlotly(plot_ly(x = 1:nrow(df_selectionid), y = ~x,
      #           type="scatter",mode="markers",source="delai")))
      # }
      # if (temp$commande == "hist"){
      #   return(renderPlot(hist(x)))
      # }
      # 
      # if (temp$commande=="plotly_pie"){
      #   return (renderPlotly(create_pie(x)))
      # }
    },
    
    
    # create_pie = function(x){
    #   valeurs <- table(x)
    #   plot_ly(labels = names(valeurs), values = valeurs, type = 'pie',source="test") %>%
    #     layout(title = "nomvariable",
    #            xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
    #            yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    # },
    
    remove_graphiques = function(colonne){
      bool <- colonne %in% graphiques$colonne
      graphiques <<- subset (graphiques, !bool)
    },
    
    ## l'id du tableau DT
    get_tableauid = function(){
      return(paste0("tableau",tabsetid))
    },
    
    get_checkboxid = function(){
      return(paste0("checkbox",tabsetid))
    },
    
    get_plotsid = function(){
      return(paste0("plots",tabsetid))
    },
    
    set_checkbox_clics = function(checkbox_clics){
      checkbox_clics <<- checkbox_clics
    },
    
    set_deleted_last = function(bool){
      deleted_last <<- bool
    }
  )
)






###### Ancienne version de cette fonction : utilsiation de plotly
## mais problème lorsqu'il y a trop de points à afficher en Javascript
## plante vite avec un piechart
# getRightUi = function(colonne_cocher, classe){
#   if (classe == "factor") {
#     ## 
#     idplotly <- paste0(tabsetid, colonne_cocher,"plotlypie")
#     bool <- idplotly %in% graphiques$id ## vérifie si le plot est connu ou pas
#     if (!bool){
#       ajout <- data.frame(idHTML = c(idplotly), colonne = colonne_cocher, commande=c("plotly_pie"))
#       graphiques <<- rbind(graphiques, ajout)
#     }
#     
#     ## encapsuler pour permettre au CSS de mettre cote à cote les graphiques d'une meme variable
#     ajoutdiv <- paste0("<div id=factor_graphics_", tabsetid, colonne_cocher,">")
#     liste <- list(HTML(ajoutdiv),plotlyOutput(idplotly,width = '22%'))
#     return (do.call(tagList, liste))
#   }
#   # else if (classe == "integer") return (shiny::plotOutput(id))
#   else if (classe == "numeric") {
#     ## plusieurs graphiques pour la classe integer
#     # l identifiant correspond à la colonne + le nom de la fonction
#     idplotly <- paste0(tabsetid,colonne_cocher,"plotly") ## id du div HTML
#     idhisto <- paste0(tabsetid, colonne_cocher,"hist") ## id du div HTML
#     #output <- list(plotlyOutput(idplotly), plotOutput(idhisto))
#     
#     ## ajout dans la data.frame graphique pour savoir ce qu'il faut plotter
#     bool <- idplotly %in% graphiques$id ## vérifie si le plot est connu ou pas
#     if (!bool){
#       ajout <- data.frame(idHTML = c(idplotly, idhisto), colonne = colonne_cocher, commande=c("plotly_scatter","hist"))
#       graphiques <<- rbind(graphiques, ajout)
#     }
#     
#     ## encapsuler pour permettre au CSS de mettre cote à cote les graphiques d'une meme variable
#     ajoutdiv <- paste0("<div id=numeric_graphics_", tabsetid, colonne_cocher,">")
#     liste <- list(HTML(ajoutdiv),plotlyOutput(idplotly,width = '50%'),
#                   plotOutput(idhisto,width = '50%'), HTML("</div>"))
#     return (do.call(tagList, liste))
#   }
# },




### fonction permettant la création d'une table de méta données ; utiliser par le filtre
create_metadf <- function(colonne_id, colonnes_tableau,type_colonnes_tableau){
  metadf <- list()
  metadf[["colonne_id"]] <- colonne_id
  metadf[["colonnes_tableau"]] <- colonnes_tableau
  metadf[["type_colonnes_tableau"]] <- type_colonnes_tableau
  return(metadf)
}
