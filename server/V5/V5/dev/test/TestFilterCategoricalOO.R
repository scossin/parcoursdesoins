source("../../classes/filter/FilterOO.R", local=T)
source("../../classes/filter/FilterCategoricalOO.R",local = T)
source("../../classes/graphics/CategoricalGraphicsOO.R",local = T)
source("../../classes/values/CategoricalValuesOO.R",local=T)


contextEnv <- new.env()
predicateName <- "predicateName"
dataFrame <- data.frame(event = paste0("event",1:10), value = LETTERS[1:10])
parentId <- "divTestFilterCategoricalOO"
where <- "beforeEnd"

filterCategorical <- FilterCategorical$new(contextEnv, predicateName, dataFrame, parentId, where)