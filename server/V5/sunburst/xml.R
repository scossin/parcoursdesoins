rm(list=ls())
library(XML)


### tests : 
predicateNode3 <- makePredicateNode("numeric","hasMedecin",values = NULL, minValue = 10, maxValue = 20)
predicateNode2 <- makePredicateNode("Date","hasEnd",minValue = 10, maxValue = 20)
predicateNode <- makePredicateNode("factor","inEtab",values = c(1:10))
eventNode0 <- makeEventNode(0, "SejourMCO", list(predicateNode, predicateNode2))
eventNode1 <- makeEventNode(1, "SejourSSR", list(predicateNode3))

linkNode <- makeLinkNode(0,1,"hasEnd", "hasBeginning", "diff", 0,"")

eventLinks <- makeEventsLinksNode(eventNodes = list(eventNode0, eventNode1))

docType <- XML::Doctype(name = "eventslinks", system = "eventslinks.dtd")
saveXML(eventLinks, file="test.xml",doctype = docType)


###
rm(list=ls())
require(R6)
require(httr)
require(XML)
source("XMLqueryOO.R")
source("ConnectionOO.R")
query <- XMLquery$new()
query$addEventNode(0, "SejourMCO")
con <- Connection$new()
con$getQueryURL()


contexts <- paste0("p",1:100000)
decoup <- split(contexts, ceiling(seq_along(contexts)/2000))
### tester 

library(XML)
df <- NULL
un <- decoup[[1]]
system.time(
  for (un in decoup){
    print(un)
    query$addContextNode(contextVector = un)
    query$saveQuery()
    results <- query$sendQuery(con$getQueryURL())
    ajout <- read.table(file=textConnection(rawToChar(results$content)), sep="\t",header = T)
    df <- rbind(df,ajout)
  }
)
results$status_code

contexts <- paste0("p",1:10)
query$addContextNode(contextVector = contexts)
query$saveQuery()

system.time(
  results <- query$sendQuery(con$getQueryURL())
)

results$status_code

voir <- read.table(file=textConnection(rawToChar(results$content)), sep="\t",header = T)

query$addEventNode(1, "SejourMCO")
query$sendQuery(con$getQueryURL())

query$addPredicateNode(1,"factor","inEtab",values = c(1:10))
query$addPredicateNode(0,"factor","inEtab",values = c(1:10))

table(voir$context)

rawToChar()
writeLines(con = "supprimer.html",text = rawToChar(results$content))

rawToChar(results$content[1:70])
query$addPredicateNode(0, "Date","hasEnd",minValue = 10, maxValue = 20)

query$fileName



query$listPredicatesNodes
query$listEventNodes

