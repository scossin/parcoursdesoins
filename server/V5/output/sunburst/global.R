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