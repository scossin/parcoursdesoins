rm(list=ls())
library(shiny)
library(timevis)
library(R6)
library(XML)
library(httr)
### load classes
# a logger to log message in file
GLOBALlogFolder <- "./"

source("../../classes/logger/STATICLoggerOO.R",local = T)
staticLogger <- STATIClogger$new()

## closing logger connection when user disconnect
session$onSessionEnded(function() {
  staticLogger$close()
})

staticLogger$info("Loading classes ...")
classesFiles <- list.files("../../classes/queries/",full.names = T)
sapply(classesFiles, source)

### SejourMCO : 
con <- Connection$new()
query <- XMLSearchQuery$new()
query$addEventNode(0, "SejourMCO")
results <- con$sendQuery(query)
results<- results[1:100,]

## liste les contextes
contexts <- results$context
## sélectionne un seul : 
context <- as.character(sample(contexts,size = 1))
context <- "p109"

## boucle sur tous les eventTabpanel pour récupérer les events de ce context 

bool <- results$context == context
sum(bool)
event0 <- results

describeEvents <- XMLDescribeQuery$new()
describeEvents$addEventTypeNode("SejourMCO") ## getEventType de TabPanepl
describeEvents$addContextNode(context) ## getContext d'un Tabpanel car ils sont tous liés entre eux
describeEvents$addPredicateTypeNode(predicateTypes = c("hasBeginning","hasEnd")) ## hard coded

describeEvents$addEventInstances(event0$event0)
describeEvents$listEventNodes
results0 <- con$sendQuery(describeEvents)

# results0 <- subset (results0, c("event","value"))
# save(results0,file = "../../dev/test/datesValues.rdata")
## date format : 
results0$value <- gsub("T|Z"," ",results0$value )
results0$value <- gsub("\\.[0-9]+ $","",results0$value )
results0$value
str(results0)
# x <- results0$value
# x <- gsub("T|Z"," ",x )
# x <- gsub("\\.[0-9]+ $","",x)
# tab <- table(x)
# tab <- data.frame(date=as.Date(names(tab)), frequency = as.numeric(tab))
# str(tab)
## 2 columns : start and end
beginning <- subset (results0, predicate == "hasBeginning")
beginning$predicate <- NULL
colnames(beginning) <- c("context","event","start")
end <- subset (results0, predicate == "hasEnd")
if (nrow(end)!=0){
  end$predicate <- NULL
  colnames(end) <- c("context","event","end")
  beginning <- merge (beginning, end, by=c("context","event"), all.x=T)
}
## rename 
timevisDf <- beginning
remove(beginning)

## add groupe 
timevisDf$event <- NULL
timevisDf$group <- "event0" ## all in the same row
timevisDf$content <- "" ### label 

printTimeDiff <- function(endDate, startDate){
  nSeconds <- as.numeric(difftime(endDate, startDate,units = c("secs")))
  nDays <- nSeconds /(60 * 60 * 24)
  nDays <- round(nDays,0)
  nSeconds <- nSeconds - (nDays * 60 * 60 *24)
  
  nHours <- nSeconds / (60 * 60)
  nHours <- round(nHours,0)
  nSeconds <- nSeconds - (nHours * 60 * 60)
  
  nMinutes <- nSeconds / (60)
  nMinutes <- round(nMinutes,0)
  # nSeconds <- nSeconds - (nMinutes * 60)
  
  timeDiffString <- paste0(nDays, "days - ", nHours, "hours - ", nMinutes, "minutes")
  return(timeDiffString)
}

timevisDf$duration <- printTimeDiff(timevisDf$end, timevisDf$start)

bool <- timevisDf$end == timevisDf$start
timevisDf$end[bool] <- NA ## make time instant, not time interval of 0
timevisDf$duration[bool] <- ""

groups <- names(table(timevisDf$group))
groupsTimevis <- data.frame(
  id = groups,
  content = groups
)
timevisDf$title <- timevisDf$duration
timevis(timevisDf,groupsTimevis,options = list(clickToUse=T, multiselect=T))


server <- function(input,output,session){
  output$timeline <- timevis::renderTimevis(
    timevis(timevisDf,groupsTimevis,options = list(clickToUse=T, multiselect=T))
  )
}