## Initialisation network
output$network <- renderVisNetwork({
  
  newagregat <- merge (dfagregation(), transfertMCOSSR, by.x="element",by.y="FROM")
  colnames(newagregat)[1:2] <- c("FROM","FROMagregat")
  newagregat <- merge (dfagregation(), newagregat, by.x="element",by.y="TO")
  colnames(newagregat)[1:2] <- c("TO","TOagregat")
  
  tab <- table(c(as.character(newagregat$FROMagregat), as.character(newagregat$TOagregat)))
  nodesnetwork <- data.frame(id = names(tab), N = as.numeric(tab)) ## value : nombre de passages
  nodesnetwork <- nodesnetwork[order(-nodesnetwork$N),]
  
  ### couleurs selon la valeur : pris sur StackOverflow
  # colors will be based on values in the Amount column
  v1 <- nodesnetwork$N
  # make some colors based on Amount - normalized
  z <- v1/max(v1)*1000
  nodesnetwork$color <- colorRampPalette(c('lightblue','blue','black'))(1000)[z]
  nodesnetwork$rs <- "raison sociale" ## ajout le label ...
  
  length(unique(nodesnetwork$id)) ## si inférieur à un certain nombre, on peut mettre un shape
  
  nodes <- data.frame(id = nodesnetwork$id, 
                      #label = paste(nodesnetwork$rs,nodesnetwork$N,sep="<br>"),                              # labels
                      label="",
                      #group=nodesnetwork$groupe,
                      title=paste(nodesnetwork$rs,nodesnetwork$N,sep="<br>"),
                      value = nodesnetwork$N,                                                # size 
                      #shape = nodesnetwork$shape,       # shape
                      color=nodesnetwork$color
                      # rs = nodesnetwork$rs
                      #title = paste0("<p><b>", 1:10,"</b><br>Node !</p>"),         # tooltip
                      #color = c("darkred", "grey", "orange", "darkblue", "purple"),# color
                      #shadow = T
  )                  # shadow
  
  library(dplyr)
  by_from <- group_by(newagregat,FROMagregat,TOagregat)
  Nfromto <- summarise(by_from, N = n())
  
  edges <- data.frame(from = Nfromto$FROMagregat, to = Nfromto$TOagregat,
                      #label = fluxfromto$n,                                 # labels
                      #length = c(100,500),                                        # length
                      arrows = c("to"),            # arrows
                      dashes = F,# dashes,
                      value=Nfromto$N,
                      color="lightgreen",
                      title=Nfromto$N
                      #font.size = fluxfromto$n 
                      #title = paste("Edge", 1:8),                                 # tooltip
                      #smooth = c(FALSE, TRUE),                                    # smooth
                      #shadow = c(FALSE, TRUE, FALSE, TRUE))                     # shadow
  )
  
  
  #selectedBy = list(variable = "rs", selected = as.character(nodesnetwork$rs)[1])
  
  # or add a selection on another column
  #idselection <- list(enabled = TRUE,useLabels=F,values=c(as.character(nodesnetwork$rs)))
  visNetwork(nodes, edges) %>%
    visOptions(highlightNearest = list(enabled=TRUE,algorithm="hierarchical"),
               nodesIdSelection = T)%>%
    #visGroups(groupname = "SSR", color = "green", shape="diamond") %>%
    #visGroups(groupname = "MCO", color = "blue", shape="dot") %>%
    visLegend() %>% visInteraction(multiselect=T)
})

# observe({
#   noeuds <- input$network_selected
#   cat("noeuds sélectionnés :", noeuds, "\n")
#   ## Modification carte : 
#   afficher_parcours("map",trajectoires,noeuds) ## afficher les parcours de ce subset
#   ### Modification tableau : 
#   DT::selectRows(DT::dataTableProxy("tableau"), get_etabrow(noeuds))
# })