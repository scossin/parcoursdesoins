shinyUI(pageWithSidebar(

  headerPanel(""),

  sidebarPanel(
    uiOutput("choose_dataset"),

    uiOutput("choose_columns"),
    
    actionButton("add", "Add UI"),
    br(),
    a(href = "https://gist.github.com/4211337", "Source code")
  ),


  mainPanel(
    DT::dataTableOutput("data_table")
  )
))
