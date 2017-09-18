load("domiciles.rdata")

domiciles$patient <- gsub("patient","p",domiciles$patient)
domiciles$dep <- substr(domiciles$domicile,1,2)
domiciles$sex <- c("H","F")
domiciles$age <- NA
domiciles$age[1:999] <- c("<18","18-75","+75")

length(unique(domiciles$domicile))

write.table(domiciles, "context.csv",sep=",", col.names = T,
            row.names = F, quote=F)
