navbarPage("Parcours de soins", id="CartoParcours",
           navbarMenu("Analyse",
                      tabPanel("Survie",
                      fluidRow(
                        column(10,
                               HTML('<p id = "survie_titre"> Courbe de survie </p>'),
                               HTML('<p id = "survie_explication"> Sélectionnez au moins 2 évènements dans l\'onglet Events</p>'),
                               plotOutput(outputId = "courbesurvie"),
                               tableOutput(outputId="tablesurvie")
                               ),
                        column(2,
                               actionButton("gosurvie","Plot survie"),
                               actionButton("updatesurvie", "Groupes de survie",style = "display:visible;")
                               
                        ))),
           tabPanel("Clustering")))