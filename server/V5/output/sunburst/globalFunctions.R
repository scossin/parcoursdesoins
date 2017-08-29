jslink <- new.env()

jslink$newTabpanel <- function(tabsetPanel, liText, contentId){
  session$sendCustomMessage(type = "newTabpanel", 
                            message = list(tabsetPanel = tabsetPanel,
                                           liText = liText, contentId=contentId))
}
