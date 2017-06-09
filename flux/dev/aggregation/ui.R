shiny::fluidPage(
    tags$head(tags$script(src = "js/moveTree.js")),
    tags$head(
      # Include our custom CSS
      includeCSS("styleTrees.css")
    ),

    column(12,
           # tout englobé dans div pour le CSS
           div(id="alltrees"
    #            div(id="treeboutton0", value="0", class="box",
    #                 h4('Main Event'),
    #                 shinyTree("tree0", checkbox = TRUE),
    #                 #verbatimTextOutput("selTxt"),
    #                div(class="bouttons",
    #                actionButton("addprevious0", "<"),
    #                actionButton("addnext0", ">"),
    #                actionButton("validate0", "V"),
    #                actionButton("remove0", "X")
    #                )
    # #actionButton("afficher", "afficher")
    #        )
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