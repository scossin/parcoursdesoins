navbarPage("Parcours de soins", id="CartoParcours",

### leaflet
tabPanel("Carte",
         div(class="outer",
             
             tags$head(
               # Include our custom CSS
               includeCSS("../../www/CSS/styleLeaflet.css")
             ),
             leaflet::leafletOutput("map", width="100%", height="100%"),
             
             
             # panel control pour la sélection
             absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                           draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                           width = 330, height = "auto",
                           
                           div(id="affichermapdiv",
                           actionButton("affichermap", "Recalculer")),
                           h4("Icônes"),
                           div(id="UNVSSRcheckbox",
                           checkboxInput("UNV",label = "UNV",value = T),
                           checkboxInput("SSR",label = "SSR",value = T)),

                           checkboxGroupInput("checkbox_transfert",label="Provenance et destination", 
                                              choices=c("entree","sortie"), selected=c("entree","sortie"),
                                              inline = T)
                           
             ) # fermeture absolute panel
         )
) # fermeture tabpanel leaflet

)