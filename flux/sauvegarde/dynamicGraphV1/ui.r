navbarPage("CartoParcours", id="CartoParcours",
           
           # tout englobé dans div pour le CSS

           # onglet carte         
           tabPanel("Filtre",
                    div(class="outer",
                        
                        tags$head(
                          # Include our custom CSS
                          includeCSS("style.css")
                        ),
                    fluidRow(
                      column(3,
                             uiOutput("choose_dataset")),
                      column(6,
                             h2("Tableau"),
                             DT::dataTableOutput("tableau")
                      )
                      
                      ),
                    fluidRow(
                      column(10,
                             h2("Graphiques"),
                             uiOutput("choose_columns")
                             
                      )),
                    fluidRow(
                      column(12,
                             uiOutput("plots"))
                    ))
           ))