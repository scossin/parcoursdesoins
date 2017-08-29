### télécharger le fichier sur le site de l'ASIP
RPPS <- read.table("ExtractionMonoTable_CAT18_ToutePopulation_201708270748.csv",sep=";",header = T,quote="",
                   comment.char = "")
# colnames(RPPS)
# bool <- grepl("SALLES",RPPS$X.Nom.d.exercice.)
# bool2 <- grepl("NATHALIE",RPPS$X.Prénom.d.exercice.)
# voir <- subset (RPPS, bool & bool2)
# t(voir)
# voir2 <- apply(voir, MARGIN = 2, function(x){
#   as.character(gsub("^\"|\"$","",x))
# })
# 
# voir2 <- as.data.frame(voir2)
# library(xtable)
# print.xtable(voir2, type="latex")

## je veux la neurologie et la médecine générale : 
RPPS$X.Libellé.savoir.faire. <- gsub("^\"|\"$","",RPPS$X.Libellé.savoir.faire.)
sort(table(RPPS$X.Libellé.savoir.faire.))

consultation <- subset (RPPS, X.Libellé.savoir.faire. %in% c("Neurologie","Spécialiste en Médecine Générale"))
consultation$dep <- substr (consultation$X.Code.commune..coord..structure..,1,2)
table(neuro$dep)
consultation33 <- subset (consultation, dep == "33")

###  sélection des attributs intéressants
consultation33selection <- subset (consultation33, select=c("X.Identification.nationale.PP.",
                                              "X.Nom.d.exercice.","X.Prénom.d.exercice.","X.Numéro.FINESS.site.",
                                              "X.Raison.sociale.site.","X.Code.commune..coord..structure..",
                                              "X.Libellé.commune..coord..structure..",
                                              "X.Code.postal..coord..structure..",
                                              "X.Libellé.savoir.faire."))

consultation33selection[] <- apply(consultation33selection,2, function(x) gsub("^\"|\"$","",x))

## est-ce que le médecin exerce en établissement ou en ville ?
bool <- consultation33selection$X.Numéro.FINESS.site. == ""
consultation33selection$Etablissement <- ifelse (bool, "non","oui")
colnames(consultation33selection) <- c("RPPS","Nom","Prenom","FINESS","RaisonSociale","Commune","LibCommune",
                                       "CodePostal","Spécialité","Etablissement")
save(consultation33selection, file="consultation33selection.rdata")

write.table(consultation33selection, "RPPS.csv",sep=",",col.names =T, row.names=F, quote=F)
