rm(list=ls())
load("hierarchical.rdata")

getShinyTreeList2(hierarchicalData)



## commande CURL : 
# commande <- "curl -X POST http://127.0.0.1:8889/bigdata/namespace/flux2/sparql --data-urlencode 'update=DROP ALL'"