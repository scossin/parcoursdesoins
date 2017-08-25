rm(list=ls())
library(shiny)
library(sunburstR)
library(R6)
library(httr)
library(XML)

### load classes
classesFiles <- list.files("../../classes/",full.names = T)
sapply(classesFiles, source, .GlobalEnv)
con <- Connection$new()
query <- XMLCountquery$new()
query$addContextNode(contextVector = "")
query$listContextNode
eventCount <- con$sendQuery(query)
hierarchy <- con$getFile(con$fileEventHierarchy4Sunburst)
hierarchy <- merge (hierarchy, eventCount, by="event", all.x=T)
bool <- is.na(hierarchy$count)
hierarchy$count[bool] <- 0
colnames(hierarchy) <- c("event","tree","size")
hierarchy4sunburst <- hierarchy
hierarchy4sunburst$event<-NULL

source("hierarchicalSunburstOO.R")
source("HierarchicalOO.R")
source("eventTabpanelOO.R")


library(shinyjs)
shinyjs::extendShinyjs()

query <- XMLSearchQuery$new()
query$addEventNode(0, "SejourMCO")
query$listEventNodes
results <- con$sendQuery(query)

tab <- as.data.frame(table(results$context))
colnames(tab) <- c("context","frequency")
str(tab)
fivenum(table(results$context))
