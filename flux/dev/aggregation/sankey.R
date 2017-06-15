#library(sankeyD3)
library(dplyr)
library(stringr)
### SankeyD3
library(sankeyD3)


## df_sankey contient :
# chaque colonne débute par event suivi d'un numéro (négatif ou positif)
make_sankey = function(df_sankey, V1 = F, V2 = T){
## re-ordonner les colonnes :
# si colonne patient on l'enlève :
df_sankey$patient <- NULL

numeros <- str_extract(colnames(df_sankey), "[-]?[0-9]+")
numeros <- as.numeric(numeros)
df_sankey <- df_sankey[,match(sort(numeros),numeros)]
numeros <- sort(numeros)

## on ajoute le numéro de l'event :
for (i in 1:length(df_sankey)){
  df_sankey[,i] <- as.factor( df_sankey[,i])
  levels(df_sankey[,i]) <- paste0(levels(df_sankey[,i]), numeros[i])
  # df_sankey[,i] <- paste0(df_sankey[,i], numeros[i])
}


### premier type de regroupement
## on compte le nombre de trajectoires uniques 

if (V1){
  grp_cols <- names(df_sankey)
  dots <- lapply(grp_cols, as.symbol)
  df_sankey2 <- df_sankey %>% group_by_(.dots=dots) %>% summarise(N=n())
  df_sankey2 <- data.frame(df_sankey2)
  
  #### l'ordre ici est très important, c'est ce qui détermine ensuite l'alignement des noeuds sur le sankey !
  df_sankey2 <- df_sankey2[order(-df_sankey2$N),]

  
  ### on met le nombre entre parenthèse au premier event pour l'affichage sur le Sankey
  ## bcp plus jolie que de répéter le N à chaque event alors que le N est le meme (NodeValue = F)
  df_sankey2[,1] <- paste0("(",df_sankey2$N,")",df_sankey2[,1])
  ## ajouter l'id du cluster (cluster = trajectoire unique)
  cluster <- 1:nrow(df_sankey2)
  
  i <- 1
  for (i in 1:(length(df_sankey2)-1)){
    df_sankey2[,i] <- paste0(df_sankey2[,i], cluster)
  }
  
  ## création de links et nodes pour les besoins du sankey - 2 colonnes : source et target
  links <- NULL
  i <- 1
  for (i in 1:(length(df_sankey2)-2)){
    ajout <- df_sankey2[,c(i:(i+1), length(df_sankey2))]
    colnames(ajout) <- c("source","target","N")
    links <- rbind (links, ajout)
  }
  # bool <- grepl("^NA",links$target)
  # sum(bool)
  # links <- subset (links, !bool)
  nodes <- c(as.character(links$source),as.character(links$target))
  nodes <- unique(nodes)
  nodes <- data.frame(name=nodes)
  
  ### il faut retirer le name et mettre un id pour que sankeyD3 accepte :
  ## alors que GoogleVis accepte ce format
  # cependant il n'est pas possible de changer le label avec googleVis !
  # test <- googleVis::gvisSankey(links, from="source",to="target",weight = "N",
  #                       options=list(sankey = "{node: {interactivity: true, width: 50}}",
  #                                    width="800px", height="800px"))
  # plot(test)
  
  
  nodes$id <- 0:(nrow(nodes)-1) ## doit commencer à 0 pour JS
  links <- merge (links, nodes, by.x="source",by.y="name")
  links <- merge (links, nodes, by.x="target", by.y="name")
  links$target <- NULL
  links$source <- NULL
  colnames(links) <- c("N","source","target")
  
  nodes$name <- gsub("[-]?[0-9]+$","",nodes$name) ## suprprimer le numéro de l'event et du cluster
  nodes$groupe <- gsub("^[(0-9)]+","",nodes$name) ## pour avoir le groupe : chaque groupe a une couleur différente
  nodes$name <- gsub("NA$","",nodes$name) ## remplacer les NA par ""
  
  # nodes$position <- str_extract(nodes$name,"[0-9]")
  # nodes$position <- as.numeric(nodes$position)
  
  ##### j'essayais de me battre pour mettre les couleurs : 
  # couleurs <- rainbow(3)
  # pie(1:length(couleurs),col=couleurs)
  # couleurs <- tolower(couleurs)
  # couleurs <- c("#7d3945","#e0677b", "#244457")
  # couleurs <-  paste(couleurs, collapse="\",\"")
  # couleurs <- paste0('d3.scaleOrdinal().range(["',couleurs, '"])')
  # car je voulais mettre aucun couleur pour NA
  
  sankey <- sankeyNetwork(Links = links, Nodes = nodes, Source = "source",
                Target = "target", Value = "N", NodeID = "name",
                units = "TWh", fontSize = 12, nodeWidth = 30,nodePadding=1,numberFormat = ".0f",
                dragX = T, dragY = T, NodeGroup = "groupe",showNodeValues = F, highlightChildLinks=T,
                zoom = T)
  
  return(sankey)
}


##### pour ce regroupement, les noeuds d'un meme axe sont mergés ; on voit avant/apres pour un event mais pas plus loin

if (V2){
## si un event est facultatif, un event sera "NA"
# il faut récupérer le remplacer par le next event :
for (i in length(df_sankey):3){ ## on ignore le premier et le dernier event
  bool <- is.na(df_sankey[,i-1]) & !is.na(df_sankey[,i])
  df_sankey[,i-1] <- ifelse(!bool, as.character(df_sankey[,i-1]), as.character(df_sankey[,i]))
}

df_sankey <- df_sankey[order(df_sankey[,1]),]

### links et nodes pour networkd3
links <- NULL
for (i in 1:(length(df_sankey)-1)){
  ajout <- df_sankey[,c(i:(i+1))]
  colnames(ajout) <- c("source","target")
  links <- rbind (links, ajout)
}

## retirer les NA de fin
bool <- is.na(links$target)
links <- subset (links, !bool)

## si c'est égal c'est lié au remplacement des NA ci-dessus
bool <- links$source == links$target & !is.na(links$source)
links <- subset (links, !bool)

bool <- is.na(links$source)
links$source[bool] <- ""## pour faire disparaitre NA
links <- group_by(links, source,target)
links <- summarise(links, N=n())
links <- data.frame(links)


### remplacer tous les NA par "" ??

#### avec Google::gvisSankey :
# test <- googleVis::gvisSankey(links, from="source",to="target",weight = "N",
#                       options=list(sankey = "{node: {interactivity: true, width: 50}}",
#                                    width="800px", height="800px"))
# plot(test)


nodes <- c(as.character(links$source),as.character(links$target))
nodes <- unique(nodes)
nodes <- data.frame(name=nodes)

### il faut retirer le name et mettre un id pour que sankeyD3 accepte :
nodes$id <- 0:(nrow(nodes)-1) ## doit commencer à 0 pour JS
links <- merge (links, nodes, by.x="source",by.y="name")
links <- merge (links, nodes, by.x="target", by.y="name")
links$target <- NULL
links$source <- NULL
colnames(links) <- c("N","source","target")

nodes$groupe <- gsub("[-]?[0-9]+$","",nodes$name) ## suprprimer le numéro de l'event et du cluster

## retirer 

sankey <- sankeyNetwork(Links = links, Nodes = nodes, Source = "source",
              Target = "target", Value = "N", NodeID = "groupe",
              units = "TWh", fontSize = 12, nodeWidth = 30,nodePadding=1,numberFormat = ".0f",
              dragX = T, dragY = T,NodeGroup = "groupe", zoom = T)

return(sankey)
} ## fin V2
} ## fin fonction

#### pour voir les différents paramétrages
# shiny::runGitHub("fbreitwieser/sankeyD3", subdir="inst/examples/shiny")


## test : 
# rm(list=ls())
#load("df_sankey.rdata")
#make_sankey(df_sankey, V1=F)
