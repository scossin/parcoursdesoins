rm(list=ls())
library(shiny)
library(timevis)
library(R6)
library(XML)
library(httr)
### load classes
# a logger to log message in file
server <- function(input,output,session){
source("../../global.R")
GLOBALlogFolder <- "./"


source("../../classes/logger/STATICLoggerOO.R",local = T)
staticLogger <- STATIClogger$new()

staticLogger$info("Loading classes ...")
source("../../classes/queries/ConnectionOO.R",local = T)
source("../../classes/superClasses/uiObject.R",local = T)
source("../../classes/timeLines/TimelineOO.R",local = T)

## closing logger connection when user disconnect
session$onSessionEnded(function() {
  staticLogger$close()
})

### SejourMCO : 
GLOBALcon <- Connection$new()

source("../../classes/queries/GetFileOO.R",local=T)

source("../../classes/terminology/STATICterminologyInstancesOO.R",local=T)
source("../../classes/terminology/TerminologyOO.R",local=T)
staticTerminologyInstances <- STATICterminologyInstances$new()

load("../../contextEvents.rdata")
contextEvents <- subset(contextEvents, context == "p20")
timeline <- Timeline$new(parentId="timelineDiv",
                         where="beforeEnd",
                         contextEvents = contextEvents)

# eventsSelected <- c("p22_Aphasie_2009_09_21T03_00_00_000_02_00")
# 
# timevis(timevisDf,groupsTimevis,options = list(clickToUse=T, multiselect=T))

# eventDescription <- GLOBALcon$getEventDescriptionTimeline(
#   eventName = "p22_Aphasie_2009_09_21T03_00_00_000_02_00")
# eventDescription <- GLOBALcon$readContentStandard(eventDescription)

}

