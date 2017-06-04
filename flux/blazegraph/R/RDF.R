setRefClass(
  # Nom de la classe
  "RDF",
  # Attributs
  fields =  c(
    world = "ANY",
    storage = "ANY",
    model = "ANY",
    parser = "ANY",
    namespaces="data.frame"
  ),
  
  # Fonctions :
  methods=list(
    ### Constructeur
    initialize = function(namespaces){
      library(redland)
      private_initialization()
      
      if (!all (colnames(namespaces) %in% c("namespace","prefixe"))){
        stop("df_namespaces doit contenir exactement 2 colonnes : namespace et prefixe")
      }
      
      namespaces <<- namespaces
    },
    
    private_initialization = function(){
      world <<- new("World")
      storage <<- new("Storage", world, "hashes", name="", options="hash-type='memory'")
      model <<- new("Model", world=world, storage, options="")
      parser <<- new("Parser", world)
    },
    
    #### remise à zero 
    resetMemory = function(){
      redland::freeParser(parser)
      redland::freeModel(model)
      redland::freeStorage(storage)
      redland::freeWorld(world)
      private_initialization()
    },
    
    check_prefixe = function(prefixe, namespace){
      bool <- prefixe %in% namespaces$prefixe
      if (!bool){
        stop("\"",prefixe,"\"", " non trouvé dans la dataframe namespace : ", 
             paste(unique(namespaces$prefixe),collapse=","))
      }
      if (sum(bool) > 1) {
        stop("\"",prefixe,"\"", " plusieurs préfixes trouvés dans la dataframe namespace ")
      }
      return(TRUE)
    },
    
    ## ajout un prefixe à un vecteur
    ajout_prefixe = function(vecteur, prefixe){
      vecteur <- as.character(vecteur)
      
      ## vérification de l'existence du prefixe
      check_prefixe(prefixe, namespace)

      remplacement <- namespaces$namespace[namespaces$prefixe == prefixe]
      newvecteur <- sapply(vecteur, function(x,remplacement){
        paste(remplacement,x,sep="")
      },remplacement=remplacement)
      
      ## les valeurs manquantes NA sont remplacées par "NA" lors de la précédente opération
      # je veux garder valeurs manquantes : NA
      bool <- is.na(vecteur)
      newvecteur[bool] <- NA
      return(as.character(newvecteur))
    },
    
    create_tripletspo = function(sujet, predicat, objet, prefixe_sujet=NULL,
                                 prefixe_predicat=NULL, prefixe_objet=NULL){
      
      if (all(is.na(sujet)) ||  all(is.na(predicat)) || all(is.na(objet))){
        cat("0 nouveaux statements")
        return(NULL)
      }
      
      
      ## ajout des prefixes si necessaires
      if (!is.null(prefixe_sujet)){
        sujet <- ajout_prefixe(sujet, prefixe_sujet)
      }
      if (!is.null(prefixe_predicat)){
        predicat <- ajout_prefixe(predicat, prefixe_predicat)
      }
      if (!is.null(prefixe_objet)){
        objet <- ajout_prefixe(objet, prefixe_objet)
      }
      
      ## dans une dataframe :
      # si la longueur de sujet / predicat / objet pas la meme, R renverra une erreur
      dfnodes <- data.frame(sujet=sujet, predicat = predicat, objet=objet, stringsAsFactors = F)
      # pour chaque ligne, creation des noeuds et enregistrement du statement :
      iter <- 0
      for (i in 1:nrow(dfnodes)){
        
        ## ne pas traiter si objet est NA
        if (is.na(dfnodes$sujet[i]) ||  is.na(dfnodes$predicat[i]) || is.na(dfnodes$objet[i])){
          next
        }
        
        iter <- iter + 1
        
        node_sujet <- new("Node",world=world, uri=dfnodes$sujet[i])
        node_predicat <- new("Node",world=world, uri=dfnodes$predicat[i])
        node_objet <- new("Node",world=world, uri=dfnodes$objet[i])
        stmt <- new("Statement", world=world, 
                    subject=node_sujet,
                    predicate=node_predicat,
                    object=node_objet)
        addStatement(model, stmt)
      }
      cat (iter, " nouveaux statements")
      return(NULL)
    },
    
    create_tripletspl = function(sujet, predicat, literal, typeliteral,
                                 prefixe_sujet=NULL,
                                 prefixe_predicat=NULL){
      
      if (all(is.na(sujet)) ||  all(is.na(predicat)) || all(is.na(literal))){
        cat("0 nouveaux statements")
        return(NULL)
      }
      
      
      if (!is.null(prefixe_sujet)){
        sujet <- ajout_prefixe(sujet, prefixe_sujet)
      }
      if (!is.null(prefixe_predicat)){
        predicat <- ajout_prefixe(predicat, prefixe_predicat)
      }
      
      ### à modifier si datatype différent à l'avenir !
      typeliteral <- paste("http://www.w3.org/2001/XMLSchema#",typeliteral, sep="")

      
      dfnodes <- data.frame(sujet=sujet, predicat = predicat, literal=literal)
      
      iter <- 0
      for (i in 1:nrow(dfnodes)){
        
        ## ne pas traiter si objet est NA
        if (is.na(dfnodes$sujet[i]) ||  is.na(dfnodes$predicat[i]) || is.na(dfnodes$literal[i])){
          next
        }
        
        iter <- iter + 1
        
        node_sujet <- new("Node",world=world, uri=dfnodes$sujet[i])
        node_predicat <- new("Node",world=world, uri=dfnodes$predicat[i])
        node_objet <- new("Node",world=world, literal = dfnodes$literal[i], datatype_uri=typeliteral)
        stmt <- new("Statement", world=world, 
                  subject=node_sujet,
                  predicate=node_predicat,
                  object=node_objet)
        addStatement(model, stmt)
      }
    cat (iter, " nouveaux statements")
    return(NULL)
    },
    
    serializeandwrite = function(fichier){
      serializer <- new("Serializer", world)
      ## ajout des namespace au fichier
      for (i in 1:nrow(namespaces)){
        setNameSpace(serializer, world, namespace=namespaces$namespace[i], prefix=namespaces$prefixe[i])  
      }
      serializeToFile(serializer, world, model, fichier)
      cat(fichier, " créé")
      
      ## libère la mémoire :
      redland::freeSerializer(serializer)
      return(NULL)
    }
  )
)