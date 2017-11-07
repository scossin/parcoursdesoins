library(shiny)
library(shinydashboard)
library(plotly)

navbarPage("Parcours de soins", id="CartoParcours",
           tabPanel("FilterDate",
                    div (id = "divTestFilterDateOO")),
           
           tabPanel("FilterCategorical",
                    div (id = "divcontainer",
                         div(id="divTestFilterCategoricalOO"))),
           
           tabPanel("FilterHierarchical",
                         div(id="divTestFilterHierarchicalOO")),
           
           tags$head(
             includeScript("../../www/js/newTabpanel.js"),
             includeScript("../../www/js/removeId.js"),
             includeScript("../../www/js/displayId.js"),
             includeScript("../../www/js/goFirstSibling.js"),
             includeCSS("../../www/css/ButtonFilter.css"),
             includeCSS("../../www/css/Graphics.css")
           ) # fin tag$head
)