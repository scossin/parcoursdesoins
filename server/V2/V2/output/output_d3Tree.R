#SearchTree----

output$Hierarchy <- renderUI({
  Hierarchy=names(dfpatients)
  Hierarchy=head(Hierarchy,-1)
  selectizeInput("Hierarchy","Tree Hierarchy",
                 choices = Hierarchy,multiple=T,selected = Hierarchy,
                 options=list(plugins=list('drag_drop','remove_button')))
})

arbre <- reactiveValues()

observeEvent(input$d3_update,{
  arbre$nodes <- unlist(input$d3_update$.nodesData)
  activeNode<-input$d3_update$.activeNode
  if(!is.null(activeNode)) arbre$click <- jsonlite::fromJSON(activeNode)
})

# observeEvent(arbre$click,{
#   output$clickView<-renderTable({
#     as.data.frame(arbre$click)
#   },caption='Last Clicked Node',caption.placement='top')
# })


TreeStruct=eventReactive(arbre$nodes,{
  df=dfpatients
  if(is.null(arbre$nodes)){
    df=dfpatients
  }else{
    
    x.filter=tree.filter(arbre$nodes,m)
    df=ddply(x.filter,.(ID),function(a.x){dfpatients%>%filter_(.dots = list(a.x$FILTER))})
  }
  df
})

observeEvent(input$Hierarchy,{
  output$d3 <- renderD3tree({
    if(is.null(input$Hierarchy)){
      p=dfpatients
    }else{
      p=dfpatients%>%select(one_of(c(input$Hierarchy,"NEWCOL")))%>%unique
    }
    
    d3tree(data = list(root = df2tree(struct = p,rootname = 'Patient'), layout = 'collapse'),
           activeReturn = c('name','value','depth','id'),height = 18,direction = 'v')
  })
})

# observeEvent(arbre$nodes,{
#   output$results <- renderPrint({
#     str.out=''
#     if(!is.null(arbre$nodes)) str.out=tree.filter(arbre$nodes,m)
#     return(str.out)
#   })    
# })

output$table <- renderTable(expr = {
  TreeStruct()%>%select(-NEWCOL)
},include.rownames=FALSE )

