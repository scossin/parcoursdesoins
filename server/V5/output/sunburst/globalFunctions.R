addToTabpanelPool <- function(Panels){
  #Panels <- lapply(Panels, function(Panel){Panel$attribs$title <- NULL; return(Panel)})
  output$tabpanelPool <- renderUI({Panels})
}


jslink <- new.env()
jslink$moveTabpanel <- function(eventNumber, tabsetName){
  session$sendCustomMessage(type = "addTabToTabset", 
                            message = list(eventNumber = eventNumber, 
                                           tabsetName = tabsetName))
}

