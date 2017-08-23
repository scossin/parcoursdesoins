navbarPage("Parcours de soins", id="CartoParcours",
           tabPanel("Events",
                    tags$head(
                    ), # fin tag$head
                    # pour retirer le tabset et le boutton permet de le retirer !
                    
                    # fluidRow(
                    #   column(12,
                    #          # tout englobé dans div pour le CSS
                    #          div(id="alltrees",
                    #             
                    #          )
                    #   ),
                      tabsetPanel(id ="mainTabset",
                                 
                                  tabPanel("Console",
                                           textOutput("selection")
                                           ), ### afficher des messages pour les utilisateurs
                                  tabPanel("Patients"),
                                  tabPanel("event0",
                                           sunburstOutput("sunburst0")
                                           )
                      )),
                    # Important! : 'Freshly baked' tabs first enter here.
                    #uiOutput("creationPool", style = "display: none;")
                    uiOutput("creationPool_tree"),
                    uiOutput("creationPool_tabpanel")
                    # End Important
           )