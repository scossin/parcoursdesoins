#?navbarPage
navbarPage("CartoParcours", id="CartoParcours",

  navbarMenu("Flux",
             # onglet données
             # tabPanel("Sélection",
             #          h2("Informations tabulaires sur les établissements"),  
             #          DT::dataTableOutput("tableau")
             # ),
             
             # onglet Network
             tabPanel("Flux",
                      h2("Flux entre les établissements"),  
                      visNetworkOutput("network"),
                      
                      h4('Sélection et aggrégation'),
                      shinyTree("tree", checkbox = TRUE),
                      verbatimTextOutput("selTxt"),
                      actionButton("go", "go")
             )
             
  )
)
