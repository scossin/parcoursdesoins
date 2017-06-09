setRefClass(
  # Nom de la classe
  "Event",
  # Attributs
  fields =  c(
    ## changer ensuite par table - interroger la base de données
    df_events = "data.frame", ## data.frame contenant la liste des évènements (ou connection à une DB)
    df_type_selected = "data.frame", ## data.frame contenant 2 colonnes : events et agregat
      ## contient le choix de l'utilisateur
    #hierarchy = "list",
    df_next_events = "data.frame", ## évènements précédents en fonction de df_events et df_type_selected
    df_previous_events = "data.frame", ## évènements suivants en fonction de df_events et df_type_selected
    filtres = "list",
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
      type_selected <- paste(type_selected,collapse="','")
      ### liste des évènements à filtrer :
      #print(df_events)
      subset_df_events_selected <- sqldf(paste0("select patient, event, num, type FROM df_events where type in ('",type_selected,"')"))
      
      ## cette dernière df sera vide si le type d'event sélectionné n'est pas prénset :
      if (nrow(subset_df_events_selected) == 0){
        cat ("Aucun évènement à filtrer")
        return(NULL)
      }
      
      ### ici j'ai une connexion à une base de données pour récupérer les attributs des évènements
      ## choisis
      # pour l'instant j'utilise une table d'attribut fictive :
      
      subset_df_events_selected$duree <- rnorm(nrow(subset_df_events_selected), 10, 2)
      subset_df_events_selected$categorie <- "H"
      # colnames(subset_df_events_selected)
      colonnes <- colnames(subset_df_events_selected)
      #str(subset_df_events_selected)
      subset_df_events_selected$type <- as.factor(subset_df_events_selected$type)
 
      metadf <- data.frame(colonnes = colonnes, isid=c(1,0,0,0,0,0), type=c(NA,"NA","NA","factor","integer","factor"),
                           intableau = c(0,0,0,1,1,1), ingraphique = c(0,0,0,1,1,0))
      filtres[[paste0("filtre",event_number)]] <<- new("Filtre",df=subset_df_events_selected, metadf,event_number)
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
    get_tree_events = function(hierarchy){
      temp <- sqldf("select distinct patient, type from df_events") ## selectionne les différents types d'évènements
      get_hierarchylistN(hierarchy, temp$type)
    },
    
    ### calcule les évènements suivants en fonction des évènements sélectionnés
    set_df_nextprevious_events = function(boolnext){
      if (length(filtres) == 0){
        cat("filtre non créé, impossible de calculer df_next_events")
        return(NULL)
      }
      
      ## Avant je prenais min(num) as num mais le problème est que si lors du filtre, le premier évènement n'est pas sélectionné
      # il faut que l'évènement suivant soit sélectionné 
      # par exemple SejourMCO puis SejourSSR ; on filtre donc sur tous les évènements sélectionnés
      # même si un seul sera sélectionné par patient
      
      ### récupérer la sélection des events actuels
      df_selection <- NULL
      for (i in length(filtres)){
        df_selection <- rbind (filtres[[i]]$df_selectionid)
      }
      df_selection <- subset (df_selection, select = c("patient","num"))
      
      ## on choisit l'évènement le plus récent par patient : 
      # le plus petit num 
      if (boolnext){
        tab <- tapply(df_selection$num, df_selection$patient, min)
      } else {
        tab <- tapply(df_selection$num, df_selection$patient, min) ## je laisse min ici
        ## on sélectionne ainsi toujours le meme quelque soit boolnext ou previous
      }
      df_selection <- data.frame(patient=names(tab), num=as.numeric(tab))
      ### les évènements sélectionnés via le filtre :
      #colnames(df_events)
      
      ## df des evenements selectionnés
      df_events_selected <- sqldf("Select a.patient, a.num, a.datestartevent, a.dateendevent, a.type from df_events a
              JOIN df_selection b ON a.patient=b.patient AND a.num = b.num")
      
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

      ### dans les étapes suivantes on crée une df allant du num_event à min ou max event
      num_main_max <- merge (df_events_selected, num_max_event, by="patient")
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
      
      ## on calcule aussi 2 indicateurs : délai entre début main et fin mai 
      colnames(df_events_selected) <- c("patient","mainnum","mainstart","mainend", "maintype") ## garde mainnum pour filtrer rapidement
      ## au lieu de devoir recalculer tous les next elements
      df_next_temp <- merge (df_events_selected,df_next_temp, by="patient")
      df_next_temp$TimeToStart <- difftime(df_next_temp$datestartevent,df_next_temp$mainstart,units="day")
      df_next_temp$TimeToEnd <- difftime(df_next_temp$datestartevent,df_next_temp$mainend,units="day")
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

      #colnames(df_next_temp)
      #colnames()
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
