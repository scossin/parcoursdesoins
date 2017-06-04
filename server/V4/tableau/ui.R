#?navbarPage
navbarPage("CartoParcours", id="CartoParcours",

  navbarMenu("Etablissements",
             # onglet données
             tabPanel("Sélection",
                      h2("Informations tabulaires sur les établissements"), 
                      fluidRow(
                        column(10,
                        DT::dataTableOutput("tableau")))
                      
             )))