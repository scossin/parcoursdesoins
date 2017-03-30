## Initialisation network
output$network <- renderVisNetwork({
  MCOSSR <- subset (trajectoires, type == "MCOSSR")
  locEtab <- rbind (locEtab33SSR@data, locEtab33UNV@data)
  libetabnetwork <- subset (locEtab, select=c(rs,nofinesset))
  boolSSR <- libetabnetwork$nofinesset %in% locEtab33SSR$nofinesset
  boolMCO <- libetabnetwork$nofinesset %in% locEtab33UNV$nofinesset
  libetabnetwork$shape <- ifelse (boolSSR, "diamond",
                           ifelse (boolMCO,"dot", NA))
  libetabnetwork$color <- ifelse (boolSSR, "green",
                           ifelse (boolMCO,"blue", NA))
  libetabnetwork$groupe <- ifelse (boolSSR, "SSR",
                            ifelse (boolMCO,"MCO", NA))
  libetabnetwork <- subset (libetabnetwork, !is.na(shape))
  
  ## 
  by_from <- group_by(MCOSSR,from)
  Nfrom <- summarise(by_from, n = sum(N))
  by_to <- group_by(MCOSSR,to)
  Nto <- summarise(by_to, n = sum(N))
  colnames(Nfrom) <- c("nofinesset","N")
  colnames(Nto) <- c("nofinesset","N")
  Nfromto <- rbind (Nfrom, Nto)
  libetabnetwork <- merge (libetabnetwork, Nfromto, by="nofinesset")
  
  nodes <- data.frame(id = libetabnetwork$nofinesset, 
                      #label = paste(libetabnetwork$rs,libetabnetwork$N,sep="<br>"),                              # labels
                      label="",
                      group=libetabnetwork$groupe,
                      title=paste(libetabnetwork$rs,libetabnetwork$N,sep="<br>"),
                      value = libetabnetwork$N,                                                # size 
                      shape = libetabnetwork$shape,       # shape
                      color=libetabnetwork$color,
                      rs = libetabnetwork$rs
                      #title = paste0("<p><b>", 1:10,"</b><br>Node !</p>"),         # tooltip
                      #color = c("darkred", "grey", "orange", "darkblue", "purple"),# color
                      #shadow = T
  )                  # shadow
  
  edges <- data.frame(from = MCOSSR$from, to = MCOSSR$to,
                      #label = fluxfromto$n,                                 # labels
                      #length = c(100,500),                                        # length
                      arrows = c("to"),            # arrows
                      dashes = F,# dashes,
                      value=MCOSSR$N,
                      color="lightgreen",
                      title=MCOSSR$N
                      #font.size = fluxfromto$n 
                      #title = paste("Edge", 1:8),                                 # tooltip
                      #smooth = c(FALSE, TRUE),                                    # smooth
                      #shadow = c(FALSE, TRUE, FALSE, TRUE))                     # shadow
  )
  
  
  selectedBy = list(variable = "rs", selected = as.character(libetabnetwork$rs)[1])
  
  # or add a selection on another column
  idselection <- list(enabled = TRUE,useLabels=F,values=c(as.character(libetabnetwork$rs)))
  visNetwork(nodes, edges) %>%
    visOptions(highlightNearest = list(enabled=TRUE,algorithm="hierarchical"),
               selectedBy = selectedBy,nodesIdSelection = T)%>%
    visGroups(groupname = "SSR", color = "green", shape="diamond") %>%
    visGroups(groupname = "MCO", color = "blue", shape="dot") %>%
    visLegend() %>% visInteraction(multiselect=T)
})

observe({
  noeuds <- input$network_selected
  cat("noeuds sélectionnés :", noeuds, "\n")
  ## Modification carte : 
  afficher_parcours("map",trajectoires,noeuds) ## afficher les parcours de ce subset
  ### Modification tableau : 
  DT::selectRows(DT::dataTableProxy("tableau"), get_etabrow(noeuds))
})