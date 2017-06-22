setRefClass(
  # Nom de la classe
  "spatial",
  # Attributs
  fields =  c(
    ## changer ensuite par table - interroger la base de données
    subset_tab_spatial = "data.frame", ## data.frame contenant la liste des séquences spatiales pour une liste d'events donnés
    df_transfert_entree = "data.frame", ## transfert à l'entrée
    df_transfert_sortie = "data.frame", ## transfert à la sortie
    
    ## pré-calculé, servira pour le pie chart
    N_transfert_sortie = "numeric",
    N_transfert_entree = "numeric",
    N_events_selected = "numeric"
  ),
  
  # Fonctions :
  methods=list(
    ### Constructeur
    initialize = function(tab_spatial, df_selection){
      cat("\t Initialisation d'un objet spatial")

      ## tab_spatial : doit être accessible dans une base de données
      require(sqldf)
      bool <- c("patient","num") %in% colnames(df_selection)
      if (!all(bool)){
        stop("df_selection ne contient pas les colonnes patient et num pour la séquence spatiale")
      }
      df_selection <- subset (df_selection, select=c("patient","num"))
      df_selection <- unique(df_selection)
      N_events_selected <<- nrow(df_selection)
      cat("\t\t", N_events_selected, "évènements sélectionnés \n")
      cat ("\t\t", nrow(tab_spatial), "lignes dans tab_spatial \n")
      
      subset_tab_spatial <<- sqldf("select a.* from tab_spatial a 
                                  JOIN df_selection b on a.patient=b.patient AND a.num = b.num")
      
      cat ("\t\t", nrow(subset_tab_spatial), "lignes dans subset_tab_spatial \n")
      
      if (nrow(subset_tab_spatial) == 0){
        df_transfert_entree <<- data.frame()
        df_transfert_sortie <<- data.frame()
      } else {
        df_transfert_entree <<- set_transfert_etab(bool_entree = T)
        df_transfert_sortie <<- set_transfert_etab(bool_entree = F)
      }
      
      cat ("\t\t", nrow(df_transfert_entree), "lignes dans df_transfert_entree \n")
      cat ("\t\t", nrow(df_transfert_sortie), "lignes dans df_transfert_sortie \n")
    },
    
  ### pour calculer les rapports
  count_dom = function(df){
    bool <- colnames(df) %in% c("patient","domicile")
    if (!all(bool)){
      stop("df doit contenir exactement patient et domicile")
    }
    df <- unique(df)
    tab <- table(as.character(df$domicile))
    tab <- data.frame(domicile = names(tab), frequence=as.numeric(tab))
    return(tab)
  },
  
  ### l'objectif de cette fonction est de renvoyer 
  # pour chaque code geo, le rapport entre le nombre de patients sélectionnés et le nombre de patients total dans notre cohorte
  # (ajouter à l'avenir la population pour calculer l'incidence standardisée)
  # les transferts de provenance et de destination
  
  ## fonction indépendante de cette classe
  get_zone_chalandise = function(df_patient, df_selection){
    
    ### 1) Nombre de patients par domicile : 
    
    ## verif que df_patient contienne les bonnes colonnes
    colonnes <- c("patient","domicile")
    bool <-  colonnes %in% colnames(df_patient)
    if (!all(bool)){
      stop("df patient ne contient pas les colonnes patient ou domicile pour calculer les trajectoires")
    }
    df_patient <- subset (df_patient, select= colonnes)
    df_patient <- unique(df_patient)
    df_patient_count <- count_dom(df_patient)
    colnames(df_patient_count) <- c("domicile","denom")
    
    ## de meme pour df_selection
    patients1 <- as.character(df_patient$patient)
    patients2 <- unique(df_selection$patient)
    bool <- patients1 %in% patients2
    df_patient_selected <- subset (df_patient, bool)
    df_patient_selected  <- unique(df_patient_selected)
    df_patient_selected_count <- count_dom(df_patient_selected)
    
    rapport_domicile <- merge (df_patient_count, df_patient_selected_count, by="domicile", all.x=T)
    bool <- is.na(rapport_domicile$frequence) ## all.x = T donc si aucun sélectionné on met 0
    rapport_domicile$frequence[bool] <- 0
    rapport_domicile$pourcentage <- rapport_domicile$frequence / rapport_domicile$denom
    return(rapport_domicile)
  },
  
  ## bool_entree = T : entrer via un autre établissement ; false : sortie de l'établissement
  set_transfert_etab = function (bool_entree){
    ## on se sert de la colonne cat pour savoir si c'est entrée ou sortie 
    if (bool_entree){
      cat <- "provenance"
    } else {
      cat <- "destination"
    }

    ## dom sont des polygones, 
    # a priori tous les autres lieux d'évènements correspodnetn à une géolocalisation
    # A modifier en fonction de l'évolution des données
    bool <- subset_tab_spatial$cat %in% cat & 
      subset_tab_spatial$typefrom != "dom" & subset_tab_spatial$typeto != "dom"
    transfert <- subset (subset_tab_spatial, bool)

    if (nrow(transfert) == 0){
      transfert <- data.frame()
    } else {
    ## on agrège les memes transferts, on enlève ce qui est spécifique au patient
    transfert$patient <- NULL
    transfert$num <- NULL
    require(dplyr)
    grp_cols <- names(transfert)
    dots <- lapply(grp_cols, as.symbol)
    transfert <- transfert %>% group_by_(.dots=dots) %>% summarise(N=n())
    ## poids entre 1 et 10 :
    transfert <- data.frame(transfert)
    transfert$poids <- ceiling(transfert$N *10 / max(transfert$N))
    }
    
    if (bool_entree){
      N_transfert_entree <<- nrow(transfert)
      df_transfert_entree <<- transfert
    } else {
      N_transfert_sortie <<- nrow(transfert)
      df_transfert_sortie <<- transfert
    }
  }
)
)


### deprecated : 
# je retournais avant 4 données : domicile provenance et destination, etablissement prov et destination
# dom pro et dest est redondant et je retire les transferts pour les rapports ce qui n'est pas pertinent
# du coup j'affiche le domicile des patients => zone de chalandise
# un pie chart pour savoir s'ils viennent du dom ou d'un autre établissement
# un autre pour la destination
# get_trajectoires = function(denom){
#   ### list : provenance et destination
#   ## 2 objets : domicile et etab
#   trajectoires <- subset_tab_spatial_selection
#   output <- list()
#   # trajectoires <- tab_spatial
#   # df <- subset (df_patient, select=c("patient","domicile"))
#   # denom <- count_dom(df)
# 
#   ### domicile :
#   provenance <- "destination"
#   for (provenance in names(table(trajectoires$cat))){
#     ### 1) domicile :
#     prov <- subset (trajectoires, cat == provenance)
#     if (provenance == "provenance"){
#       domfrom <- subset (prov, typefrom %in% "dom", select=c("patient","from"))
#     } else {
#       domfrom <- subset (prov, typeto %in% "dom", select=c("patient","from"))
#     }
# 
#     colnames(domfrom) <- c("patient","domicile")
#     domfrom <- count_dom(domfrom)
# 
#     colnames(denom) <- c("domicile","denom")
#     rapportfrom <- merge (domfrom, denom, by="domicile")
#     rapportfrom$pourcentage <- rapportfrom$frequence / rapportfrom$denom
# 
#     ## pour les transferts :
#     transfertfrom <- subset (prov, typefrom %in% "etab" & typeto %in% "etab")
#     if (nrow(transfertfrom) == 0){
#       transfertfrom <- NULL
#     } else {
#       transfertfrom$patient <- NULL
#       transfertfrom$num <- NULL
#       require(dplyr)
#       grp_cols <- names(transfertfrom)
#       dots <- lapply(grp_cols, as.symbol)
#       transfertfrom <- transfertfrom %>% group_by_(.dots=dots) %>% summarise(N=n())
#       ## poids entre 1 et 10 :
#       transfertfrom <- data.frame(transfertfrom)
#       transfertfrom$poids <- ceiling(transfertfrom$N *10 / max(transfertfrom$N))
#     }
#     output[[provenance]] <- list(dom = rapportfrom, transfert=transfertfrom)
#   }
#   return(output)
# },