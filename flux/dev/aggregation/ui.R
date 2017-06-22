navbarPage("Parcours de soins", id="CartoParcours",
  tabPanel("Events",
    tags$head(
      ## script js
      includeScript("www/js/moveTree.js"),
      includeScript("www/js/addTabToTabset.js"),
      includeScript("www/js/removeTabToTabset.js"),
      includeScript("www/js/sankey.js"),
      
      ## css
      includeCSS(path="www/CSS/styleTabpanel.css"),
      includeCSS(path="www/CSS/styleLeaflet.css"),
      includeCSS(path="www/CSS/styleSankey.css"),
      includeCSS(path="www/CSS/styleTrees.css")
    ), # fin tag$head
    # pour retirer le tabset et le boutton permet de le retirer !

    fluidRow(
    column(12,
           # tout englobé dans div pour le CSS
           div(id="alltrees"
           ),
           HTML("<hr style='border-top: dotted 1px;'/>") ## dotted line
  ),
  tabsetPanel(id ="mainTabset",
    tabPanel("Console") ### afficher des messages pour les utilisateurs
  )),
  # Important! : 'Freshly baked' tabs first enter here.
  #uiOutput("creationPool", style = "display: none;")
  uiOutput("creationPool"),
  uiOutput("creationPool2")
  # End Important
  )
  ,
  
  
  ## Sankey : 
  tabPanel("Sankey",
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
  
  , ## fin sankey
  
  
  
  ### leaflet
  tabPanel("Carte",
           div(class="outer",
           leaflet::leafletOutput("map", width="100%", height="100%"),
           
           
           # panel control pour la sélection
           absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                         draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                         width = 330, height = "auto",
                         
                         h2("Sélection"),
                         actionButton("button", "Reset"),
                         checkboxInput("UNV",label = "UNV",value = T),
                         checkboxInput("SSR",label = "SSR",value = T)
                         
                        ) # fermeture absolute panel
  )
  ) # fermeture tabpanel leaflet,
  
  ,    ### timelines
  
  
  tabPanel("Timelines")
)

  ## ordonner les trees
  # var $divs = $("div.box");
  # var valuesort = $divs.sort(function (a, b) {     return $(a).attr("value") > $(b).attr("value"); });
  # $("#alltrees").html(valuesort);