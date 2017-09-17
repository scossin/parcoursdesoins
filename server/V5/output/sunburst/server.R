# source("global.R")
server <- function(input,output,session){
  source("../../classes/logger/STATICLoggerOO.R",local = T)
  staticLogger <- STATIClogger$new()
  
  ## closing logger connection when user disconnect
  session$onSessionEnded(function() {
    staticLogger$close()
  })
  
  staticLogger$info("Loading classes ...")
  
  source("../../classes/queries/ConnectionOO.R",local=T)
  GLOBALcon <- Connection$new()
  
  source("../../classes/queries/GetFileOO.R",local=T)
  
  source("../../classes/queries/PredicatesOO.R",local=T)
  GLOBALterminologyDescription <- list(
    Event = Predicates$new(GLOBALcon$terminology$Event,GLOBALlang),
    RPPS = Predicates$new(GLOBALcon$terminology$RPPS,GLOBALlang),
    Etablissement = Predicates$new(GLOBALcon$terminology$FINESS,GLOBALlang),
    Graph = Predicates$new(GLOBALcon$terminology$Graph,GLOBALlang)
    )

    # GLOBALterminologyDescription$CONTEXT$getPredicateDescriptionOfEvent("Graph")
    #   getPredicateDescriptionOfEvent("")
    # GLOBALterminologyDescription$Etablissement$predicatesDf
  source("../../classes/queries/STATICmakeQueriesOO.R",local=T)

  source("../../classes/queries/XMLCountQueryOO.R",local=T)
  source("../../classes/queries/XMLDescribeQueryOO.R",local=T)
  source("../../classes/queries/XMLDescribeTerminologyQueryOO.R",local = T)
  source("../../classes/queries/XMLqueryOO.R",local=T)
  source("../../classes/queries/XMLSearchQueryOO.R",local=T)
  
  

  source("../../classes/superClasses/uiObject.R",local=T)
  source("../../classes/filter/HierarchicalOO.R",local = T)
  source("../../classes/filter/HierarchicalSunburstOO.R",local = T)
  source("../../classes/events/EventTabpanelOO.R",local=T)
  source("../../classes/events/ListEventsTabpanelOO.R",local=T)
  source("../../classes/buttonFilter/ButtonFilterOO.R",local=T)
  source("../../classes/filter/FilterOO.R",local=T) ## order matters ! 
  source("../../classes/filter/FilterNumericOO.R",local=T)
  source("../../classes/filter/FilterNumericDurationOO.R",local=T)
  source("../../classes/graphics/NumericGraphicsOO.R",local = T)
  source("../../classes/values/NumericValuesOO.R",local = T)

  source("../../classes/filter/FilterCategoricalOO.R",local = T)
  source("../../classes/graphics/CategoricalGraphicsOO.R",local = T)
  source("../../classes/values/CategoricalValuesOO.R",local=T)
  
  source("../../classes/filter/FilterDate.R",local = T)
  source("../../classes/graphics/DateGraphics.R",local = T)
  source("../../classes/values/DateValuesOO.R",local=T)
  
  source("../../classes/events/InstanceSelection.R",local = T)
  
  # an object to help others objects to create Filter Object
  source("../../classes/filter/STATICfilterCreatorOO.R",local = T)
  staticFilterCreator <- STATICfilterCreator$new()
  
  # an object to help others object to make queries
  source("../../classes/queries/STATICmakeQueriesOO.R",local=T)
  staticMakeQueries <- STATICmakeQueries$new()
  
  listEventTabpanel <- ListEventsTabpanel$new()
  
  
  
  ### Context : 
  staticLogger$info("creating Context...")
  # get a sample ...
  
  contextEvents <- data.frame(context=paste0("p",1:100),event=paste0("p",1:100))
  parentId = "contextId"
  where = "beforeEnd"
  contextEnv <- new.env()
  contextEnv$eventNumber <- 99999
  contextEnv$instanceSelection <- InstanceSelection$new(contextEnv = contextEnv, 
                                                        terminologyName = "Graph", 
                                                        className = "Graph", 
                                                        contextEvents = contextEvents, 
                                                        parentId = parentId, 
                                                        where = where)
  rm(contextEvents)
  staticLogger$info("ContextEnv added")
  
  
  observeEvent(input$addEventTabpanel,{
    staticLogger$user("addEventTabpanel clicked")
    nClick <- input$addEventTabpanel
    ## create new Tabpanel :
    eventTabpanel <- EventTabpanel$new(eventNumber=nClick, 
                                       context = contextEnv$instanceSelection$context)
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
    staticLogger$user("removeEventTabpanel")
    isolate({
      liText <- input[["eventToRemove"]]
      staticLogger$user(liText, " to remove")
    })
    listEventTabpanel$removeEventTabpanel(liText = liText)
    choices <- c("",listEventTabpanel$getAllLiText())
    shiny::updateSelectInput(session,
                             inputId = "eventToRemove",
                             choices = choices)
  })
  
  
  # AllInputs <- reactive({
  #   x <- reactiveValuesToList(input)
  #   df <- data.frame(
  #     names = names(x),
  #     values = paste(unlist(x, use.names = FALSE), collapse="\t")
  #   )
  #   print(df)
  #   return(df)
  # })
}

#o$destroy()

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

# test <- GLOBALterminologyDescription[[GLOBALcon$terminology$Event]]
# test$predicatesDf

