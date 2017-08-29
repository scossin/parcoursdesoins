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

GLOBALlang <- "en"

GLOBALpredicatesDescription <- Predicates$new(GLOBALlang)
GLOBALpredicatesDescription$predicatesDf

GLOBALpredicatesDescription$getPredicateOfEvent("Traitement")
GLOBALpredicatesDescription$getPredicateDescriptionOfEvent("Traitement")
GLOBALpredicatesDescription$predicatesDf

### label
if (GLOBALlang == "fr"){
  GLOBALaddEventTabpanel <- "Ajout un évènement"
  GLOBALremoveEventTabpanel <- "Retirer un évènement"
} else if (GLOBALlang == "en"){
  GLOBALaddEventTabpanel <- "Add an event"
  GLOBALremoveEventTabpanel <- "removeEventTabpanel"
}





