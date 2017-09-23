library(shiny)
library(sunburstR)
library(R6)
library(httr)
library(XML)
library(shinyWidgets)
library(plotly)
library(dygraphs)
library(leaflet)
library(shinyTree)
library(jsonlite)

## Leaflet : 
GLOBALmapObjectControls = "mapObjectControls"
GLOBALcontrols <- "controls"
GLOBALmapId <- "mapId"
GLOBALlayerControl <- "layerControl"

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
  
  ## pieChart : 
  GLOBALinitialPieChart <- "valeurs initiales"
  GLOBALselectedPieChart <- "valeurs sélectionnées"
  
  ## TextInfo
  GLOBALvaluesSelectedOutOf <- "valeurs sélectionnées sur"
  
  ## and
  GLOBALand <- "et"
  
  ## hierarchy selection : 
  GLOBALnoselected <- "Sélectionnez une catégorie"
  GLOBALmanyselected <- "Merci de sélectionner une seule catégorie"
  
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
  
  ## pieChart : 
  GLOBALinitialPieChart <- "initial values"
  GLOBALselectedPieChart <- "selected values"
  
  ## TextInfo
  GLOBALvaluesSelectedOutOf <- "values selected out of"
  
  ## and
  GLOBALand <- "and"
  
  ## hierarchy selection : 
  GLOBALnoselected <- "please, select one class"
  GLOBALmanyselected <- "please, select only one class"
}


