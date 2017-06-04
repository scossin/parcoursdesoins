library(shiny)
shinyUI(navbarPage("TiGr",
                   
                   tabPanel("File Input Page",
                            fluidPage("Input")),
                   
                   tabPanel("Summary Statistics and Plots",
                            fluidPage("Statistics")),
                   
                   tabPanel("Time Clusters",
                            fluidPage("cluster"),
                            actionButton("subClust", label = "Create Subcluster"),
                            uiOutput("tabs"),
                            conditionalPanel(condition="input.level==1",
                                             helpText("test work plz")
                            ), 
                            conditionalPanel(condition="input.level==5",
                                             helpText("hohoho")
                            )
                   )
))