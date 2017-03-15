#?navbarPage
navbarPage("CartoParcours", id="CartoParcours",

  # onglet carte         
  tabPanel("Carte",
           
           # tout englobé dans div pour le CSS
           div(class="outer",
               
               tags$head(
                 # Include our custom CSS
                 includeCSS("style.css")
               ),
           
            # carte leaflet    
          leafletOutput("map", width="100%", height="100%"),
          
            # panel control pour la sélection
          absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                        draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                        width = 330, height = "auto",
                        
                        h2("Sélection"),
                        actionButton("button", "Reset"),
                        checkboxInput("UNV",label = "UNV",value = T),
                        checkboxInput("SSR",label = "SSR",value = T)
                        
                        ) # fermeture absolute panel
               ) # fermeture div
  ),
  
  ### patients : timelines et sélection
  navbarMenu("Patients",
             ## d3Tree pour la sélection
             tabPanel("Sélection",
                      fluidRow(
                        column(7,
                               uiOutput("Hierarchy"),
                               #verbatimTextOutput("results"),
                               #tableOutput("clickView"),
                               d3treeOutput(outputId="d3",width = '1200px',height = '800px')
                        ),
                        column(5,
                               tableOutput('table')
                        )
                      )),
             tabPanel("Timelines",
                      ### pb de CSS
                      # tags$head(
                      #   # Include our custom CSS
                      #   includeCSS("mytimevis.css")
                      # ),
                      uiOutput("plots"),
                      
                      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                    draggable = TRUE, top = 60, left = "auto", right = 120, bottom = "auto",
                                    width = 330, height = "auto",
                                    
                                    h2("Sélection"),
                                    selectInput("n","Nombre de timelines à afficher:",
                                                choices=c(1,10,20,50), selected=1)
                      ))
             ), ## fin patients
  
  
  navbarMenu("Etablissements",
             # onglet données
             tabPanel("Sélection",
                      h2("Informations tabulaires sur les établissements"),  
                      DT::dataTableOutput("tableau")
             ),
             
             # onglet Network
             tabPanel("Flux",
                      h2("Flux entre les établissements"),  
                      visNetworkOutput("network")
             )
             
  ), ## fin établissements
  
  
  
  navbarMenu("Indicateurs",
             tabPanel("Par indicateur",
                      navlistPanel(
                        "Liste des indicateurs",
                        tabPanel("Anti-Agrégants et anticoagulants",
                                 plotly::plotlyOutput("AAP")
                        ),
                        tabPanel("Thrombolyse",
                                 plotly::plotlyOutput("thrombolyse")
                        ),
                        tabPanel("Expertise Neuro-Vasculaire",
                                 plotly::plotlyOutput("expertise")
                        )
                      )),
             tabPanel("Par établissement",
                      fluidRow(
                        column(2,
                               selectInput("choixetab",label="Choix de l'établissement",
                                           choices = c(unique(as.character(indicateurs$nometab))),
                                           selected = "Etablissement E")
                        ),
                        column(10,
                               radarchart::chartJSRadarOutput("radarchart") 
                        )
                        
                      ))
             ),           


  
  # onglet sur le clustering
  tabPanel("Clustering",
    h4("Cet onglet aura pour objectif de présenter le résultat de l'analyse des parcours."),
    HTML("<br>"),
    HTML("<p style='font-size:125%'> Des propositions de cluster seraient proposées à l'utilisateur. 
      Un cluster correspondrait à un sous-ensemble (patients, établissements, zone géographique ...). 
      Ces clusters pourront être visualisés dans les onglets précédents.</p>")
    )       
)


