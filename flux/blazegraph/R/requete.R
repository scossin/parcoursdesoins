rm(list=ls())
library(SPARQL)
# endpoint <- "http://127.0.0.1:8889/bigdata/sparql"

endpoint_timelines <- "http://127.0.0.1:8889/bigdata/namespace/timelines/sparql"
source("SPARQLqueries.R")

ns = c("CNTROavc","<http://www.eigsante2017.fr/CNTROavc#>",
"rdf","<http://www.w3.org/1999/02/22-rdf-syntax-ns#>",
"eig","<http://www.eigsante2017.fr/>")

### base de données flux inter-établissement : 
# transfertMCOSSR  <- SPARQL(url = endpoint_timelines,query = SPARQLqueries$transfertMCOSSR,
#                             ns=ns)$results

evenements  <- SPARQL(url = endpoint_timelines,query = SPARQLqueries$evenements2,
                           ns=ns)$results



## les dates sont en secondes puis le 1970-1-1
evenements$datestartevent <- as.POSIXct(evenements$datestartevent, origin = "1970-01-01")
evenements$dateendevent <- as.POSIXct(evenements$dateendevent, origin = "1970-01-01")
library(stringr)
## retirer l'URI du named graph
evenements$patient <- str_extract(evenements$patient,"[a-z0-9]+>$")
evenements$patient <- gsub(">$","",evenements$patient)

## voir le fichier codeGeo.R pour sa création
load("domiciles.rdata")
evenements <- merge (evenements, domiciles, by="patient")

save(evenements, file="../../aggregation/evenements.rdata")

## fonction qui détermine la séquence spatiale à partir d'une liste d'events : 
# à réfléchir ce qu'on veut afficher spatialement
# choix arbitaire : algo : si plus de 2 jours entre 2 évènements alors le patient est rentré à domicile
i <- evenements$patient[100]
patients <- unique(evenements$patient)
sequencespatial <- NULL
bool <- is.na(evenements$dateendevent)
evenementsfinis <- subset (evenements, !bool)
for (i in patients){
  temp <- subset (evenementsfinis, patient == i)
  temp <- temp[order(temp$datestartevent),]
  dom <- unique(as.character(temp$domicile))
  diff <- as.numeric(temp$datestartevent[2:(nrow(temp))] - temp$dateendevent[1:(nrow(temp)-1)])
  bool <- diff < 3
  fromlieu <- ifelse (bool, temp$lieu[-nrow(temp)], dom)
  fromlieu <- append(dom, fromlieu)
  tolieu <- ifelse (bool, temp$lieu[-1],dom)
  tolieu <- append(tolieu, dom)
  ajout <- data.frame(fromlieu = fromlieu, tolieu = tolieu)
  sequencespatial <- rbind(sequencespatial, ajout)
}

sequencespatial2 <- cbind(evenementsfinis, sequencespatial) ## dataframe qui sera utilisé pour afficher sur une carte

# colnames(transfertMCOSSR)[c(2:3)] <- c("FROM","TO")
# ## retirer les préfixes
# transfertMCOSSR[] <- apply(transfertMCOSSR, 2, function(x){
#   x <- gsub("^[A-Za-z]+:","",x)
# })
# save(file="transfertMCOSSR.rdata",transfertMCOSSR)

######### hiérarchie ancienne méthode : récupérer via une requête SPARQL
#### 2 colonnes : s = fils ; o = pere (?s rdf:type ?o) 
# endpoint_hierarchie <- "http://127.0.0.1:8889/bigdata/namespace/hierarchieMCOSSR/sparql"
# FROMTOtypes  <- SPARQL(url = endpoint_hierarchie,query = SPARQLqueries$individualtype,
#                            ns=ns)$results ### les individus
# hierarchy <- SPARQL(url = endpoint_hierarchie,query = SPARQLqueries$hierarchie,
#                     ns=ns)$results ### les classes
# hierarchy <- rbind(hierarchy, FROMTOtypes)
# ## retirer les prefixes
# hierarchy[] <- apply(hierarchy, 2, function(x){
#   x <- gsub("^[A-Za-z]+:","",x)
# })

### nouvelle méthode
# on exporte sous protégé la hiérarchie :
# click droit - Copy subhierarchy as tab indented text
# colle ça dans un fichier txt

### comme j'avais déjà fait une méthode pour passer d'une dataframe à 2 colonnes (?s ?o ; voir plus haut)
# en nested list contenant la hiérarchie ; je transforme ce fichier txt en dataframe à 2 colonnes : ?s ?o

# Etape 1 : transformer le fichier txt en dataframe à 2 colonnes
hierarchy <- readLines("../tab_hierarchy.txt")
library(stringr)
## on garde en mémoire la dernière entrée dans la hierarchie :
laste_entry = data.frame(niveau=numeric(), entry=factor())
df_hierarchy <- data.frame(s=factor(), o=factor())
entry <- hierarchy[2]
for (entry in hierarchy){
  niveau <- stringr::str_count(entry,"\t")
  bool <- laste_entry$niveau %in% niveau
  if (any(bool)){ ## si l'entrée existe, on la supprime
    laste_entry <- laste_entry[!bool,]
  } 
  ## on ajoute l'info dans last_entry
  ajout <- data.frame(niveau = niveau, entry=entry)
  laste_entry <- rbind(laste_entry, ajout)
  
  ## on ajoute l'info dans la df_hierarchy :
  if (niveau > 0){ ## niveau 0 : n'a pas de père
    pere <- laste_entry$entry[laste_entry$niveau == (niveau-1)] ## le pere : l'entrée qui a le niveau précédent
    fils <- entry
    ajout <- data.frame(s=fils, o=pere)
    df_hierarchy <- rbind(df_hierarchy, ajout)
  }
}

## on retire les \t
df_hierarchy[] <- apply(df_hierarchy, 2, function(x){
  x <- gsub("^[\t]+","",x)
})


### Etape 2 : transformer cette dataframe à 2 colonnes en nested list
bool <- df_hierarchy$o %in% df_hierarchy$s ## classes qui ne sont pas sous-classe (top classe)
top <- unique(as.character(df_hierarchy$o[!bool])) ## top class : n a pas de fils

## fonction récursive qui recherche tous les fils d'un père
recursive <- function(x, resultat){
  bool <- x %in% resultat$o
  if (!bool) {
    return(x)
  } else {
    fils <- subset (resultat, o == x)$s
    liste <- lapply(fils, recursive,resultat=resultat)
    names(liste) <- fils
    return(liste) 
  }
}

listes <- vector("list",length(top))
names(listes) <- top
i <- 1
for (i in 1:length(top)){
  listes[[i]] <- recursive (top[i], df_hierarchy)
}
hierarchy <- listes
save(file="../../aggregation/hierarchy.rdata",hierarchy)


## commande CURL : 
# commande <- "curl -X POST http://127.0.0.1:8889/bigdata/namespace/flux2/sparql --data-urlencode 'update=DROP ALL'"