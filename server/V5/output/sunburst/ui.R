navbarPage("Parcours de soins", id="CartoParcours",
           tabPanel("Events",
                    
                    fluidPage(
                      sidebarLayout(
                      sidebarPanel(
                        actionButton(inputId = "addEventTabpanel", 
                                     label = "Add an event"),
                        actionButton(inputId = "removeEventTabpanel", 
                                     label = "Remove an event"),
                        selectInput(inputId = "eventToRemove",
                                    label = c(""), 
                                    choices = c(""))
                      ),
                      mainPanel(
                        HTML("Developement")
                      )
                      
                      )

                    ),
                    
                    
                    tags$head(
                      includeScript("../../www/js/newTabpanel.js"),
                      includeScript("../../www/js/removeId.js")
                    ), # fin tag$head
                    # pour retirer le tabset et le boutton permet de le retirer !
                    
                      tabsetPanel(id = GLOBALeventTabSetPanel,
                                  tabPanel("Context")
                      )
                    )
           )