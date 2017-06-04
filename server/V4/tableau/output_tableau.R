## DT : afficher une table

## pris sur github : https://gist.github.com/wch/4211337

# fichier créé avec le script FinessGeo.R
load("MetaDonneesEtab33.rdata")
rownames(locEtab33) <- NULL

output$tableau <- DT::renderDataTable({
  DT::datatable(locEtab33)
})

# get_etabrow <- function(finesses){
#   bool <- locEtab$nofinesset %in% finesses
#   return(which(bool))
# }

observe({
  
  ligne <- input$tableau_rows_selected
  if (length(ligne) > 0){
    finesses <- locEtab33@data[ligne,]$nofinesset
    cat ("Clique dans le tableau, row : ",ligne, "\n")
    
    ## Modification carte : 
    #afficher_parcours("map",trajectoires,finesses) ## afficher les parcours de ce subset
    
    # leafletProxy("map") %>% clearPopups()
    # for (i in ligne){
    #   nometab <- locEtab33SSR@data[i,]$rs
    #   x <- coordinates(locEtab33SSR)[i,1]
    #   y <- coordinates(locEtab33SSR)[i,2]
    #   leafletProxy("map") %>% addPopups(lat =y, lng = x, as.character(nometab))
    # }
    ### Modification network
    
    #visSelectNodes(visNetworkProxy("network"),id = finesses)

  }
})

