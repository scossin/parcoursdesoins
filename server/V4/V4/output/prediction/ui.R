navbarPage("Parcours de soins", id="CartoParcours",
           navbarMenu("Analyse",
                      tabPanel("prediction",
                      fluidRow(
                        column(10,
                               HTML('<p id = "prediction_titre"> Courbe de prediction </p>'),
                               HTML('<p id = "prediction_explication"> Sélectionnez au moins 2 évènements dans l\'onglet Events</p>'),
                               plotOutput(outputId = "courbeprediction"),
                               tableOutput(outputId="tableprediction")
                               ),
                        column(2,
                               actionButton("goprediction","Plot prediction"),
                               actionButton("updateprediction", "Groupes de prediction",style = "display:visible;")
                               
                        ))),
           tabPanel("Clustering")))