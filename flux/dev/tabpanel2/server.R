library(shiny)

shinyServer(function(input, output,session) {
  output$tabs=renderUI({
    
    Tabs<-as.list(rep(0,input$subClust+1))
    for (i in 0:length(Tabs)){
      Tabs[i]=lapply(paste("Layer",i,sep=" "),tabPanel,value=i)
    }
    
    #Tabs <- lapply(paste("Layer",0:input$subClust,sep=" "), tabPanel)
    do.call(tabsetPanel,c(Tabs,id="level"))
  })
}
)