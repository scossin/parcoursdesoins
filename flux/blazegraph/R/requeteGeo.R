rm(list=ls())
library(SPARQL)

endpoint_timelines <- "http://127.0.0.1:8889/bigdata/namespace/geo/sparql"
source("SPARQLqueries.R")

ns = c("CNTROavc","<http://www.eigsante2017.fr/CNTROavc#>",
       "rdf","<http://www.w3.org/1999/02/22-rdf-syntax-ns#>",
       "eig","<http://www.eigsante2017.fr/>",
       "wgs84","<http://www.w3.org/2003/01/geo/wgs84_pos#>")

coordonneesGeo  <- SPARQL(url = endpoint_timelines,query = SPARQLqueries$coordonnesGeo,
                      ns=ns)$results

save(coordonneesGeo,file="coordonneesGeo.rdata")
