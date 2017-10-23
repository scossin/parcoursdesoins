navbarPage("Parcours de soins", id="CartoParcours",
           ### leaflet
           tabPanel("Carte",
                    div(class="outer",
                        tags$head(
                          # Include our custom CSS
                          includeCSS("../../www/css/styleLeaflet.css"),
                          includeScript("../../www/js/newTabpanel.js"),
                          includeScript("../../www/js/removeId.js"),
                          includeScript("../../www/js/displayId.js"),
                          includeScript("../../www/js/goFirstSibling.js"),
                          includeCSS("../../www/css/ButtonFilter.css"),
                          includeCSS("../../www/css/Graphics.css")
                        ),
                        leaflet::leafletOutput(GLOBALmapId, width="100%", height="100%"),
                        
                        
                        # panel control pour la sélection
                        absolutePanel(id = GLOBALmapObjectControls, class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = 330, height = "auto",
                                      
                                      h4(GLOBALcontrols),
                                      shiny::actionButton("add",label="add"),
                                      div(id=GLOBALlayerControl)
                                      )
                    )
           ), # fermeture tabpanel leaflet
           tabPanel("Events",
                    div (id = "firstDivOfSomething"))
)
