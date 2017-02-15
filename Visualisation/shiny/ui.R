navbarPage("CartoParcours",
  
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

                        h3("Résumé"),
                        verbatimTextOutput("summary"),
                        plotOutput("graphique", height = 250)
                        
                        ) # fermeture absolute panel
               ) # fermeture div
  ),
  
  # onglet données
  tabPanel("Données",
    h2("Informations tabulaires sur les établissements"),  
    DT::dataTableOutput("table_pmsi")
  ),
  
  # onglet sur le clustering
  tabPanel("Clustering",
    h4("Cet onglet présente le résultat de l'analyse des parcours. 
       Il est possible de créer des liens vers l'onglet carte ou d'afficher de nouvelles cartes"))       
)


