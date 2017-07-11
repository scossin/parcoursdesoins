########## L'objectif de ce script est de chargé les triplets dans un triplestore

####### chargement des timelines dans des sous-graphes distincts :
rm(list=ls())
library(SPARQL)


## endpoint local d'une base de données Blazegraph tournant dans un container Docker
# cette url est spécifique à blazegraph
endpoint_timelines <- "http://127.0.0.1:8889/bigdata/namespace/timelines/sparql"

### la première étape consiste à transférer les triplets dans le docker :
## sudo docker cp triplets/ container:/tmp/triplets/

#### Chargement des timelines :
i <- "patient1"
load("listeevents_consultation.rdata")
patients <- unique(listeevents$patientid)
for (i in patients){
  print (i)
  namedgraph <- paste0("<", i, ">")
  file <- paste0("<file:/tmp/triplets/timelines/",i,".xml>")
  field <- paste0("update=LOAD ", file, " INTO GRAPH ", namedgraph, ";")
 
  ### Il existe une fonction pour updater :  SPARQL::SPARQL(update=...)
  ## mais bizaremment ça ne marche pas pour blazegraph (fonctionne pour Fuseki par exemple)
  ## le serveur renvoie une erreur avec le message "bad request"
  ## la requete CURL envoyée par cette fonction est mauvaise, je ne comprends pas pourquoi
  # du coup, j'utilise une autre fonction pour updater: 
  postForm(endpoint_timelines,
           .opts = list(postfields =field),
           httpheader = c('Content-Type' = 'application/x-www-form-urlencoded'))
}


#### Chargement des géolocalisations :

endpoint_geo <- "http://127.0.0.1:8889/bigdata/namespace/geo/sparql"

## centroides des codes géographiques 
field <- "update=LOAD <file:/tmp/triplets/codesGEO.ttl>"
postForm(endpoint_geo,
         .opts = list(postfields =field),
         httpheader = c('Content-Type' = 'application/x-www-form-urlencoded'))

## codes FINESS :  
field <- "update=LOAD <file:/tmp/triplets/codesFINESS.ttl>"
postForm(endpoint_geo,
         .opts = list(postfields =field),
         httpheader = c('Content-Type' = 'application/x-www-form-urlencoded'))



"curl -X POST -H 'Content-type: application/xml' --data @ns.xml http://localhost:9999/blazegraph/namespace"

# requete : 

query <- "### 
SELECT * where{?p ?o <http://www.eigsante2017.fr/Etab330000555>}
LIMIT 10"

query <- "SELECT ?s
{
  ?p <http://www.w3.org/2003/01/geo/wgs84_pos#long>  ?long .
    SERVICE <http://127.0.0.1:8889/bigdata/namespace/timelines/sparql>
     { ?s ?o ?p }
  }

LIMIT 10"

  SPARQL(url = endpoint_geo,query = query)
SPARQL(url = endpoint_timelines,query = query)

