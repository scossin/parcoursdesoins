# eventPredicates <- con$getFile(fileName = con$filePredicateFrequency)
# 
# predicatesDescription <- merge(predicatesDescription, eventPredicates, by="predicate")
# predicatesDescription$eventType <- "SejourMCO"
# predicatesDescription <- unique(predicatesDescription)
# GLOBALpredicatesDescription <- predicatesDescription

# logFile <- "logFile.txt"
# if (!file.exists(logFile)){
#   file.create(logFile)
# }
# con <- file(logFile)
# sink(con, append=TRUE)
# sink(con, append=TRUE, type="message")

server <- function(input,output,session){
  source("../../classes/superClasses/uiObject.R",local=T)
  source("../../classes/filter/HierarchicalOO.R",local = T)
  source("../../classes/filter/HierarchicalSunburstOO.R",local = T)
  source("../../classes/events/EventTabpanelOO.R",local=T)
  source("../../classes/events/ListEventsTabpanelOO.R",local=T)
  source("../../classes/buttonFilter/ButtonFilterOO.R",local=T)
  source("../../classes/filter/FilterOO.R",local=T) ## order matters ! 
  source("../../classes/filter/FilterNumericOO.R",local=T)
  source("../../classes/filter/STATICfilterCreator.R",local = T)
  staticFilterCreator <- STATICfilterCreator$new()
  source("../../classes/queries/STATICmakeQueriesOO.R",local=T)
  staticMakeQueries <- STATICmakeQueries$new()
  source("globalFunctions.R", local = T)
  
  listEventTabpanel <- ListEventsTabpanel$new()
  
  observeEvent(input$addEventTabpanel,{
    nClick <- input$addEventTabpanel
    ## create new Tabpanel :
    eventTabpanel <- EventTabpanel$new(eventNumber=nClick, context="")
    eventTabpanel$setHierarchicalObject()
    listEventTabpanel$addEventTabpanel(eventTabpanel)
    
    #listNames <- c(eventTabpanel$getLiText(), names(listEventTabpanel))
    ### update list of elements to remove :
    choices <- c("",listEventTabpanel$getAllLiText())
    shiny::updateSelectInput(session,
                             inputId = "eventToRemove",
                              choices = choices)
  })
  
  observeEvent(input$removeEventTabpanel,{
    isolate({
      liText <- input[["eventToRemove"]]
    })
    listEventTabpanel$removeEventTabpanel(liText = liText)
    choices <- c("",listEventTabpanel$getAllLiText())
    shiny::updateSelectInput(session,
                             inputId = "eventToRemove",
                             choices = choices)
    
    ## ajouter dans finalize eventTabPanel : une fonction retirant le li
  })
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


# test <- list()
# testLength <- length(test)
# test[[testLength+1]] <- GLOBALcon
# names(test)[testLength+1] <- "test2"
# names(test)
# length(test)
# for (test1 in test){
#   print(test1$filePredicatesDescription)
# }

