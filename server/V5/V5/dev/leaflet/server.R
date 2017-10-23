source("../../global.R")
server <- function(input, output, session) {
  # shapeFiles
  # a logger to log message in file
  GLOBALlogFolder <- "./"
  GLOBALshapeFileFolder <- "./../../shapeFiles/"
  
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
  source("../../classes/queries/STATICmakeQueriesOO.R",local=T)
  staticMakeQueries <- STATICmakeQueries$new()
  
  
  source("../../classes/queries/XMLCountQueryOO.R",local=T)
  source("../../classes/queries/XMLDescribeQueryOO.R",local=T)
  source("../../classes/queries/XMLDescribeTerminologyQueryOO.R",local = T)
  source("../../classes/queries/XMLqueryOO.R",local=T)
  source("../../classes/queries/XMLSearchQueryOO.R",local=T)
  source("../../classes/queries/XMLSearchQueryTerminologyOO.R",local=T)
  
  source("../../classes/events/InstanceSelection.R",local = T)
  source("../../classes/events/InstanceSelectionEvent.R",local = T)
  source("../../classes/events/InstanceSelectionContext.R",local = T)
  
  source("../../classes/terminology/STATICterminologyInstancesOO.R",local=T)
  source("../../classes/terminology/TerminologyOO.R",local=T)
  staticTerminologyInstances <- STATICterminologyInstances$new()
  
  
  source("../../classes/superClasses/uiObject.R",local=T)
  source("../../classes/filter/FilterOO.R",local=T)
  source("../../classes/leaflet/MapObjectOO.R",local = T)
  source("../../classes/filter/FilterSpatialPolygon.R",local=T)
  GLOBALmapObject <- MapObject$new()
  
  contextEnv <- new.env()
  predicateName <- "predicateName"
  dataFrame <- data.frame(event=character(),value=character())
  parentId <- "firstDivOfSomething"
  where = "beforeEnd"
  observeEvent(input$add,{
    filterSpatialPolgyon <- FilterSpatialPolygon$new(contextEnv, predicateName, dataFrame, parentId, where)
    GLOBALmapObject$addSpatialFilter(filterSpatialPolgyon) 
  })
}



