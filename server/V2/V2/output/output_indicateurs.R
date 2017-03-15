labelsprecis <- c("Pourcentage de patients sous anti-agrégants plaquettaires ou anticoagulants",
                    "Pourcentage de patients avec une expertise neurovasculaire",
                    "Pourcentage de patients thrombolysés")
  
  output$radarchart <- renderChartJSRadar({
    colonne <- which(colnames(tindicateurs) == input$choixetab)
    chart <- chartJSRadar(scores=tindicateurs[,c(colonne,11,12)], labs=labelsprecis,maxScale=100,scaleStartValue=0)
  })
  output$AAP <- renderPlotly(create_plotly(indicateurs, "pourcentageAAP",labelsprecis[1]))
  output$thrombolyse <- renderPlotly(create_plotly(indicateurs, "pourcentageThrombolyse",labelsprecis[3]))
  output$expertise <- renderPlotly(create_plotly(indicateurs, "pourcentageExpertise",labelsprecis[2]))