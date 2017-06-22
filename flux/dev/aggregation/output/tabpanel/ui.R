navbarPage("Parcours de soins", id="CartoParcours",
           tabPanel("Events",
                    tags$head(
                      ## script js
                      includeScript("../../www/js/addTabToTabset.js"),
                      ## css
                      includeCSS(path="../../www/CSS/styleTabpanel.css")
                    ), # fin tag$head
                    # pour retirer le tabset et le boutton permet de le retirer !
                    
                    fluidRow(
                      column(12,
                             # tout englobé dans div pour le CSS et appender les tree à alltrees
                             div(id="alltrees"
                             )
                      ),
                      tabsetPanel(id ="mainTabset",
                                  tabPanel("Console",
                                           HTML("Some text will go here"))
                      )),
                    # Important! : 'Freshly baked' tabs first enter here.
                    #uiOutput("creationPool", style = "display: none;")
                    uiOutput("creationPool")
                    # End Important
           ),
           tabPanel("Carte"))