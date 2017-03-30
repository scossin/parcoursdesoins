# library(networkD3)
# library(shiny)
# library(googleVis)

### listeevents : évènements disponibles (après sélection des patients, établissements ...)
# mainevent : évènement sur lequel on se centre
# selectedevents : évènements à afficher (en plus du mainevents)
# Navant : nbr d'évènements avant le mainevent
# Napres : nbr d'évènements après le mainevent


get_aggregation <- function(dfcategorie, event){
if (event %in% dfcategorie$details){
  dftemp <- data.frame (group=event, event = event)
} else if (event %in% dfcategorie$sous){
  dftemp <- subset (dfcategorie, sous %in% event,select=c(sous, details))
  colnames(dftemp) <- c("group","event")
} else if (event %in% dfcategorie$categorie){
  dftemp <- subset (dfcategorie, categorie %in% event,select=c(categorie, details))
  colnames(dftemp) <- c("group","event")
} else {
  stop("event non trouvé dans dfcategorie")
}
return(dftemp)}

create_sankey <- function(listeevents, maineventdf, selectedeventsdf, 
                          Navant, Napres){
  if (is.null(maineventdf) | is.null(selectedeventsdf)){
    return(NULL)
  }
  
  if (Navant == 0 & Napres == 0){
    return(NULL)
  }
  
  listeevents$naturesankey <- listeevents$nature
  
  ## trie par patient et par date d'évènements : 
  listeeventsmain <- subset (listeevents, naturesankey %in% maineventdf$event)
  listeeventsselected <- subset (listeevents, naturesankey %in% selectedeventsdf$event
                                 & patientid %in% listeeventsmain$patientid)
  listeeventssubset <- rbind (listeeventsmain,listeeventsselected)
  listeeventssubset <- listeeventssubset[with(listeeventssubset,order(patientid,start)),]
  numeropat <- as.numeric(table(listeeventssubset$patientid))
  startnumerique <- as.numeric(listeeventssubset$start)
  listeeventssubset$num <- ave(startnumerique, listeeventssubset$patientid, 
                               FUN = seq_along)
  
  ## variables dont on a besoin de listeevents : 
  besoin <- subset (listeeventssubset, select=c(patientid, naturesankey,num))
  
  ## evenements mainevent
  centre <- subset (listeeventssubset, naturesankey %in% maineventdf$event, select = c("patientid","num"))

  ## évènements avant et après :
  # avant : 
  if (Navant <=0){
    dfavant <- NULL
  } else {
    avant <- centre
    dfavant <- NULL
    for (i in 1:Navant){
      temp <- avant
      temp$num <- temp$num - i 
      dfavant <- rbind (dfavant, temp)
    }
  }

  if (Napres <=0){
    dfavant <- NULL
  } else {
    apres <- centre
    dfapres <- NULL
    for (i in 1:Napres){
      temp <- apres
      temp$num <- temp$num + i 
      dfapres <- rbind (dfapres, temp)
    }
  }

atransformer <- rbind (centre, dfavant, dfapres)
atransformer <- merge (besoin,atransformer,by=c("patientid","num"))
atransformer <- atransformer[with(atransformer,order(patientid,num)),]

## transforme la data.frame en 2 colonnes : from-to
atransformer$naturesankey <- as.factor(atransformer$naturesankey)
# atransformer$naturesankey <- factor(atransformer$naturesankey,
#                                     levels=c(levels(atransformer$naturesankey ),
#                                              "tous"))

## remplacer les levels par les groupes : 
newlevels <- rbind (maineventdf,selectedeventsdf)
i <- 1
for (i in 1:nrow(newlevels)){
  numlevel <- which(levels(atransformer$naturesankey) == newlevels$event[i])
  levels(atransformer$naturesankey)[numlevel] <- as.character(newlevels$group[i])
}

nodes <- data.frame(name=levels(atransformer$naturesankey))
# touslevel <- which(levels(atransformer$naturesankey) == "tous") - 1
# atransformer$naturesankey <- as.numeric(atransformer$naturesankey) - 1 ## pour network3D
links <- NULL
pat <- atransformer$patientid[1]
i <- 2
for (i in 2:(nrow(atransformer))){
  if (pat == atransformer$patientid[i]){ ## si c'est le même patient à la ligne suivante => new from to
    ajoutlink <- data.frame(source=atransformer$naturesankey[i-1],
                            target=atransformer$naturesankey[i])
    links <- rbind (links, ajoutlink)
  } else{
    pat <-  atransformer$patientid[i]
    # ajoutlink <- data.frame(source=touslevel,
    #                         target=atransformer$naturesankey[i])
    # links <- rbind (links, ajoutlink)
    next ## si on change de patient, next ligne
  }
}

links <- group_by(links, source,target)
links <- summarise(links, N=n())
links <- data.frame(links)

googleVis::gvisSankey(links, from="source",to="target",weight = "N",
             options=list(sankey = "{node: {interactivity: true, width: 50}}"))

## networkd3 : 
# je n'utilise pas car j'ai un pb d'affichage sous Shiny : trop petit
# sankeyNetwork(Links = links, Nodes = nodes, Source = "source",
#               Target = "target", Value = "N", NodeID = "name",
#               units = "TWh", fontSize = 12, nodeWidth = 30)
}


# mainevent <- c("MCO")
# selectedevents <- c("appel","imagerie","SSRenfant","SSRadulte")
# Navant <- 0
# Napres <- 1
# table(listeevents$nature)

