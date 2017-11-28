source("../../global.R")
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
  source("../../classes/buttonFilter/ButtonFilterOO.R",local = T)
  staticTerminologyInstances <- STATICterminologyInstances$new()
  
  source("../../classes/superClasses/uiObject.R",local=T)
  
  # source("TestFilterCategoricalOO.R",local = T)
  source("TestFilterHierarchical.R",local = T)
  #source("TestFilterDateOO.R",local = T)
}


library(sunburstR)
sunburstR::sunburst()

library(sunburstR)

# read in sample visit-sequences.csv data provided in source
# only use first 200 rows to speed package build and check
#   https://gist.github.com/kerryrodden/7090426#file-visit-sequences-csv
sequences <- read.csv(
  system.file("examples/visit-sequences.csv",package="sunburstR")
  ,header = FALSE
  ,stringsAsFactors = FALSE
)[1:100,]

sunburst(sequences)

## Not run: 

# explore some of the arguments
sunburst(
  sequences
  ,count = TRUE
)