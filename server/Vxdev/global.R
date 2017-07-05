library(shiny)
library(shinyTree)
library(visNetwork)
rm(list=ls())


#### Algo pour l'agrégation selon les choix de l'utilisateur : 
## 1) on commence par lister tous les éléments pour chaque niveau d'agrégat choisi
## 2) on compte le nombre d'éléments dans chaque niveau d'agrégat
## 3) Si un élément apparait 2 fois : on sélectionne le niveau d'agrégat le plus petit

get_dfagregation <- function(hierarchyliste, choix){
  rmatch <- function(x, name) {
    pos <- match(name, names(x))
    if (!is.na(pos)) return(x[[pos]])
    for (el in x) {
      if (class(el) == "list") {
        out <- Recall(el, name)
        if (!is.null(out)) return(out)
      }
    }
  }
  
  
  ## 1) 
  elementsNiveaux <- lapply(choix, function(x){
    as.character(unlist(rmatch(hierarchyliste, x)))
  })
  ## 2) 
  Nelements <- unlist(lapply(elementsNiveaux, length))
  
  dfagregation <- NULL
  i <- 1
  for (i in 1:length(elementsNiveaux)){
    ajout <- data.frame(element = unlist(elementsNiveaux[[i]]), Ngroupe = Nelements[i], agregat = choix[i])
    dfagregation <- rbind(dfagregation, ajout)
  }
  
  ## 3)
  ## un élément est dans plusieurs groupes pour l'agrégation : choix du groupe le plus petit
  tab <- tapply(dfagregation$Ngroupe, dfagregation$element, min)
  tab <- data.frame(element = names(tab), Ngroupe=as.numeric(tab))
  dfagregation <- merge (dfagregation, tab, by=c("Ngroupe","element"))
  bool <- length(unique(dfagregation$element)) == nrow(dfagregation)
  if (!bool){
    warning("Un élément est rangé dans plusieurs groupes pour l'agrégation")
  }
  dfagregation$Ngroupe <- NULL
  return(dfagregation)
}


load("listes.rdata")
hierarchyliste <- listes

load("transfertMCOSSR.rdata")


