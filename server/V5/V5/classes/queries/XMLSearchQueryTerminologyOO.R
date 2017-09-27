XMLSearchQueryTerminology <- R6Class("XMLSearchQueryTerminology",
  inherit = XMLSearchQuery,

    public = list(
    
    initialize=function(){
      super$initialize()
    }),

  private=list(
    name = "eventslinks",
    system = "searchTerminology.dtd"
  )
)