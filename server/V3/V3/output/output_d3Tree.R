#SearchTree----

output$Hierarchy <- renderUI({
  bool <- as.character(unlist(lapply(dfpatients, typeof))) == "integer"
  Hierarchy=names(dfpatients)[bool]
  Hierarchy <- Hierarchy[-1] # retirer patientid pour le mettre à la fin
  Hierarchy <- c(Hierarchy, "patientid")
  selectizeInput("Hierarchy","Ordonner les variables :",
                 choices = Hierarchy,multiple=T,selected = Hierarchy,
                 options=list(plugins=list('drag_drop','remove_button')))
})

# output$VarQuant <- 

arbre <- reactiveValues()

observeEvent(input$d3_update,{
  
  arbre$nodes <- unlist(input$d3_update$.nodesData)
  activeNode<-input$d3_update$.activeNode
  if(!is.null(activeNode)) {
    arbre$click <- jsonlite::fromJSON(activeNode)
  }
})

# observeEvent(arbre$click,{
#   output$clickView<-renderTable({
#     as.data.frame(arbre$click)
#   },caption='Last Clicked Node',caption.placement='top')
# })

## dépend de la sélection sur le noeud
selecteddelai <- reactive({
  d <- event_data(event="plotly_selected",source="delai")
  
  if (!is.null(d) & is.data.frame(d)){
    cat(nrow(d))
    previous <- TreeStruct()
    selected <- previous[d$pointNumber+1,] ## +1 car R débute à 1, Js à 0 l'index des tableaux :-)
    return(selected)
  } else{
    return (NULL)
  }
})


TreeStruct=eventReactive(arbre$nodes,{
  ## priorité de la sélection sur plotly que sur les tree : 
  df=dfpatients

  if(is.null(arbre$nodes)){
    df=dfpatients
  }else{
    x.filter=tree.filter(arbre$nodes,m)
    df=ddply(x.filter,.(ID),function(a.x){dfpatients%>%filter_(.dots = list(a.x$FILTER))})
  }
  df
})


### Sélection des évènements
patientsselection <- reactive({
  if (!is.null(selecteddelai())){
    selection <- selecteddelai()
  } else {
    selection <- TreeStruct()
  }
  #bool <- listeevents$patientid %in% selection$patientid
  return(selection)
})


### Sélection des évènements
listeeventsselection <- reactive({
  # if (!is.null(selecteddelai())){
  #   selection <- selecteddelai()
  # } else {
  #   selection <- TreeStruct()
  # }
  bool <- listeevents$patientid %in% patientsselection()$patientid
  return(subset(listeevents,bool))
})

### patients sélectionnés : 
patientsids <- reactive({
  evenements <- listeeventsselection()
  return(unique(evenements$patientid))
})

## Nombre de patients sélectionnés
# NombreDePatients <- reactive({
#   return(length(patientsids()))
# })

observeEvent(input$Hierarchy,{
  output$d3 <- renderD3tree({
    if(is.null(input$Hierarchy)){
      p=dfpatients
    }else{
      p=dfpatients%>%select(one_of(c(input$Hierarchy,"NEWCOL")))%>%unique
    }
    
    tree <- d3tree(data = list(root = df2tree(struct = p,rootname = 'Patient'), layout = 'collapse'),
           activeReturn = c('name','value','depth','id'),height = 10,direction = 'h')
    
  })
})


# selection <- dfpatients
# variable <-"classeAge"
create_pie <- function(selection, variable){
  # variable <- input$Hierarchy[1]
  # selection <- TreeStruct()
  colonne <- which(colnames(selection) == variable)
  valeurs <- table(selection[,colonne])
  plot_ly(selection, labels = names(valeurs), values = valeurs, type = 'pie') %>%
    layout(title = variable,
           xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
           yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
}
# output$pie <- renderPlotly({
#   create_pie(selection =  TreeStruct(), variable=input$Hierarchy[1])
# })

# output$table <- renderTable(expr = {
#   TreeStruct()%>%select(-NEWCOL)
# },include.rownames=FALSE )

# 


output$NpatientsDelai <- renderPrint({
  e <- event_data("plotly_selected",source="delai")
  if (is.null(e) | !is.data.frame(e)) {
    "Sélectionner un point !"} 
  else{
      paste ("Nombre de patients sélectionnés :",nrow(e))
    }
  
  ### "plotly_relayout" => deselected 
})

output$NpatientsTree <- renderPrint({
  paste ("Nombre de patients sélectionnés :", length(patientsids()))
})

### variable quantiative : les délais
output$delai <- renderPlotly({
  #colnames(dfpatients)
  plot_ly(TreeStruct(), x = 1:nrow(TreeStruct()), y = ~delaiSymptomeImagerie,
          type="scatter",mode="markers",source="delai")
})

# observe({
#   e <- event_data(event="plotly_selected",source="delai")
#   previous <- TreeStruct()
#   selected <- previous[e$pointNumber+1,] ## +1 car R débute à 1, Js à 0 l'index des tableaux :-)
#   cat(e$pointNumber+1)
#   TreeStruct() <- selected
#   #if (is.null(e)) return(dfpatients) else e
# })

# output$selected <- renderPrint({
#   e <- event_data("plotly_selected")
#   if (is.null(e)) "Hover on a point!" else e
# })


### piecharts : 

output$piecharts <- renderUI({
  plot_output_list <- lapply(1:3, function(i) {
    plotname <- paste("piechartN", i, sep="")
    plotlyOutput(plotname,width = '22%')
  })

  # Convert the list to a tagList - this is necessary for the list of items
  # to display properly.
  do.call(tagList, plot_output_list)
})

# Call renderPlot for each one. Plots are only actually generated when they
# are visible on the web page.
for (i in 1:3) {
  # Need local so that each item gets its own number. Without it, the value
  # of i in the renderPlot() will be the same across all instances, because
  # of when the expression is evaluated.
  local({
    my_i <- i
    plotname <- paste("piechartN", my_i, sep="")

    output[[plotname]] <- renderPlotly({
      create_pie(selection =  patientsselection(), variable=input$Hierarchy[my_i])
    })
  })
}