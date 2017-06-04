setRefClass(
  # Nom de la classe
  "Filtre",
  # Attributs
  fields =  c(
    df = "data.frame", ## la dataframe
    metadf = "data.frame", ## metadonnees sur df
    df_selectionid = "data.frame", ## current selection
    
    graphiques = "data.frame", ### liste des graphiques disponibles
    
    colonnes_tableau = "vector", ## colonnes à afficher dans le tableau
    colonnes_graphiques = "vector", ## colonnes pouvant etre selectionner pour afficher un graphique
    
    num_colonneid = "numeric",  # numéro de la colonne contenant l'identifiant unique

    selectionid ="vector" ## les ids selectionnes
  ),
  
  # Fonctions :
  methods=list(
    ### Constructeur
    
    initialize = function(df, metadf){
      require(plotly)
      require(shiny)
      df <<- df
      metadf <<- metadf
      
      ## colonnes pour le tableau
      colonnes_tableau <<- as.vector(metadf$colonnes[as.logical(metadf$intableau)])
      
      ## colonnes pour la checkbox (graphique)
      colonnes_graphiques <<- as.vector(metadf$colonnes[as.logical(metadf$ingraphique)])
      
      num_colonneid <<- which(colnames(df) == as.vector(metadf$colonnes[as.logical(metadf$isid)]))
      
      selectionid <<- df[,num_colonneid] ## tous les ids sont selectionnes par defaut
      df_selectionid <<- df ## data.frame contenant la selection
      
      graphiques <<- data.frame(idHTML=factor(), colonne = character(), commande=character())
      ## idHTML : id du div HTML du graphique
      ## colonne : colonne de df 
      ## commande : graphique à réaliser pour cet id du divHTML avec cette colonne de df
    },
    
    
    getCheckBox = function(){
      # checkboxes pour selectionner les variables
      shiny::checkboxGroupInput("coche_graphique", "Cocher pour afficher les graphiques:", 
                         choices  = colonnes_graphiques,
                         selected = NULL,inline=T)
    },
    
    getDT = function(){
      num_colonnes_tableau <- colnames(df) %in% colonnes_tableau
      ncolonnes <- sum(num_colonnes_tableau) - 1
      DT::datatable(df[,num_colonnes_tableau], width="auto",
                    rownames = F, caption="", filter="top", ## pas de rownames, ni de catpion, filter en haut
                    fillContainer =F, style="bootstrap",
                    options = list(
                      columnDefs = list(list(className = 'dt-center', targets = 0:ncolonnes))))
    },
    
    ## renvoie la liste (balises html) des plots à afficher
    get_plot_output_list = function(colonnes_cocher){
      plot_output_list <- vector(mode = "list")
      for (i in colonnes_cocher){
        num <- which(colnames(df) == i) ## numéro de la colonne
        classe <- metadf$type[metadf$colonnes == i] ## la classe de la colonne donne le type de plot à afficher
        plot_output_list[[i]] <- getRightUi(colonne_cocher = i, classe)
      }
      do.call(tagList, plot_output_list) ## nécessaire pour l'affichage HTML
    },
    
    ### fonction private pour get_plot_output_list : type d'Output à afficher selon la variable
    getRightUi = function(colonne_cocher, classe){
      if (classe == "factor") {
        ## 
        idplotly <- paste0(colonne_cocher,"plotlypie")
        bool <- idplotly %in% graphiques$id ## vérifie si le plot est connu ou pas
        if (!bool){
          ajout <- data.frame(idHTML = c(idplotly), colonne = colonne_cocher, commande=c("plotly_pie"))
          graphiques <<- rbind(graphiques, ajout)
        }
        return (plotlyOutput(idplotly,width = '22%'))
        }
      # else if (classe == "integer") return (shiny::plotOutput(id))
      else if (classe == "integer") {
        ## plusieurs graphiques pour la classe integer
        # l identifiant correspond à la colonne + le nom de la fonction
        idplotly <- paste0(colonne_cocher,"plotly") ## id du div HTML
        idhisto <- paste0(colonne_cocher,"hist") ## id du div HTML
        #output <- list(plotlyOutput(idplotly), plotOutput(idhisto))
        
        ## ajout dans la data.frame graphique pour savoir ce qu'il faut plotter
        bool <- idplotly %in% graphiques$id ## vérifie si le plot est connu ou pas
        if (!bool){
          ajout <- data.frame(idHTML = c(idplotly, idhisto), colonne = colonne_cocher, commande=c("plotly_scatter","hist"))
          graphiques <<- rbind(graphiques, ajout)
        }
        
        ## encapsuler pour permettre au CSS de mettre cote à cote les graphiques d'une meme variable
        ajoutdiv <- paste0("<div id=",colonne_cocher,"_graphiques>")
        liste <- list(HTML(ajoutdiv),plotlyOutput(idplotly,width = '50%'),
                      plotOutput(idhisto,width = '50%'), HTML("</div>"))
        return (do.call(tagList, liste))
      }
    },
    
    getRightPlot = function(idHTML){
      # num <- which(colnames(df) == id) ### numero de la colonne
      # classe <- class(df[,num])
      # #if (classe=="integer") return (renderPlot(boxplot(df_selectionid[,num])))
      # if (classe=="integer") return (renderPlotly(
      #   plot_ly(x = 1:nrow(df_selectionid), y = ~df_selectionid[,num],
      #       type="scatter",mode="markers",source="delai")))
      # if (classe=="factor") return (renderPlotly(create_pie(id,df_selectionid[,num])))
      
      bool <- graphiques$idHTML == idHTML
      temp <- subset (graphiques, bool)
      num <- which(colnames(df) == temp$colonne) ## quel est la variable concernée pour ce graphique ?
      x <- df_selectionid[,num] # c'est x
      
      ## quel graphique réalisé ?
      if (temp$commande == "plotly_scatter"){
        return(renderPlotly(plot_ly(x = 1:nrow(df_selectionid), y = ~x,
                type="scatter",mode="markers",source="delai")))
      }
      if (temp$commande == "hist"){
        return(renderPlot(hist(x)))
      }
      
      if (temp$commande=="plotly_pie"){
        return (renderPlotly(create_pie(x)))
      }
    },
    
    
    create_pie = function(x){
      valeurs <- table(x)
      plot_ly(labels = names(valeurs), values = valeurs, type = 'pie',source="test") %>%
        layout(title = "nomvariable",
               xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
               yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    },
    
    remove_graphiques = function(colonne){
      bool <- colonne %in% graphiques$colonne
      graphiques <<- subset (graphiques, !bool)
    },
    
    get_selectionid = function(){
      return(selectionid)
    },
    
    set_selectionid = function(ids){
      selectionid <<- ids
      bool <- df[,num_colonneid] %in% ids
      df_selectionid <<- subset (df, bool)
    },
    
    get_ids_fromrows = function(rows_selected){
      temp_df <- subset (df, id %in% selectionid)
      ids <- temp_df[,num_colonneid]
      ids_rows_selected <- ids[rows_selected]
      return(ids_rows_selected)
    }
  )
)

