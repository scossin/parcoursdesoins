source("../../classes/filter/FilterHierarchicalOO.R",local = T)
source("../../classes/filter/FilterHierarchicalEventOO.R",local = T)
source("../../classes/filter/FilterOO.R",local = T)

contextEnv <- new.env()
terminology <- staticTerminologyInstances$getTerminology("Event")

predicateName <- "predicateName"
parentId <- "divTestFilterHierarchicalOO"
where <- "beforeEnd"

contextEnv$context <- "p1"
#eventCount <- staticMakeQueries$getEventCount(context)

dataFrame <- data.frame(event="test", value="SejourMCO")
predicateName <- "hasType"
filterCategorical <- FilterHierarchical$new(contextEnv, terminology, predicateName, 
                                              dataFrame, parentId, where)


