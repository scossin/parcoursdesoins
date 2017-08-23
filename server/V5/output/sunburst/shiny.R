library(shiny)
library(sunburstR)


hierarchy <- read.table("hierarchy4sunburst.txt",sep="\t",header=F)
colnames(hierarchy) <- c("event","eventHierarchy")
hierarchy$size <- 0
hierarchy$size[1] <- 1
hierarchy$event<-NULL
hierarchy$color <- sapply(rainbow(20), function(x) substr(x,1,7))



#  read the csv data downloaded from the Google Fusion Table linked in the article


server <- function(input,output,session){
  
  output$sunburst <- renderSunburst({
    #invalidateLater(1000, session)
    
    
    add_shiny(sunburst(hierarchy,colors = hierarchy$color, count=T,legend = list(w=200)))
  })
  
  output$selection <- renderText(input$sunburst_click)
}


ui<-fluidPage(
  
  # plot sunburst
  mainPanel(
    sunburstOutput("sunburst"),
    textOutput("selection")
  )
)

shinyApp(ui = ui, server = server)