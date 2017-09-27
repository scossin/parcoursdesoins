source("../../classes/filter/FilterOO.R", local=T)
source("../../classes/filter/FilterDate.R",local = T)
source("../../classes/graphics/DateGraphics.R",local = T)
source("../../classes/values/DateValuesOO.R",local=T)

contextEnv <- new.env()
predicateName <- "predicateName"
load("datesValues.rdata")
dataFrame <- results0
parentId <- "divTestFilterDateOO"
where <- "beforeEnd"

filterDate <- FilterDate$new(contextEnv, predicateName, 
                                           dataFrame, parentId, where)