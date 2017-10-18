ContextDescription <- R6::R6Class(
  inherit = uiObject,
  "ContextDescription",
  public = list(
    initialize = function(parentId, where){
      super$initialize(parentId,where)
      self$insertDivUI()
      self$insertHTMLdescription()
    },
    
    insertDivUI = function(){
      ui <- div(id=self$getDivId(),
                h2(GLOBALcontextDescription),
                shiny::uiOutput(outputId = self$getHTMLdescriptionContextId())
      )
      jQuerySelector = paste0("#",self$parentId)
      insertUI(
        selector = jQuerySelector,
        where = "beforeEnd",
        ui = ui
      )
    },
    
    getDivId = function(){
      return(paste0("ContextDivDescription-",self$parentId))
    },
    
    getHTMLdescriptionContextId = function(){
      return(paste0("HTMLdescriptionContext-",self$getDivId()))
    },
    
    insertHTMLdescription = function(){
        htmlDescription <- GLOBALcontextEnv$instanceSelection$getDescription()
        output[[self$getHTMLdescriptionContextId()]] <- renderUI({
          htmlDescription
        })
    }
  ))

