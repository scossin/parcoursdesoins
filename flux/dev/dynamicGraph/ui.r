navbarPage("CartoParcours", id="CartoParcours",
           
           # tout englobé dans div pour le CSS

           # onglet carte
           # tabPanel("Haut",
           # tabsetPanel(id = "test",
           tabPanel("Filtre",
                    div(class="outer",
                        
                        # tags$head(
                        #   # Include our custom CSS
                        #   includeCSS("style.css")
                        # ),
                    fluidRow(
                      column(6,
                             h2("Tableau"),
                             DT::dataTableOutput("tableau1")
                      )),
                   fluidRow(
                      column(3,
                             uiOutput("box1")),
                      column(3,
                             actionButton("go", "Go"))
                      
                      )
           )))