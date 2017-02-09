rm(list=ls())
##############
#### correspondance entre code postal et codes communes : 
# https://www.data.gouv.fr/fr/datasets/base-officielle-des-codes-postaux/
correspondance <- read.table("laposte_hexasmal.csv",sep=";",header=T, colClasses = "factor")

# colonnes qui nous interessent : 
colnames(correspondance)
Nomcolonnes <- c("Code_commune_INSEE","Code_postal")
bool <- all(Nomcolonnes %in% colnames(correspondance))
if (!bool){
  stop("colonnes sélectionnées non trouvées")
}
colonnes <- which(colnames(correspondance) %in% Nomcolonnes)
correspondance <- correspondance[,colonnes]
correspondance <- unique(correspondance)
correspondance <- correspondance[order(correspondance$Code_postal),]

### code geoPMSI : 
# http://www.atih.sante.fr/mise-jour-2015-de-la-liste-de-correspondance-codes-postaux-codes-geographiques
geoPMSI <- read.table("codepost2015.csv",sep="\t",header=T)
colnames(geoPMSI) <- c("Code_postal","Nom_poste","pop_poste","pop_geo","Code_geo","temp")
all(is.na(geoPMSI$temp)) ### dernière colonne incompréhensible
geoPMSI$temp <- NULL
colnames(geoPMSI)
geoPMSI <- subset (geoPMSI, select=c("Code_postal","Code_geo"))
geoPMSI <- unique(geoPMSI)
geoPMSI <- geoPMSI[order(geoPMSI$Code_postal),]

### jointure : 
bool <- geoPMSI$Code_postal %in% correspondance$Code_postal
unmatch <- subset (geoPMSI, !bool)
sum(!bool) #### 238 codes postaux non présents dans la table de correspondance : 
### la Corse est absente et les codes étrangers (99)

####### Les communes avec plusieurs codes postaux peuvent poser problème
### car une commune peut potentielle être dans plusieurs codes géo PMSI
## ce qui pose des problèmes de délimitation d'un code géo PMSI sur une carte
length(unique(correspondance$Code_postal))
length(unique(correspondance$Code_commune_INSEE))
# le plus souvent : un code Postal pour plusieurs communes
# mais parfois ! plusieurs communes pour un même code postal
tab <- table(correspondance$Code_commune_INSEE)
bool <- tab > 1
tab <- subset (tab, bool)
tab
length(tab) ## 266 communes avec plusieurs codes postaux
voir <- subset (correspondance, Code_commune_INSEE %in% names(tab))
voir <- voir[order(voir$Code_commune_INSEE),]


#### jointure : 
geoPMSIcommune <- merge (geoPMSI, correspondance, by="Code_postal")
geoPMSIcommune$Code_postal <- NULL
geoPMSIcommune <- unique(geoPMSIcommune)
length(unique(geoPMSIcommune$Code_commune_INSEE))
tab <- table(geoPMSIcommune$Code_commune_INSEE)
bool <- tab > 1
tab <- subset (tab, bool)
voir <- subset (geoPMSIcommune, Code_commune_INSEE %in% names(tab))
voir <- voir[order(voir$Code_commune_INSEE),]
#### on peut voir les codesInsee rattachés à plusieurs codes géo. 


length(unique(geoPMSIcommune$Code_geo)) ### 5822 codes géo
length(unique(geoPMSIcommune$Code_commune_INSEE))
save(geoPMSIcommune,file="geoPMSIcommune.rdata")
