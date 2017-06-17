navbarPage("Parcours de soins", id="CartoParcours",

### leaflet
tabPanel("Carte",
         div(class="outer",
             
             tags$head(
               # Include our custom CSS
               includeCSS("style_leaflet.css")
             ),
             leaflet::leafletOutput("map", width="100%", height="100%"),
             
             
             # panel control pour la sélection
             absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                           draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                           width = 330, height = "auto",
                           
                           h2("Sélection"),
                           actionButton("button", "Reset"),
                           checkboxInput("UNV",label = "UNV",value = T),
                           checkboxInput("SSR",label = "SSR",value = T),
                           h4("Provenance et destination"),
                           checkboxGroupInput("checkbox_transfert",label="Transfert", 
                                              choices=c("entree","sortie"), selected=c("entree","sortie"))
                           
             ) # fermeture absolute panel
         )
) # fermeture tabpanel leaflet

)