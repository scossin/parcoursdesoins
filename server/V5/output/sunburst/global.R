library(shiny)
library(sunburstR)
library(R6)
library(httr)
library(XML)
library(shinyWidgets)

###################### Initialization
### load classes
classesFiles <- list.files("../../classes/queries/",full.names = T)
sapply(classesFiles, source)


GLOBALcon <- Connection$new()
GLOBALeventTabSetPanel <- "eventTabset" # tabsetPanel id of events

GLOBALlang <- "fr"

GLOBALpredicatesDescription <- Predicates$new(GLOBALlang)
GLOBALpredicatesDescription$predicatesDf


### label
if (GLOBALlang == "fr"){
  GLOBALaddEventTabpanel <- "Ajout un évènement"
  GLOBALremoveEventTabpanel <- "Retirer un évènement"
  GLOBALhide <- "Masquer"
  GLOBALshow <- "Afficher"
} else if (GLOBALlang == "en"){
  GLOBALaddEventTabpanel <- "Add an event"
  GLOBALremoveEventTabpanel <- "removeEventTabpanel"
  GLOBALhide <- "Hide"
  GLOBALshow <- "Show"
}





