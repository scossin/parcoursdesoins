navbarPage("Parcours de soins", id="CartoParcours",
           tabPanel("Events"),
           tabPanel("Timelines",
                    timevis::timevisOutput("timeline")
                    )
)