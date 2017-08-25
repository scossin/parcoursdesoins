library(shiny)
library(sunburstR)
library(R6)
library(httr)
library(XML)
library(shinyjs)
library(shinyWidgets)

###################### Initialization
### load classes
classesFiles <- list.files("../../classes/queries/",full.names = T)
sapply(classesFiles, source)

con <- Connection$new()
query <- XMLCountquery$new()
query$addContextNode(contextVector = "")
query$listContextNode
eventCount <- con$sendQuery(query)
hierarchy <- con$getFile(con$fileEventHierarchy4Sunburst)
hierarchy <- merge (hierarchy, eventCount, by="event", all.x=T)
bool <- is.na(hierarchy$count)
hierarchy$count[bool] <- 0
colnames(hierarchy) <- c("event","hierarchy","size")
hierarchy <- rbind(hierarchy, data.frame(event="Event",hierarchy="Event",size=0))

predicatesDescription <- con$getFile(fileName = con$filePredicatesDescription)
# eventPredicates <- con$getFile(fileName = con$filePredicateFrequency)
# 
# predicatesDescription <- merge(predicatesDescription, eventPredicates, by="predicate")
predicatesDescription$eventType <- "SejourMCO"
# predicatesDescription <- unique(predicatesDescription)
GLOBALpredicatesDescription <- predicatesDescription

test <- list()
test[[1]] <- predicatesDescription
test[[1]]$predicate
names(test[[1]]) <- "deux"
test[[2]] <- "trois"
test
names(test[[1]])
test$"deux"

server <- function(input,output,session){
  source("../../classes/events/HierarchicalOO.R",local = T)
  source("../../classes/events/HierarchicalSunburstOO.R",local = T)
  source("../../classes/events/EventTabpanelOO.R",local=T)
  source("../../classes/buttonFilter/ButtonFilterOO.R",local=T)
  source("../../classes/Filter/FilterNumericOO.R",local=T)
  source("../../classes/Filter/FilterOO.R",local=T)
  source("globalFunctions.R", local = T)
  
  hierarchicalObject <- HierarchicalSunburst$new(eventNumber=1, hierarchy)
  
  eventTabpanel <- EventTabpanel$new(eventNumber=1,hierarchicalObject)
  tabPanel <- eventTabpanel$getTabpanel()
  addToTabpanelPool(tabPanel)
  jslink$moveTabpanel(1,"mainTabset")
  eventTabpanel$hierarchicalObject$makeUI()
  eventTabpanel$hierarchicalObject$sendPrivate()
  eventTabpanel$addHierarchicalObserver()
  
  
}

#o$destroy()
# AllInputs <- reactive({
#   x <- reactiveValuesToList(input)
#   df <- data.frame(
#     names = names(x),
#     values = paste(unlist(x, use.names = FALSE), collapse="\t")
#   )
#   print(df)
#   return(df)
# })
# 
# output$show_inputs <- renderTable({
#   AllInputs()
# })

#eventTabpanel$addHierarchicalObserver()
# output$sunburst0 <- renderSunburst({
#   add_shiny(sunburst(hierarchy4sunburst,colors = hierarchy4sunburst$color, count=T,legend = list(w=200)))
# })
# 
# selection <- reactive({
#   if (is.null(input$sunburst0_click)){
#     return(NULL)
#   }
#   print(input$sunburst0_click)
#   input$sunburst0_click
# })
# 
# output$selection <- renderText(selection())
