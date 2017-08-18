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
source("XMLqueryOO.R")

require(R6)
require(httr)

query <- XMLquery$new()

query$addEventNode(0, "SejourMCO")
query$addEventNode(1, "SejourMCO")
query$addPredicateNode(1,"factor","inEtab",values = c(1:10))
query$addPredicateNode(0,"factor","inEtab",values = c(1:10))
query$saveQuery()

results <- query$sendQuery(con$getQueryURL())
rawToChar(results$content)
con <- Connection$new()
con$getQueryURL()
query$addPredicateNode(0, "Date","hasEnd",minValue = 10, maxValue = 20)

query$fileName

query$sendQuery()

query$listPredicatesNodes
query$listEventNodes

