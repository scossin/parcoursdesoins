jslink <- new.env()

jslink$newTabpanel <- function(tabsetPanel, liText, firstDivId){
  session$sendCustomMessage(type = "newTabpanel", 
                            message = list(tabsetPanel = tabsetPanel,
                                           liText = liText, firstDivId=firstDivId))
}
