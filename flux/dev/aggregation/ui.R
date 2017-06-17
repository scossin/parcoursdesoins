navbarPage("Parcours de soins", id="CartoParcours",
  tabPanel("Events",
    tags$head(tags$script(src = "js/moveTree.js")),
    tags$head(tags$script(src = "js/addTabToTabset.js")),
    # pour retirer le tabset et le boutton permet de le retirer !
    tags$head(tags$script(src = "js/removeTabToTabset.js")),
    tags$head(tags$script(src = "js/sankey.js")),
    tags$head(
      # Include our custom CSS
      includeCSS("styleTrees.css")
    ),

    fluidRow(
    column(12,
           # tout englobé dans div pour le CSS
           div(id="alltrees"
           )
  ),
  tabsetPanel(id ="mainTabset",
    tabPanel("Console"), ### afficher des messages pour les utilisateurs
    tabPanel("Patients")
  )),
  # Important! : 'Freshly baked' tabs first enter here.
  #uiOutput("creationPool", style = "display: none;")
  uiOutput("creationPool")
  # End Important
  )
  ,
  #
  tabPanel("Sankey",
           fluidRow(
             column(10,
                    HTML('<p id = "sankey_event0" style="text-align:center; background-color:#F0F0F0; font-size:200%"> test </p>')
                    ),
             column(2,
                    actionButton("go","Plot Sankey"),
                    actionButton("update", "update",style = "display:none;", onclick = "remove_radiobuttons()")

             )
           ),
           fluidRow(sankeyD3::sankeyNetworkOutput("sankey"))),
  
  
  
  
  
  ### leaflet
  tabPanel("Carte",
           div(class="outer",
               
               tags$head(
                 # Include our custom CSS
                 includeCSS("style.css")
               ),
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