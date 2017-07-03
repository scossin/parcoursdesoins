navbarPage("Parcours de soins", id="CartoParcours",
           tabPanel("Events",
                    tags$head(
                      ## script js
                      includeScript("../../www/js/moveTree.js"),
                      includeScript("../../www/js/sankey.js"),
                      
                      ## css
                      includeCSS(path="../../www/CSS/styleTrees.css")
                    ), # fin tag$head
                    # pour retirer le tabset et le boutton permet de le retirer !
                    
                    fluidRow(
                      column(12,
                             # tout englobé dans div pour le CSS
                             div(id="alltrees"
                             )
                      ),
                      tabsetPanel(id ="mainTabset",
                                  tabPanel("Console"), ### afficher des messages pour les utilisateurs
                                  tabPanel("Patients")
                      )),
                    # Important! : 'Freshly baked' tabs first enter here.
                    #uiOutput("creationPool", style = "display: none;")
                    uiOutput("creationPool_tree"),
                    uiOutput("creationPool_tabpanel")
                    # End Important
           )
           )