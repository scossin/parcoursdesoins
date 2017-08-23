library(shiny)
library(sunburstR)
library(R6)
library(httr)
library(XML)

### load classes
classesFiles <- list.files("../../classes/",full.names = T)
sapply(classesFiles, source, .GlobalEnv)
con <- Connection$new()
query <- XMLCountquery$new()
query$addContextNode(contextVector = "")
query$listContextNode
eventCount <- con$sendQuery(query)
hierarchy <- con$getFile(con$fileEventHierarchy4Sunburst)
hierarchy <- merge (hierarchy, eventCount, by="event", all.x=T)
bool <- is.na(hierarchy$count)
hierarchy$count[bool] <- 0
colnames(hierarchy) <- c("event","tree","size")
hierarchy4sunburst <- hierarchy
hierarchy4sunburst$event<-NULL
hierarchy4sunburst$color <- sapply(rainbow(nrow(hierarchy4sunburst)), function(x) substr(x,1,7))
#sunburst(hierarchy4sunburst,colors = hierarchy4sunburst$color, count=T,legend = list(w=200))
#sum(hierarchy4sunburst$size)


server <- function(input,output,session){
  
  output$sunburst0 <- renderSunburst({
    add_shiny(sunburst(hierarchy4sunburst,colors = hierarchy4sunburst$color, count=T,legend = list(w=200)))
  })
  
  selection <- reactive({
    if (is.null(input$sunburst0_click)){
      return(NULL)
    }
    print(input$sunburst0_click)
    input$sunburst0_click
  })
  
  output$selection <- renderText(selection())
}


