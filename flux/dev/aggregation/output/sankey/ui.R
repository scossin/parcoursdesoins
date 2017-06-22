navbarPage("Parcours de soins", id="CartoParcours",

  tabPanel("Sankey",
           tags$head(
             includeScript(path = "../../www/js/sankey.js"),
             includeCSS(path="../../www/CSS/styleSankey.css")
             
             ),
         fluidRow(
           column(10,
                  HTML('<p id = "sankey_titre"> Diagramme de Sankey </p>'),
                  HTML('<p id = "sankey_explication"> Sélectionnez au moins 2 évènements dans l\'onglet Events puis sélectionnez les attributs à afficher pour chaque évènement (type par défaut)</p>')
           ),
           column(2,
                  actionButton("go","Plot Sankey"),
                  radioButtons("sankey_type",label = "Type de Sankey",choices=c("V1","V2"),selected = "V1"),
                  actionButton("update", "Update Choix",style = "display:visible;", onclick = "remove_radiobuttons()")
                  
           )
         ),
         fluidRow(sankeyD3::sankeyNetworkOutput("sankey"))
         )
  
  )