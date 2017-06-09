setRefClass(
  # Nom de la classe
  "Event",
  # Attributs
  fields =  c(
    ## changer ensuite par table - interroger la base de données
    evenements = "data.frame",
    main_event = "vector",
    hierarchy = "list",
    df_next = "data.frame"
  ),
  
  # Fonctions :
  methods=list(
    ### Constructeur
    initialize = function(evenements, hierarchy){
      evenements <<- evenements
      hierarchy <<- hierarchy
    },
    
    set_main_event = function(main_event){
      main_event <<- main_event
      set_df_apres()
    },
    
    get_tree_mainevent = function(){
      temp <- sqldf("select distinct patient, type from evenements")
      lowestlevel_vector <- temp$type
      get_hierarchylistN(hierarchy, lowestlevel_vector)
    },
    
    set_df_apres = function(){
      num_main_event <- sqldf(paste0("select patient, datestartevent, dateendevent, min(num) as num FROM evenements where type = '",main_event,"'
                                     GROUP BY patient"))
      
      # récupérer tous les evenements après ce num event par patient 
      # ? possible en SQL ?
      # ma solution : créer une table d'events à sélectionner, générer par un langage de programmation
      # la charger dans la base et faire un merge
      # ou commencer par un petit nombre de patients :
      # calculer le nombre d'events apres pour ce nombre 
      # prendre 0.95 de la distrib pour déterminer N events apres
      # evite de récupérer tous les events
      
      ## Etape 2 : dénombrer les events entre num_main_event +1 à num_max_event
      # on commence par récupérer le num max par patient : 
      num_max_event <- sqldf(paste0("select patient, max(num) as max FROM evenements 
                                    GROUP BY patient "))
      num_main_max <- merge (num_main_event, num_max_event, by="patient")
      ## si num_main_event = num_max_event, il n'y en a pas après donc on retire :
      bool <- num_main_max$num == num_main_max$max
      num_main_max <- subset(num_main_max, !bool)
      num_main_max$patientfromto <- paste(num_main_max$patient,num_main_max$num,num_main_max$max,sep=";")
      df_event_apres <- NULL
      for (x in num_main_max$patientfromto){
        temp <- unlist(strsplit(x,";"))
        vecteur <- seq(as.numeric(temp[2])+1, as.numeric(temp[3]),by=1) ## +1 : next event
        df_event_apres <- rbind(df_event_apres,data.frame(patient=temp[1],num=vecteur))
      }
      ## Ici on load dans la base de données df_event_apres
      # puis on a la requête suivante :
      df_apres <- sqldf("Select a.patient, a.num, a.datestartevent, a.type from evenements a
              JOIN df_event_apres b ON a.patient=b.patient AND a.num = b.num")
      # df_apres : tous les events apres le main_event qu'on proposera à l'utilisateur
      
      ## on calcule aussi 2 indicateurs : délai entre début main et fin mai 
      num_main_event$num <- NULL
      colnames(num_main_event) <- c("patient","mainstart","mainend")
      df_apres <- merge (num_main_event,df_apres, by="patient")
      df_apres$debutdebut <- difftime(df_apres$datestartevent,df_apres$mainstart,units="day")
      df_apres$debutfin <- difftime(df_apres$datestartevent,df_apres$mainend,units="day")
      df_next <<- df_apres
    }
  )
)
