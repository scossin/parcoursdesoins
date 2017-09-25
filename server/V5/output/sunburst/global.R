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
  
  ## filterHierarchical 
  GLOBALvalidate <- "Valider le choix"
  
  ## boxplot
  GLOBALinitialBoxplot <- "valeurs initiales"
  GLOBALselectedBoxplot <- "valeurs sélectionnées"
  
  ## pieChart : 
  GLOBALinitialPieChart <- "valeurs initiales"
  GLOBALselectedPieChart <- "valeurs sélectionnées"
  
  ## TextInfo
  GLOBALvaluesSelectedOutOf <- "valeurs sélectionnées sur"
  
  ## hierarchy selection : 
  GLOBALnoselected <- "Sélectionnez une catégorie"
  GLOBALmanyselected <- "Merci de sélectionner une seule catégorie"
  
  ## words
  GLOBALevent <- "évènements"
  GLOBALparcours <- "parcours de soins"
  GLOBALand <- "et"
  GLOBALselected <- "sélectionné(s)"
  
  ## instanceSelectionContext and Events : 
  GLOBALsearchContexts <- paste0("Rechercher des ",GLOBALparcours)
  GLOBALsearchEvents <- "Rechercher des évènements"
  
  ## context : 
  GLOBALupdateContext <- paste0("Choisir ces ",GLOBALparcours, " pour les ", GLOBALevent)
  
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
  
  ## hierarchy selection : 
  GLOBALnoselected <- "please, select one class"
  GLOBALmanyselected <- "please, select only one class"
  
  ## words
  GLOBALevent <- "event(s)"
  GLOBALparcours <- "patients trajectories"
  GLOBALselected <- "selected"
  GLOBALand <- "and"
  
  ## instanceSelectionContext and Events : 
  GLOBALsearchContexts <- paste0("Search ",GLOBALparcours)
  GLOBALsearchEvents <- "Search events"
  
  ## context : 
  GLOBALupdateContext <- paste0("Set these ",GLOBALparcours, " for ", GLOBALevent)
  
  ## filterHierarchical 
  GLOBALvalidate <- "Confirm"
}
