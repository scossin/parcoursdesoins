setRefClass(
  # Nom de la classe
  "Event",
  # Attributs
  fields =  c(
    ## changer ensuite par table - interroger la base de données
    df_events = "data.frame", ## data.frame contenant la liste des évènements (ou connection à une DB)
    df_type_selected = "data.frame", ## data.frame contenant 2 colonnes : events et agregat
    df_events_selected = "data.frame", ## après le choix de l'utilisateur, les évènements pour la sélection
    ## contient le choix de l'utilisateur
    #hierarchy = "list",
    df_next_events = "data.frame", ## évènements précédents en fonction de df_events et df_type_selected
    df_previous_events = "data.frame", ## évènements suivants en fonction de df_events et df_type_selected
    filtres = "list",
    spatial="ANY",
    event_number = "numeric" ## numéro d'event permettant d'ordonner les events
  ),
  
  # Fonctions :
  methods=list(
    ### Constructeur
    initialize = function(df_events, event_number){
      df_events <<- df_events
      event_number <<- event_number
    },
    
    set_df_type_selected = function(df_type_selected){
      bool <- c("events","agregat") %in% colnames(df_type_selected) 
      if (!all(bool)){
        stop ("df_type_selected ne contient pas toutes les colonnes : events et agregat")
      }
      
      df_type_selected <<- df_type_selected
      
      df_next_events <<- data.frame(patient=character(), type=factor(),
                                    event = factor(), num=numeric()) ## ré-initialise les events suivants
      df_previous_events <<- data.frame(patient=character(), type=factor(),
                                        event = factor(), num=numeric()) ## ré-initialise les events précédents
      
      
      #### création d'un objet filtre pour filtrer les évènements :
      ## type_selected <- c("SejourUM","SejourUM")
      type_selected <- df_type_selected$events
      type_selected <- paste(type_selected,collapse="','") ## pour la requete SQL suivante
      
      ### liste des évènements à filtrer :
      # subset_df_events <- sqldf(paste0("select patient, event, num, type FROM df_events where type in ('",type_selected,"')"))

      subset_df_events <- sqldf(paste0("select * FROM df_events where type in ('",type_selected,"')"))
      
      ## cette dernière df sera vide si le type d'event sélectionné n'est pas prénset :
      if (nrow(subset_df_events) == 0){
        cat ("Aucun évènement à filtrer")
        return(NULL)
      }
      
      subset_df_events$type <- as.factor(subset_df_events$type)
      subset_df_events$agregat <- as.factor(unique(df_type_selected$agregat))
      
      ### jointure à faire sur table de métadonnées :
      
      # fake colonne duree :
      
      subset_df_events$duree <- round(rnorm(nrow(subset_df_events),mean=100,sd = 20),0)
      
      
      ### meta données (à récupérer via une base de données) :
      colonne_id <- "patient"
      colonnes_tableau <- c("type","duree","TimeToStart","TimeToEnd","agregat")
      type_colonnes_tableau <- c("factor","numeric","numeric","numeric","factor")
      
     
      ### Pour un démo : ajouter des attributs à SejourMCO et SejourSSR : 
      # A retirer apres la démo : récupérer les attributs et leur type en base de données
      agregat <- unique(df_type_selected$agregat)
      if (agregat %in% c("SejourHospitalier","SejourMCO","SejourSSR")){
        load("rdata/ATTR_SejourHospitalier.rdata")
        subset_df_events <- merge (subset_df_events, ATTR_SejourHospitalier, by=c("patient","num"), all.x=T)
        colonnes_SejourHospitalier <- c("nofinesset","RaisonSociale","libcategetab","dep","INSEE_COM")
        colonnes_tableau <- c(colonnes_tableau, colonnes_SejourHospitalier)
        if (agregat == "SejourMCO"){
          colonnes_tableau <- c(colonnes_tableau, "UNV")
        }
        if (agregat == "SejourSSR"){
          colonnes_tableau <- c(colonnes_tableau, c("SSRadulte","SSRenfant"))
        }
        add_factors <- rep("factor",length(colonnes_tableau) - length(type_colonnes_tableau))
        type_colonnes_tableau <- c(type_colonnes_tableau, add_factors)
      } ## fin ajout attributs pour démo

      
      ## devrait etre une fonction statique de eventOO.R mais pas de fonction statique en R5
      metadf <- create_metadf(colonne_id, colonnes_tableau, type_colonnes_tableau)
      
      # tabsetid <- paste0("tabset",event_number) ## avec js ça 
      filtres[[paste0("filtre",event_number)]] <<- new("Filtre",df=subset_df_events, metadf,tabsetid = event_number)
      set_df_events_selected() ## les events_selected par défaut si aucun filtre par l'utilisateur
    },
    
    get_type_selected = function(){
      if (is.null(df_type_selected)){
        cat("df_type_selected is null : pas d'events selected")
        return(NULL)
      } else {
        return (unique(df_type_selected$events))
      }
    },
    
    ### prend la hiérarchie en entrée et met le nombre de valeurs entre parenthèse
    ## renvoie une liste ; est utilisée par shinyTree
    get_type = function(hierarchy,get_hierarchylistN){
      temp <- sqldf("select distinct patient, type from df_events") ## selectionne les différents types d'évènements
      return(temp$type)
    },
    
    set_df_events_selected = function(){
      if (length(filtres) == 0){
        cat("filtre non créé, impossible de calculer df_next_events ou df_events_selected")
        return(1)
      }
      ## Avant je prenais min(num) as num mais le problème est que si lors du filtre, le premier évènement n'est pas sélectionné
      # il faut que l'évènement suivant soit sélectionné 
      # par exemple SejourMCO puis SejourSSR ; on filtre donc sur tous les évènements sélectionnés
      # même si un seul sera sélectionné par patient
      
      ### récupérer la sélection des events actuels
      df_selection <- NULL
      for (i in length(filtres)){
        df_selection <- rbind (filtres[[i]]$get_df_selection())
      }
      ## vérifier qu'on ait les memes colonnes si filtres d'évènements différents
      # avant de faire un rbind ici
      
      #df_selection <- subset (df_selection, select = c("patient","num"))
      
      ## on choisit l'évènement le plus récent par patient : 
      # le plus petit num 
      tab <- tapply(df_selection$num, df_selection$patient, min)
      tab <- data.frame(patient=names(tab), num=as.numeric(tab))
      ### les évènements sélectionnés via le filtre :
      #colnames(df_events)
      
      df_events_selected <<- merge (df_selection,tab, by=c("patient","num"))
      return(0)
    },
    
    set_spatial = function(){
      ### mise à jour de l'objet spatial : 
      ## séquence spatiale : uniquement pour tabset 0
      if (event_number == 0){
        if (!set_df_events_selected()) {## mise à jour de la sélection
          spatial <<- new("spatial",tab_spatial = tab_spatial, df_selection =  df_events_selected)
        } 
      }
      return(NULL)
    },
    
    ### calcule les évènements suivants en fonction des évènements sélectionnés
    set_df_nextprevious_events = function(boolnext){
      resultat <- set_df_events_selected() ## 
      if (resultat){
        return(NULL)
      }
      # df_events_selected <- sqldf(paste0("select patient, datestartevent, dateendevent, type, min(num) as num FROM df_events where type in ('",type_selected,"')
      #                                GROUP BY patient"))
      
      # récupérer tous les df_events après ce num event par patient 
      # ? possible en SQL ?
      # ma solution : créer une table d'events à sélectionner, générer par un langage de programmation
      # la charger dans la base et faire un merge
      
      # autre idée : commencer par un petit nombre de patients :
      # calculer le nombre d'events next pour eux 
      # prendre 0.95 de la distrib pour déterminer N events next
      # evite de récupérer tous les events
      
      ## Etape 2 : dénombrer les events entre num_main_event +1 à num_max_event
      # on commence par récupérer le num max par patient : 
      
      #### on récupère tous les évènements avant ou après l'évènement
      ## previous : tous avant 
      ## next : tous après
      # on commence par connaitre le min(num) ou max(num)
      if (boolnext){
        num_max_event <- sqldf(paste0("select patient, max(num) as max FROM df_events 
                                    GROUP BY patient "))
      } else {
        num_max_event <- sqldf(paste0("select patient, min(num) as max FROM df_events 
                                    GROUP BY patient "))
        ## oui c'est étrange ce min(num) as max : c'est pour garder le nom de la colonne
        # il s'agit bien de min
      }

      ## df des evenements selectionnés => on récupère les dates pour calculer des durées
      df_current_event <- sqldf("Select a.patient, a.num, a.datestartevent, a.dateendevent, a.type from df_events a
              JOIN df_events_selected b ON a.patient=b.patient AND a.num = b.num")
      
      ### dans les étapes suivantes on crée une df allant du num_event à min ou max event
      num_main_max <- merge (df_current_event, num_max_event, by="patient")
      ## si num_main_event = num_max_event, il n'y en a pas après donc on retire :
      bool <- num_main_max$num == num_main_max$max
      num_main_max <- subset(num_main_max, !bool)
      num_main_max$patientfromto <- paste(num_main_max$patient,num_main_max$num,num_main_max$max,sep=";")
      df_event_next <- NULL ### il s'agit de previous event si boolnext=F
      
      #boolnext <- F
      for (x in num_main_max$patientfromto){
        temp <- unlist(strsplit(x,";"))
        if (boolnext){
          vecteur <- seq(as.numeric(temp[2])+1, as.numeric(temp[3]),by=1) ## +1 : next event
        } else {
          vecteur <- seq(as.numeric(temp[3]), as.numeric(temp[2])-1,by=1) ## -1 : previous event
        }
        df_event_next <- rbind(df_event_next,data.frame(patient=temp[1],num=vecteur))
      }
      
      if (is.null(df_event_next)){
        cat("Aucun évènement précédent")
        return(NULL)
      }
      ### Df créé, on peut maintenant récupérer ces évènements par une requete dans la base
      ## Ici on loaderait dans la base de données df_event_next
      # puis on a la requête suivante :
      #colnames(df_events)
      df_next_temp <- sqldf("Select a.patient, a.event, a.num, a.datestartevent,  a.dateendevent, a.type from df_events a
              JOIN df_event_next b ON a.patient=b.patient AND a.num = b.num")
      # df_next_temp : tous les events next le main_event qu'on proposera à l'utilisateur
      
      ## on calcule aussi 2 indicateurs : délai entre début main et fin main 
      colnames(df_current_event) <- c("patient","mainnum","mainstart","mainend", "maintype") ## garde mainnum pour filtrer rapidement
      ## au lieu de devoir recalculer tous les next elements
      df_next_temp <- merge (df_current_event,df_next_temp, by="patient")
      
      ## calcul du temps : début - début et fin - début
      if (boolnext){
        df_next_temp$TimeToStart <- difftime(df_next_temp$datestartevent,df_next_temp$mainstart,units="day")
        df_next_temp$TimeToEnd <- difftime(df_next_temp$datestartevent,df_next_temp$mainend,units="day")
      } else {
        df_next_temp$TimeToStart <- difftime(df_next_temp$mainstart,df_next_temp$datestartevent,units="day")
        df_next_temp$TimeToEnd <- difftime(df_next_temp$mainend,df_next_temp$datestartevent,units="day")
      }
      df_next_temp$TimeToStart <- as.numeric(df_next_temp$TimeToStart)
      df_next_temp$TimeToEnd <- as.numeric(df_next_temp$TimeToEnd)
      
      ## retire tout ce qui concerne le main event
      df_next_temp$mainend <- NULL
      df_next_temp$mainstart <- NULL
      df_next_temp$mainnum <- NULL
      df_next_temp$maintype <- NULL
      if (boolnext){
        df_next_events <<- df_next_temp
      } else {
        df_previous_events <<- df_next_temp
      }
    },
    
    
    #### ids :
    get_treebouttonid = function(){
      return (paste0("treeboutton",event_number))
    },
    
    get_addpreviousid = function(){
      return (paste0("addprevious",event_number))
    },
    
    get_addnextid = function(){
      return (paste0("addnext",event_number))
    },
    
    get_validateid = function(){
      return (paste0("validate",event_number))
    },
    
    get_removeid = function(){
      return (paste0("remove",event_number))
    },
    
    get_h4 = function(){
      return (paste0("event",event_number))
    },
    
    get_event_number = function(){
      return(event_number)
    }, 
    
    get_treeid = function(){
      return(paste0("tree",event_number))
    }
    
  )
)
