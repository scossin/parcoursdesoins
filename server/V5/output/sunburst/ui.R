navbarPage("Parcours de soins", id="CartoParcours",
           tabPanel("Events",
                    
                    fluidPage(
                      sidebarLayout(
                      sidebarPanel(
                        actionButton(inputId = "addEventTabpanel", 
                                     label = GLOBALaddEventTabpanel
                                     ),
                        actionButton(inputId = "removeEventTabpanel", 
                                     label = GLOBALremoveEventTabpanel),
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
                      includeScript("../../www/js/removeId.js"),
                      includeScript("../../www/js/displayId.js"),
                      includeScript("../../www/js/goFirstSibling.js"),
                      includeCSS("../../www/css/ButtonFilter.css")
                    ), # fin tag$head
                    # pour retirer le tabset et le boutton permet de le retirer !
                    
                      tabsetPanel(id = GLOBALeventTabSetPanel,
                                  tabPanel("Context")
                      )
                    )
           )