source("../../classes/filter/FilterHierarchicalOO.R",local = T)
source("../../classes/filter/FilterHierarchicalEventOO.R",local = T)
source("../../classes/filter/FilterOO.R",local = T)

contextEnv <- new.env()

predicateName <- "predicateName"
parentId <- "divTestFilterHierarchicalOO"
where <- "beforeEnd"

contextEnv$context <- "p92776"
#eventCount <- staticMakeQueries$getEventCount(context)

dataFrame <- data.frame(event="test", value="I50")
predicateName <- "hasDP"

contextEvents = data.frame(context="",event="")

terminology <- staticTerminologyInstances$getTerminology(
  staticTerminologyInstances$terminologyInstances$Event$terminologyName)
terminology$predicateDescription
contextEnv$eventNumber <- 1 
ls(contextEnv)
contextEnv$instanceSelection = InstanceSelection$new(contextEnv = contextEnv, 
                                          terminology = terminology, 
                                          className = terminology$mainClassName, 
                                          contextEvents = contextEvents, 
                                          parentId = "autre", 
                                          where = "beforeEnd")

terminology <- staticTerminologyInstances$getTerminology("CIM10")
filterCategorical <- FilterHierarchical$new(contextEnv = contextEnv, 
                                            terminology, predicateName, 
                                              dataFrame, parentId, where)


