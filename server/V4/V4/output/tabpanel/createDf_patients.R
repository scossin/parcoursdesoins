###
load("domiciles.rdata")## pour tabpatient
dates <- sample(seq(as.Date('1916/01/01'), as.Date('2016/01/01'), by="year"), 100)
age <- round (as.numeric(as.Date("2016-01-01") - dates ) / 365, 0)
bool <- age < 18
bool2 <- age > 75
categorieAge <- ifelse (bool, "<18",ifelse(bool2,
                              ">75",">18 et <75"))
df <- data.frame(patient = paste0("patient",1:nrow(domiciles)), age = age, sexe=c("H","F"),
                 categorieAge=categorieAge)
df <- merge (df, domiciles, by="patient")
df$depdomicile <- 33
df_patient <- df
save(df_patient, file="df_patient.rdata")
