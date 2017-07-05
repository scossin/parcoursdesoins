fonctions_prediction <- new.env()

fonctions_prediction$graphiques_comparaison <- function(data, y, colonnes){
  textes <- NULL
  for (i in colonnes){
    bool <- is.numeric (data[,i])
    if (bool){
      fonctions_prediction$comparaison_quant(data[,i], y, colnames(data)[i])
    } else {
      bool <- is.factor (data[,i]) | (length(table(data[,i])) < 10)
      if (bool){
        fonctions_prediction$comparaison_qual(data[,i], y, colnames(data)[i])
      } else {
        #### plus de 10 facteurs, on assume que c'est du texte
        cat("plus de 10 facteurs - pas de comparaison réalisée \n")
        return(NULL)
      }
      ### femerture if factor
      ### femerture else
    }
  } ## close the loop
}


fonctions_prediction$test_khi2_fisher <- function(x,y){
  resultat <- chisq.test(y,x, correct=F)
  ### toutes les valeurs attendues supérieurs à 5 : khi2
  # sinon on fait le fisher
  bool <- all(resultat$expected >= 5)
  if (bool){
    nom_test <- "khi2"
  } else {
    nom_test <- "fisher"
    resultat <- fisher.test(y,x)
  }
  pvalue <- resultat$p.value
  pvalue <- fonctions_prediction$transformer_pvalue(pvalue)
  return (list(nom_test = nom_test, pvalue=pvalue))
}

fonctions_prediction$transformer_pvalue <- function(pvalue){
  if (pvalue < 0.001){
    pvalue <- 0.001
  } else {
    pvalue <- round(pvalue, 3)
  }
}

fonctions_prediction$comparaison_quant <- function(x,y,nom_x){
  #   y <- df$intervention2
  #   x <- df$NIHSS.arrivée
  #   nom_x <- "test"
  ### test stat :
  
  if (!is.numeric(x)){
    stop("La variable x n'est pas numérique")
  }
  
  if (!length(names(table (y)))>1){
    cat ("Erreur, le nombre d'éléments y n'est pas supérieur à 1")
    return (0)
  }
  
  test <- fonctions_prediction$test_wilcox_whitney(x,y)
  
  ## résultat du test sur le plot :
  if (test$pvalue == 0.001){
    resultat_plot <- paste (test$nom_test, "< 0.001")
  } else {
    resultat_plot <- paste (test$nom_test, "=", test$pvalue)
  }
  ### boxplot
  titre <- paste ("Comparaison des distributions entre les groupes", resultat_plot, sep="\n")
  test <- boxplot(x~y,xaxt="n",ylab=nom_x, main=titre)
  
  ### axe du bas
  level <- names(table(y))
  level_n <- paste (level, " (" ,test$n, ")",sep="")
  axis (side=1, at=1:length(level), labels=level_n)
}

fonctions_prediction$test_wilcox_whitney <- function(x,y){
  if (length(names(table (y))) > 2){
    test <- "Kruskal-Wallis"
    resultat <- kruskal.test(y ~ x)
    pvalue <- resultat$p.value
    if (pvalue < 0.001){
      pvalue <- 0.001
    } else{
      pvalue <- round (pvalue, 3)
    }
  } else {
    test <- "wilcoxon"
    resultat <- wilcox.test(x[y==names(table(y))[1]], x[y==names(table(y))[2]])
    pvalue <- resultat$p.value
    if (pvalue < 0.001){
      pvalue <- 0.001
    } else{
      pvalue <- round (pvalue, 3)
    }
  }
  return (list(pvalue=pvalue, nom_test=test))
}
fonctions_prediction$comparaison_qual <- function (x, y, nom_x){
  # x <- df$intervention
  # y <- df$groupe
  # nom_x <- "test"
  ######### Test du khi2
  
  test <- fonctions_prediction$test_khi2_fisher(x,y)
  
  if (test$pvalue == 0.001){
    resultat_plot <- paste (test$nom_test, "< 0.001")
  } else {
    resultat_plot <- paste (test$nom_test, "=", test$pvalue)
  }
  
  ##### titre
  titre <- paste (nom_x, resultat_plot, sep="\n")
  
  #### Axe
  counts <- table (x,y)
  comptes <- as.numeric (counts)
  pourcentages <- as.numeric (c(prop.table(counts[,1]),prop.table(counts[,2])))
  counts <- matrix(pourcentages, ncol=2)
  pourcentages <- round (pourcentages*100,1)
  comptes_pourcen <- paste (pourcentages, " (",comptes,")", sep="")
  #par(mar = c(4, 4, 4, 4))
  niveau_x <- length(table(x))
  couleurs <- rainbow(niveau_x)
  par(mar = c(6, 4, 4, 4))
  bplt <- barplot(counts, main=titre, col=c(couleurs), beside=TRUE
                  , ylab="pourcentage", ylim = c(0,1.1))
  at_axis <- c(mean(bplt[,1]), mean(bplt[,2]))
  axis (side = 1, at = at_axis, labels=names(table(y)))
  text(x=bplt, y=(pourcentages + 2)/100, labels=as.character(comptes_pourcen))
  
  #legend ("topright",legend=names(table(x)), fill=c("red","green"),bty="n", title=nom_x)
  par(fig = c(0, 1, 0, 1), oma = c(0, 0, 0, 0), mar = c(0, 0, 0, 0), new = TRUE)
  plot(0, 0, type = "n", bty = "n", xaxt = "n", yaxt = "n")
  legend ("bottom",legend=names(table(x)), horiz=F, xpd=T, inset = c(0, 0),
          fill=couleurs,bty="n", y.intersp = 0.8)
  
  #legend("bottom", c("IM", "IBD", "1R", "2R"), xpd = TRUE, horiz = TRUE, inset = c(0, 0), bty = "n", pch = c(4, 2, 15, 19), col = 1:4, cex = 2)
  
  ### paramètres graphiques par défault :
  par(fig = c(0, 1, 0, 1), oma = c(0, 0, 0, 0), mar = c(5.1, 4.1, 4.1, 2.1), new = F)
  
}