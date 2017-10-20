navbarPage("Parcours de soins", id="CartoParcours",
           ### Sankey 
           tabPanel("Sankey",
                    div(id = GLOBALmainPanelSankeyId),
                    tabsetPanel(id = GLOBALeventTabSetPanelSankey)
           ),
           
           tabPanel("Events",
                    
                    fluidPage(
                      sidebarLayout(
                      sidebarPanel(width=2,
                        shiny::actionButton(inputId = GLOBALaddEventTabpanel,width = "180px", 
                                     label = GLOBALaddEventTabpanel
                                     ),
                        shiny::actionButton(inputId = GLOBALsetQuery,
                                            label = GLOBALlabelSetQuery,width = "180px"),
                        shiny::actionButton(inputId = GLOBALsearchEvents,width = "180px",
                                            label = GLOBALlabelSearchEvents)
                      ),
                      
                      mainPanel(
                        div(id = GLOBALdivQueryBuilder)
                      )
                      
                      )

                    ),
                    
                    
                    tags$head(
                      includeCSS("www/css/styleLeaflet.css"),
                      includeScript("www/js/newTabpanel.js"),
                      includeScript("www/js/removeId.js"),
                      includeScript("www/js/displayId.js"),
                      includeScript("www/js/empty.js"),
                      includeScript("www/js/goFirstSibling.js"),
                      includeCSS("www/css/ButtonFilter.css"),
                      includeCSS("www/css/Graphics.css"),
                      includeCSS("www/css/queryBuilder.css")
                    ), # fin tag$head
                    # pour retirer le tabset et le boutton permet de le retirer !
                    
                      tabsetPanel(id = GLOBALeventTabSetPanel,
                                  tabPanel("Context",
                                           div(id="contextId"))
                      )
                    ), ## end tabpanel Event
           

           
           ### leaflet
           tabPanel("Carte",
                    div(class="outer",
                        leaflet::leafletOutput(GLOBALmapId, width="100%", height="100%"),
                        # panel control pour la sélection
                        absolutePanel(id = GLOBALmapObjectControls, class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = 330, height = "auto",
                                      
                                      h4(GLOBALcontrols),
                                      div(id=GLOBALlayerControl)
                        ))
           )
)