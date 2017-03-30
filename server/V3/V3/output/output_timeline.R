
# Insert the right number of plot output objects into the web page

## timeline
max_plots <- 10 ### pas plus de 10 timelines


output$plots <- renderUI({

  ## dépend de la sélection des patients : 
  nevents <- length(patientsids())
  if (input$n > nevents) {
    nchoix <- nevents
  } else {
    nchoix <- input$n
  }
  
  plot_output_list <- lapply(1:nchoix, function(i,patientsids) {
    plotname <- paste("plot", i, sep="")
    htmlpatient <- paste('<p style="text-align:center; background-color:#F0F0F0; font-size:200%">',patientsids[i],'</p>')
    list(HTML(htmlpatient),timevisOutput(plotname))
  },patientsids=patientsids())
  
  # Convert the list to a tagList - this is necessary for the list of items
  # to display properly.
  do.call(tagList, plot_output_list)
})

# Call renderPlot for each one. Plots are only actually generated when they
# are visible on the web page.
for (i in 1:max_plots) {
  # Need local so that each item gets its own number. Without it, the value
  # of i in the renderPlot() will be the same across all instances, because
  # of when the expression is evaluated.
  local({
    my_i <- i
    plotname <- paste("plot", my_i, sep="")
    
    output[[plotname]] <- renderTimevis({
      unetimeline <- subset(listeevents,patientid==patientsids()[my_i])
      timevis(unetimeline,groupes,options = list(clickToUse=T, multiselect=T))
    })
  })
}

observe(
  for (i in 1:10){
    selected <- paste("plot",i,"_selected",sep="")
    cat(input[[selected]])
  }
)