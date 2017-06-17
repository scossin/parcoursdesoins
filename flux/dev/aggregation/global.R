library(shiny)
library(shinyTree)
library(sqldf)
library(dplyr)
library(stringr)
library(leaflet)

load("evenements.rdata")
evenements$type <- gsub("^(.*?)#","",evenements$type) ### retirer tout ce qu'il y a avant #
evenements <- evenements %>% group_by(patient) %>% mutate(num = row_number()) ## numéroter les évènements
evenements <- as.data.frame(evenements) ## sinon erreur bizarre

load("output/leaflet/tab_spatial.rdata")


source("output/tree/fonctions_tree.R")