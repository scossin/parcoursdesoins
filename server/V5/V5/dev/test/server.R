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
  staticTerminologyInstances <- STATICterminologyInstances$new()
  
  
  source("../../classes/superClasses/uiObject.R",local=T)
  
  # source("TestFilterCategoricalOO.R",local = T)
  # source("TestFilterHierarchical.R",local = T)
  #source("TestFilterDateOO.R",local = T)
  output$htmlOutput <- renderUI({
    lislist <- NULL
    
    liDescription1 <-  shiny::tags$li("inEtab", class="lipredicate",
                                                        p("selected values : "))
    lislist <- append(lislist,shiny::tagList(liDescription1))
    print(lislist)
    liDescription2 <- shiny::tags$li("inDoctor", class="lipredicate",
                                     p("selected values : atres "))
    lislist <- append(lislist,shiny::tagList(liDescription2))
    #lislist <- list(liDescription1, liDescription2)
    print(lislist)
    lis <- shiny::tagList(lislist)
    print(lis)
    shiny::tags$ul(id="test","Ceci est du texte",
                   div(lis, style = "margin-left:400px"),

                   shiny::actionButton(inputId = "idButton",
                                       label = "Rechercher des attributs communs")
    )
  })

}