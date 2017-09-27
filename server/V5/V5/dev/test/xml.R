rm(list=ls())
library(XML)

############################# Test Describe Query
rm(list=ls())
require(R6)
require(httr)
require(XML)
source("../../output/sunburst/global.R")
source("../../classes/logger/STATICLoggerOO.R",local = T)
staticLogger <- STATIClogger$new()

staticLogger$info("Loading classes ...")
source("../../classes/queries/ConnectionOO.R")
source("../../classes/queries/XMLqueryOO.R")
source("../../classes/queries/XMLDescribeQueryOO.R")
source("../../classes/queries/XMLSearchQueryOO.R")

con <- Connection$new()

#### SearchQuery : 
tempQuery <- XMLSearchQuery$new()
predicateNodes <- list()
predicateNode <- tempQuery$makePredicateNode(predicateClass = "numeric",
                                             predicateType = "hasPrice",
                                             minValue = 1248,
                                             maxValue = 1300)

context <- paste0("p",1:100)
tempQuery$addContextNode(context)
tempQuery$addEventNode(eventNumber = 1,
                   eventType = "SejourSSR",
                   terminologyName = "Event")
tempQuery$addPredicateNode2(eventNumber = 1, predicateNode = predicateNode)
tempQuery$saveQuery()
results <- con$sendQuery(XMLqueryInstance = tempQuery)

######## DescribeQuery : 
query <- XMLDescribeQuery$new()
query$docType
query$addEventTypeNode(eventType = "SejourMCO",terminologyName = "Event")
query$listEventNodes
query$addPredicateTypeNode(c("inEtab"))
contexts <- paste0("p",c(1,10))
query$addContextNode(contexts)
query$listContextNode
eventInstances <- c("p1_SejourMCO_2009_11_21T02_08_00_000_01_00",
                    "p10_SejourMCO_2009_10_06T04_32_00_000_02_00")
query$addEventInstances(eventInstances)
con$sendQuery(query)
class(predicateNode)

#### Test search query : 
query <- XMLSearchQuery$new()
query$addEventNode(eventNumber = 0, terminologyName = "Event",eventType = "SejourMCO")
query$listEventNodes
query$listContextNode
contexts <- paste0("p",1:10)
query$addContextNode(contexts)
query$listContextNode

query$addEventNode(eventNumber = 1, terminologyName = "Event",eventType = "SejourMCO")
query$addLinkNode(eventNumber1 = 0, eventNumber2 = 1,predicate1 = "hasEnd",
                  predicate2 = "hasBeginning",operator = "diff",minValue = 0,maxValue = 60
                    )
query$listLinkNodes
con$sendQuery(query)
query$addPredicateNode(1,"numeric","hasPrice",minValue = 1200,maxValue = 5000)
query$addPredicateNode(0,"numeric","hasPrice",minValue = 1200,maxValue = 5000)
con$sendQuery(query)


###### SearchQueryTerminology !
source("../../classes/queries/XMLSearchQueryTerminologyOO.R")
query <- XMLSearchQueryTerminology$new()
query$docType
query$addEventNode(eventNumber = 0,terminologyName = "Graph",
                   eventType = "Graph")
query$addPredicateNode(0,"factor","CatAge",values=c("<18", "+75"))
con$sendQuery(query)

########## test GET : 
rm(list=ls())
require(R6)
require(httr)
require(XML)
source("ConnectionOO.R")
con <- Connection$new()
results <- con$getFile("comments.csv")
results <- con$getFile("predicateFrequency.csv")
results <- con$getFile("EventHierarchy4Sunburst.csv")
results <- con$getFile("comments.csv")


###  Test count query
rm(list=ls())
require(R6)
require(httr)
require(XML)
source("ConnectionOO.R")
source("XMLqueryOO.R")
source("XMLCountQueryOO.R")
con <- Connection$new()
query <- XMLCountquery$new()
contexts <- paste0("p",1:10)
query$addContextNode(contexts)
query$listContextNode
con$sendQuery(query)


## closing logger connection when user disconnect
staticLogger$close()


### test performance : 
# contexts <- paste0("p",1:100000)
# decoup <- split(contexts, ceiling(seq_along(contexts)/2000))
# library(XML)
# df <- NULL
# un <- decoup[[1]]
# system.time(
#   for (un in decoup){
#     print(un)
#     query$addContextNode(contextVector = un)
#     ajout <- con$sendQuery(query)
#     df <- rbind(df,ajout)
#   }
# )