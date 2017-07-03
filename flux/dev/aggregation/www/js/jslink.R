jslink <- new.env()


jslink$moveTabpanel <- function(event_number, tabsetName){
  session$sendCustomMessage(type = "addTabToTabset", message = list(event_number = event_number, 
                                                                    tabsetName = tabsetName))
}

jslink$moveTabpatient <- function(tabsetName){
  session$sendCustomMessage(type = "addPatientsToTabset", message = list(tabsetName = tabsetName))
}

### déplace le tree après sa création pour le mettre au bon endroit (id alltrees)
jslink$moveTree <- function(treebouttonid, boolprevious){
  session$sendCustomMessage(type = "moveTree", message = 
                              list(divtargetname = "alltrees", treebouttonid = treebouttonid,
                                   boolprevious=boolprevious)) ## alltrees : emplacement des treebouttons (voir ui.R)
}


### treebouttonvalue : le numéro du div de treebouttonvalue : event$get_event_number()
## boolitself : faut-il retirer le div lui-même
jslink$remove_treebutton <- function(treebouttonvalue){
  session$sendCustomMessage(type = "remove_treebutton", message = 
                              list(value = treebouttonvalue))
}

### treebouttonvalue : le numéro du div de treebouttonvalue : event$get_event_number()
## boolitself : faut-il retirer le div lui-même
jslink$hide_boutton <- function(event){
  event_number <- event$get_event_number()
  bool <- event_number == 0
  if (bool){
    bouttonid <- event$get_removeid()
  }
  bool <- event_number < 0
  if (bool){
    bouttonid <- event$get_addnextid()
  }
  bool <- event_number > 0
  if (bool){
    bouttonid <- event$get_addpreviousid()
  }
  session$sendCustomMessage(type = "hide_boutton", message = list(bouttonid = bouttonid))
}


jslink$remove_tabset = function(tabsetid){
  session$sendCustomMessage(type = 'removeTabToTabset',
                            message = list(tabsetid = paste0("#tab-",tabsetid))) ### #tab- : Cf js
}