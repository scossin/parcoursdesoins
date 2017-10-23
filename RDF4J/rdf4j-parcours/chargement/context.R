load("domiciles.rdata")

domiciles$patient <- gsub("patient","p",domiciles$patient)
domiciles$dep <- substr(domiciles$domicile,1,2)
domiciles$sex <- c("Homme","Femme")
domiciles$age <- NA
domiciles$age[1:999] <- c("moins de 18 ans","entre 18 et 75 ans","plus de 75 ans")

length(unique(domiciles$domicile))

write.table(domiciles, "context.csv",sep=",", col.names = T,
            row.names = F, quote=F)
