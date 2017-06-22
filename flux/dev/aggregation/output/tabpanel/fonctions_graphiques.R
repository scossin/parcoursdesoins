###
numerique_box_hist <- function(x, nom_variable){
  
  #### check
  bool <- is.numeric(x)
  if (!bool){
    print (x)
    stop(" la variable n'est pas numérique")
  }
  
  #### titres du plot
  missing <- sum(is.na(x))
  # missing_percent <- round (100*missing / length(x),1)
  nombres_titre <- paste ("N=",sum(!is.na(x)), " (inconnu=",missing,")",sep="")
  titre <- paste (nom_variable, "\n",nombres_titre)
  
  #### mise en forme :
  nf <- layout(matrix(c(1,2), ncol=2, byrow=T))
  
  # moyenne (boxplot)
  moyenne <- round (mean(x,na.rm=T),1)
  moyenne <- paste ("moyenne = ", moyenne,sep="")
  
  
  ### boxplot
  boxp <- boxplot (x, na.action = NULL, range = 1.5, main=titre, xlab="")
  mtext(side=1, text=moyenne,line=1)
  text(x=1.4, y=fivenum(x), labels=as.character(round(fivenum(x),1)))
  
  ### histogramme
  hist(x, ylab="Fréquence", xlab="", main="")
  nf <- layout(matrix(1))
}

numerique_box_comparaison <- function(initial_x, index_selection){
  #### check initial_x
  bool <- is.numeric(initial_x)
  if (!bool){
    print (initial_x)
    stop(initial_x, " la variable n'est pas numérique")
  }
  selection_x <- initial_x[index_selection]
  bplt <- boxplot(initial_x, selection_x,col = c("grey","blue"), na.action = NULL, xlab="")
  axis(side=1, at=c(1,2), labels=c("initial","sélection"))
  text(x=1.5, y=fivenum(initial_x), labels=as.character(round(fivenum(initial_x),1)), col="grey")
  text(x=2.5, y=fivenum(selection_x), labels=as.character(round(fivenum(selection_x),1)), col="blue")
}

numerique_hist_comparaison <- function(initial_x, index_selection, nom_variable){
  #### check initial_x
  bool <- is.numeric(initial_x)
  if (!bool){
    print (initial_x)
    stop(initial_x, " la variable n'est pas numérique")
  }
  selection_x <- initial_x[index_selection]
  
  
  nf <- layout(matrix(c(1,2), ncol=2, byrow=T)) ### 2 graphes cote à cote
  
  ## graph initial 
  missing <- sum(is.na(initial_x))
  nombres_titre <- paste ("N=",sum(!is.na(initial_x)), " (inconnu=",missing,")",sep="")
  titre <- paste (nom_variable, "\n",nombres_titre)
  histo <- hist(initial_x, xlab="initial", ylab="Fréquence", main=titre, col="grey")
  
  ## graph sélection :
  x_limites <- c(min(initial_x), max(initial_x))
  y_limites <- c(0, max(histo$counts))
  nombres_titre <- paste ("N=",sum(!is.na(selection_x)),sep="")
  titre <- paste ("\n",nombres_titre)
  hist(selection_x, xlim=x_limites, xlab="sélection",ylim = y_limites, ylab="", main = titre,col="blue")
  nf <- layout(matrix(1))
}

barplot_graphique <- function(x, nom_variable){
  #### pour ne pas modifier l'ordre des facteurs si on veut en mettre un
  if (!is.factor(x)){
    x <- as.factor(as.character(x))
  }
  missing <- sum(is.na(x))
  tab <- table(x)
  nombres_titre <- paste ("N=",sum(tab), " (inconnu=",missing,")",sep="")
  
  ### nombre de modalités : 
  commentaire <- "" ## ajout commentaire si n_modalites > 10
  
  n_modalites <- length(tab)
  if (n_modalites > 10){
    tab <- sort(tab,decreasing = T)
    tab <- tab[1:10]
    commentaire <- "(10ères modalités)"
  }
  
  titre <- paste (nom_variable, commentaire, "\n",nombres_titre)
  if (length(tab) > 5){
    tab <- sort(tab)
    par(mar=c(4,10,4,6))
    bplt <- barplot(tab, main = titre, horiz = T, las = 1, xlim=c(0, max(tab) + 0.4*max(tab)), xlab="Effectif")
    tab_percent <- round (100*tab/sum(tab, na.rm=T),1)
    texte <- paste (tab, " (",tab_percent, "%)", sep="")
    text (x= tab + 0.18*max(tab) , y=bplt, labels=as.character(texte))
    par(mar=c(4,4,4,4))
  } else {
    ### plot
    bplt <- barplot(tab, main = titre, ylim=c(0, max(tab) + 0.2*max(tab)), ylab="Effectif")
    ### texte
    tab_percent <- round (100*tab/sum(tab, na.rm=T),1)
    texte <- paste (tab, " (",tab_percent, "%)", sep="")
    text (x= bplt, y=tab + 0.1*max(tab), labels=as.character(texte))
  }
}

dates_graphique <- function(x, nom_variable){
  bool <- class(x) == "Date"
  if (!bool){
    print (x)
    stop(" la variable n'est pas de classe Date")
  }
  ### nombre par date : 
  tab <- table(x)
  tab <- data.frame (date=names(tab), frequence=as.numeric(tab))
  tab <- tab[order(tab$date),]
  tab$date <- as.Date(tab$date)
  
  ### rajouter les jours où c'est 0
  jours <- seq(min(tab$date), max(tab$date), by="day")
  jours <- data.frame (jours=jours)
  
  tab2 <- merge (tab, jours, by.x="date",by.y="jours", all.y=T)
  bool <- is.na(tab2$frequence)
  tab2$frequence[bool] <- 0
  
  
  #### titres du plot
  missing <- sum(is.na(x))
  nombres_titre <- paste ("N=",sum(!is.na(x)), " (inconnu=",missing,")",sep="")
  titre <- paste (nom_variable, "\n",nombres_titre)
  
  plot(tab2$frequence, type="l", ylim=c(0,max(tab2$frequence)+max(tab2$frequence)*1.25),
       ylab="Fréquence", xlab="initial",xaxt="n",lty=1,lwd=2, main = titre, col="grey")
  sequence <- seq(1, nrow(tab2), by=round(nrow(tab2)/5)) ## afficher que 6 dates
  axis (side = 1, at = sequence, labels=as.character(tab2$date[sequence]),las=1)
}

dates_graphique_comparaison <- function(initial_x, index_selection, nom_variable){
  bool <- class(initial_x) == "Date"
  if (!bool){
    print (initial_x)
    stop(" la variable n'est pas de classe Date")
  }
  
  selection_x <- initial_x[index_selection]
  
  nf <- layout(matrix(c(1,2), ncol=2, byrow=T)) ### 2 graphes cote à cote
  
  ##### je copie - colle le code de la fonction dates_graphique
  ### j'ai besoin de récupérer tab qui contient le nombre d'occurence par date
  
  ### nombre par date : 
  tab <- table(initial_x)
  tab <- data.frame (date=names(tab), frequence=as.numeric(tab))
  tab <- tab[order(tab$date),]
  tab$date <- as.Date(tab$date)
  
  ### rajouter les jours où c'est 0
  jours <- seq(min(tab$date), max(tab$date), by="day")
  jours <- data.frame (jours=jours)
  
  tab2 <- merge (tab, jours, by.x="date",by.y="jours", all.y=T)
  bool <- is.na(tab2$frequence)
  tab2$frequence[bool] <- 0
  
  
  #### titres du plot
  missing <- sum(is.na(initial_x))
  nombres_titre <- paste ("N=",sum(!is.na(initial_x)), " (inconnu=",missing,")",sep="")
  titre <- paste (nom_variable, "\n",nombres_titre)
  
  plot(tab2$frequence, type="l", ylim=c(0,max(tab2$frequence)+max(tab2$frequence)*1.25),
       ylab="Fréquence", xlab="initial",xaxt="n",lty=1,lwd=2, main = titre, col="grey")
  sequence <- seq(1, nrow(tab2), by=round(nrow(tab2)/5)) ## afficher que 6 dates
  axis (side = 1, at = sequence, labels=as.character(tab2$date[sequence]),las=1)
  
  
  ### graph selection :
  tab <- table(selection_x)
  tab <- data.frame (date=names(tab), frequence_selection=as.numeric(tab))
  tab <- tab[order(tab$date),]
  tab$date <- as.Date(tab$date)
  tab2 <- merge (tab2, tab, by="date",all.x=T)
  bool <- is.na(tab2$frequence_selection)
  tab2$frequence_selection[bool] <- 0
  nombres_titre <- paste ("N=",sum(!is.na(selection_x)),sep="")
  titre <- paste ("\n",nombres_titre)
  plot(tab2$frequence_selection, type="l", ylim=c(0,max(tab2$frequence)+max(tab2$frequence)*1.25),
       ylab="", xlab="sélection",xaxt="n",lty=1,lwd=2, main = titre, col="blue")
  axis (side = 1, at = sequence, labels=as.character(tab2$date[sequence]),las=1)
  nf <- layout(matrix(1))
}


barplot_graphique_comparaison <- function(initial_x, index_selection, nom_variable){
  #### pour ne pas modifier l'ordre des facteurs si on veut en mettre un
  if (!is.factor(initial_x)){
    initial_x <- as.factor(as.character(initial_x))
  }
  selection_x <- initial_x[index_selection]
  
  nf <- layout(matrix(c(1,2), ncol=2, byrow=T)) ### 2 graphes cote à cote
  
  ### fonction produisant le barplot
  tab <- table(initial_x)
  x_limites <- c(0, max(tab) + 0.4*max(tab))
  
  mon_barplot <- function(initial_x, couleur, x_limites, nom_variable, xylab){
    missing <- sum(is.na(initial_x))
    tab <- table(initial_x)
    nombres_titre <- paste ("N=",sum(tab), " (inconnu=",missing,")",sep="")
    ### nombre de modalités : 
    commentaire <- "" ## ajout commentaire si n_modalites > 10
    
    n_modalites <- length(tab)
    if (n_modalites > 10){
      tab <- sort(tab,decreasing = T)
      tab <- tab[1:10]
      commentaire <- "(10ères modalités)"
    }
    
    titre <- paste (nom_variable, commentaire, "\n",nombres_titre)
    if (length(tab) > 5){
      tab <- sort(tab)
      par(mar=c(4,10,4,6))
      bplt <- barplot(tab, main = titre, horiz = T, las = 1, xlim=x_limites, xlab=xylab)
      tab_percent <- round (100*tab/sum(tab, na.rm=T),1)
      texte <- paste (tab, " (",tab_percent, "%)", sep="")
      text (x= tab + 0.18*max(tab) , y=bplt, labels=as.character(texte))
      par(mar=c(4,4,4,4))
    } else {
      ### plot
      bplt <- barplot(tab, main = titre, ylim=x_limites, ylab=xylab, col=couleur)
      ### texte
      tab_percent <- round (100*tab/sum(tab, na.rm=T),1)
      texte <- paste (tab, " (",tab_percent, "%)", sep="")
      text (x= bplt, y=tab + 0.1*max(tab), labels=as.character(texte))
    }
  }
 
  ## premier graphe
  mon_barplot(initial_x, "grey",x_limites,nom_variable, "initial")
  
  ## deuxième graphe
  mon_barplot(selection_x, "blue",x_limites,nom_variable,"sélection")
}




# ###### Tests :
# load("df_patient.rdata")
# 
# ## numerique_box_hist
# numerique_box_hist(df_patient$age, "age")
# 
# # numerique_box_comparaison et numerique_hist_comparaison
# initial_x <- df_patient$age
# index_selection <- sample(df_patient$age,size = 20)
# numerique_box_comparaison(initial_x, index_selection)
# numerique_hist_comparaison(initial_x, index_selection,"age")
# 
# # factor_graphique
# factor_graphique(df_patient$categorieAge,"catégorie age")
# factor_graphique(df_patient$domicile,"domicile")
# 
# # dates_graphique
# dates <- seq(as.Date("01-01-2015", format="%d-%m-%Y"),as.Date("01-01-2017", format="%d-%m-%Y"), by="day")
# x <- df_patient$date
# df_patient$date <- sample(dates, size=nrow(df_patient), replace = T)
# dates_graphique(df_patient$date, nom_variable = "dates")
# 
# # dates_graphique_comparaison
# initial_x <- df_patient$date
# index_selection <- sample(1:nrow(df_patient),size = 20)
# dates_graphique_comparaison(initial_x,index_selection,"dates")
# 
# #  barplot_graphique_comparaison
# initial_x <- df_patient$categorieAge
# barplot_graphique_comparaison(initial_x,index_selection,"catégories")
