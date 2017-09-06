library(shiny)
library(sunburstR)
library(R6)
library(httr)
library(XML)
library(shinyWidgets)


# a logger to log message in file
GLOBALlogFolder <- "./logs/"



GLOBALeventTabSetPanel <- "eventTabset" # tabsetPanel id of events

GLOBALlang <- "fr"



### label
if (GLOBALlang == "fr"){
  GLOBALaddEventTabpanel <- "Ajout un évènement"
  GLOBALremoveEventTabpanel <- "Retirer un évènement"
  GLOBALhide <- "Masquer"
  GLOBALshow <- "Afficher"
  
  # duration
  GLOBALminutes <- "minutes"
  GLOBALhours <- "heures"
  GLOBALdays <- "jours"
  GLOBALweeks <- "semaines"
  GLOBALmonths <- "mois"
  
  ## boxplot
  GLOBALinitialBoxplot <- "valeurs initiales"
  GLOBALselectedBoxplot <- "valeurs sélectionnées"
  
  ## TextInfo
  GLOBALvaluesSelectedOutOf <- "valeurs sélectionnées sur"
  
  ## and
  GLOBALand <- "et"
  
} else if (GLOBALlang == "en"){
  GLOBALaddEventTabpanel <- "Add an event"
  GLOBALremoveEventTabpanel <- "removeEventTabpanel"
  GLOBALhide <- "Hide"
  GLOBALshow <- "Show"
  
  # duration
  GLOBALminutes <- "minutes"
  GLOBALhours <- "hours"
  GLOBALdays <- "days"
  GLOBALweeks <- "weeks"
  GLOBALmonths <- "months"
  
  ## boxplot
  GLOBALinitialBoxplot <- "initial values"
  GLOBALselectedBoxplot <- "selected values"
  
  ## TextInfo
  GLOBALvaluesSelectedOutOf <- "values selected out of"
  
  ## and
  GLOBALand <- "and"
}


