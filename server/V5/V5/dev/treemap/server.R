require(treemap)
require(dplyr)
require(shiny)
require(gridBase)
require(RColorBrewer)
require(plotly)

pop_data=read.csv("Population_by_country_region_1960_2015.csv", stringsAsFactors =FALSE)

### Handle cliks on a treemap
tmLocate <- function(coor, tmSave) {
    tm <- tmSave$tm
    # retrieve selected rectangle
    rectInd <- which(tm$x0 < coor[1] &
                       (tm$x0 + tm$w) > coor[1] &
                       tm$y0 < coor[2] &
                       (tm$y0 + tm$h) > coor[2])
    return(tm[rectInd[1], ])
  }
#######
input = data.frame(region = "South Asia")
data_selected_region <-     pop_data[pop_data$Region%in%input$region,]
temp <- data_selected_region
shinyServer(function(input, output) {
  data_selected_region <- reactive({
    pop_data[pop_data$Region%in%input$region,]
  })
  
  output$threemap_population_country <- renderPlot({ 
    
    par(mar=c(0,0,0,0), xaxs='i', yaxs='i') 
    plot(c(0,1), c(0,1),axes=F, col="white")
    vps <- baseViewports()
    
    temp=data_selected_region()
    temp=filter(temp, Year==2015)
    .tm <<- treemap(temp, 
                    index="Country", 
                    vSize="Population", 
                    vColor="Population",
                    type="value",
                    title = "",
                    palette="Blues",
                    border.col ="white",
                    position.legend="right",
                    fontsize.labels = 16,
                    title.legend="")
  })
  
  
  treemap_clicked_country <- reactiveValues(
    center = NULL,
    for_condition=NULL
  )
  
  # Handle clicks on treemap by country
  observeEvent(input$click_treemap_country, {
    x <- input$click_treemap_country$x
    y <- input$click_treemap_country$y
    treemap_clicked_country$center <- c(x,y)
    
    if(is.null(treemap_clicked_country$for_condition)){
      treemap_clicked_country$for_condition=c(x,y)
    }
    else{treemap_clicked_country$for_condition=NULL}
  })
  
  getRecord_population_country <- reactive({
    x <- treemap_clicked_country$center[1]
    y <- treemap_clicked_country$center[2]
    
    x <- (x - .tm$vpCoorX[1]) / (.tm$vpCoorX[2] - .tm$vpCoorX[1])
    y <- (y - .tm$vpCoorY[1]) / (.tm$vpCoorY[2] - .tm$vpCoorY[1])
    
    
    l <- tmLocate(list(x=x, y=y), .tm)
    z=l[, 1:(ncol(l)-5)]
    
    
    if(is.na(z[,1]))
      return(NULL)
    
    col=as.character(z[,1])
    
    filter(pop_data,Country==col)
  })
  
  condition1<-reactive({
    
    refresh=refresh()
    
    if(is.null(treemap_clicked_country$for_condition) & refresh==0){
      result=1}else if((refresh%%2==0) & !is.null(treemap_clicked_country$for_condition)){
        result =0
      }else if((refresh%%2!=0) & !is.null(treemap_clicked_country$for_condition)){
        result =1
      }else if((refresh%%2!=0) & is.null(treemap_clicked_country$for_condition)){
        result =0
      }else if((refresh%%2==0) & is.null(treemap_clicked_country$for_condition)){
        result =1
      }
  })
  
  
  output$condition1 <- renderText({
    condition1()
  })
  
  outputOptions(output, 'condition1', suspendWhenHidden=FALSE)
  
  
  output$population_country_time_series<-renderPlotly({
    temp=getRecord_population_country()
    title=paste0("Population of ",unique(temp$Country))
    
    f <- list(
      family = "Courier New, monospace",
      size = 16,
      color = "#7f7f7f"
    )
    plot_ly(temp, x = ~Year,y = ~Population, type = 'bar', color = I("orange")) %>%
      layout(title = title,font=f,
             xaxis = list(title = ""),
             yaxis = list(title = "",range=c(min(temp$Population),max(temp$Population))))
  })
  
  
  output$zoomout = renderUI({
    actionButton("refresh", em("Go to the previous page",style="text-align:center;color:red;font-size:200%"))
  })
  
  refresh=reactive({
    input$refresh
  })
  
})


?treemap


data(GNI2014)
treemap(GNI2014,
        index=c("continent", "iso3"),
        vSize="population",
        vColor="GNI",
        type="value",
        format.legend = list(scientific = FALSE, big.mark = " "))


test <- rnorm(1000, 5, 2)
test <- round(test,0)
tab<- table(test)
tab <- data.frame(vSize=as.numeric(tab), index=names(tab))
tab$letter <- LETTERS[1:nrow(tab)]
tab$bool <- c(c(1,2),1)
treemap(tab,
        index=c("bool","letter"),
        vSize="vSize")


library(sunburstR)
sunburstR::sunburst()

sequences <- read.csv(
  system.file("examples/visit-sequences.csv",package="sunburstR")
  ,header = FALSE
  ,stringsAsFactors = FALSE
)[1:100,]
sunburst(sequences)












library(treemap)
library(sunburstR)
library(d3r)

# use example from ?treemap::treemap
data(GNI2014)
tm <- treemap(GNI2014,
              index=c("continent", "iso3"),
              vSize="population",
              vColor="continent",
              type="index")

tm_nest <- d3_nest(
  tm$tm[,c("continent", "iso3", "vSize", "color")],
  value_cols = c("vSize", "color")
)

sunburst(
  data = tm_nest,
  valueField = "vSize",
  count = TRUE,
  colors = htmlwidgets::JS("function(d){return d3.select(this).datum().data.color;}"),
  withD3 = TRUE
)
