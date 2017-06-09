  shiny::fluidPage(
    tags$head(tags$script(src = "js/moveTree.js")),
    column(12,
           # tout englobé dans div pour le CSS
           div(id="alltrees", 
               div(id="treeboutton1", value="2", class="box",
    h4('Sélection et aggrégation'),
    shinyTree("tree1", checkbox = TRUE),
    #verbatimTextOutput("selTxt"),
    actionButton("boutton1", "go"),
    actionButton("afficher", "afficher")
           )
           )
  ),
  tabsetPanel(
    tabPanel("test")
  ),
  # Important! : 'Freshly baked' tabs first enter here.
  #uiOutput("creationPool", style = "display: none;")
  uiOutput("creationPool")
  # End Important
  )
  
  ## ordonner les trees
  # var $divs = $("div.box");
  # var valuesort = $divs.sort(function (a, b) {     return $(a).attr("value") > $(b).attr("value"); });
  # $("#alltrees").html(valuesort);