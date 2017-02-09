########## Exploration du fichier FINESS téléchargé sur le site data.gouv.fr
## https://www.data.gouv.fr/fr/datasets/extraction-du-fichier-national-des-etablissements-sanitaires-et-sociaux-finess-par-etablissements/
#rm(list=ls())
finess <- read.table("etalab_cs1100507_stock_20170120-0449.csv",sep=";",fill=T, fileEncoding = "ISO8859-1",quote="")

finess[1,]
### première ligne ??
finess <- finess[-1,]

### le fichier CSV est composé en 2 parties : 
## 1) description des structures
## 2) géolocalisation du numéro FINESS établissements
bool <- finess$V1 == "geolocalisation"
geoloc <- subset (finess, bool)
finess <- subset (finess, !bool)

## geoloc : 
# 3 colonnes intéressantes
geoloc <- geoloc[,c(2:4)]
colnames(geoloc) <- c("nofinesset","X","Y")
geoloc <- unique(geoloc)

####### Ajout du nom des colonnes dans la table finess
## je recopie manuellement la colonne "Balise XML" du fichier décrivant les variables
colonnes <- c("structure","nofinesset","nofinessej","rs","rslongue","complrs",
                      "compldistrib","numvoie","typvoie","voie","compvoie","lieuditbp",
                      "commune","departement","libdepartement","ligneacheminement",
                      "telephone","telecopie","categetab","libcategetab","categagretab",
                      "libcategagretab","siret","codeape","codemft","libmft","codesph",
              "libsph","dateouv","dateautor","datemaj","numuai")

bool <- length(colonnes) == ncol(finess)
if (!bool){
  stop("Nombre de colonnes de la table finess différent du nombre de libellés")
}
colnames(finess) <- colonnes

# ajout du codeInsee à la table finess: 
finess$INSEE_COM <- paste (finess$departement,finess$commune,sep="")


############ Vérification concordance entre les 2 dataframe geoloc et finess:
bool <- geoloc$nofinesset %in% finess$nofinesset
cat (sum(!bool), " coordonnées de la table geoloc sans correspondance dans table finess")

#### établissements non géolocalisés ?
bool <- finess$nofinesset %in% geoloc$nofinesset
sansGeoloc <- subset (finess, !bool)
cat (nrow(sansGeoloc), " établissements non géolocalisés")

### plusieurs geolocalisations pour un même numéro finess ?
tab <- table(geoloc$nofinesset)
tab <- subset (tab, tab > 1)
anomalies <- subset (geoloc, nofinesset %in% names(tab))
if (nrow(anomalies)!= 0){
  cat("Plusieurs géolocalisations pour un même Finess Etab")
} else {
  cat("Une seule géolocalisation pour chaque Finess")
}

# voir <- subset (geoloc, !bool)
length(unique(geoloc$nofinesset))
table(nchar(as.character(finess$nofinesset))) ### tous on bien 9 charactères
table(nchar(finess$INSEE_COM)) ## codes insee = 5 charactères

############# table avec les colonnes qui m'interessent
### colonnes qui m'intéressent : 
colnames(finess)
variables <- c("nofinesset","nofinessej","rs","categetab",
              "libcategetab","categagretab","libcategagretab",
              "siret","INSEE_COM")
bool <- all(variables %in% colnames(finess))
if (!bool){
  stop("variable sélectionnée non connue de la table finess")
}
colonnes <- which(colnames(finess) %in% variables)
finessSelect <- finess[,colonnes]
finessSelect <- unique(finessSelect)
finessSelect <- merge (finessSelect, geoloc, by="nofinesset")
## renommage pour l'export :
# locEtab <- finessSelect
# save(locEtab, file="locEtab.rdata")


