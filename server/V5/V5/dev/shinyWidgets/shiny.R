library(shinyWidgets)

shinyWidgets::shinyWidgetsGallery()


searchInput(inputId = "Id009", 
            label = "Click search icon to update or hit 'Enter'", 
            placeholder = "A placeholder", 
            btnSearch = icon("search"), 
            btnReset = icon("remove"), 
            width = "100%")


pickerInput(inputId = "Id062", 
            label = "Live search", choices = attr(UScitiesD, 
                                                  "Labels"), options = list(`live-search` = TRUE))




materialSwitch(inputId = "Id055", 
               label = "Primary", value = TRUE, 
               status = "primary")




library(shinysky)
shinysky::run.shinysky.example()

## Busy indicator !?