navbarPage("Parcours de soins", id="CartoParcours",
           tabPanel("Events",
                    tags$head(
                      includeScript("../../www/js/addTabToTabset.js")
                    ), # fin tag$head
                    # pour retirer le tabset et le boutton permet de le retirer !
                    
                      tabsetPanel(id ="mainTabset",
                                 
                                  tabPanel("Console",
                                           tableOutput('show_inputs'),
                                           textOutput("selection")
                                           ), ### afficher des messages pour les utilisateurs
                                  tabPanel("Patients",
                                           div(id="switch1",
                                           materialSwitch(inputId = "inEtabEvent0", 
                                                          label = HTML("<b>inEtab</b> (blablabla)"), value = FALSE, 
                                                          status = "primary", right = T)),
                                           materialSwitch(inputId = "inMedecinEvent0", 
                                                          label = "inMedecin", value = FALSE, 
                                                          status = "primary", right = T)
                                           ),
                                  tabPanel("event0")
                                 
                      ),uiOutput("tabpanelPool")
                    )
           
           
                    # Important! : 'Freshly baked' tabs first enter here.
                    #uiOutput("creationPool", style = "display: none;")
                    #uiOutput("creationPool_tree"),
                    
                    # End Important
           )