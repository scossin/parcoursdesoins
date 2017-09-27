

server <- function(input, output, session) {
  source("../../classes/leaflet/MapObjectOO.R",local = T)
  source("../../classes/filter/FilterSpatialPointOO.R",local=T)
  mapObject <- MapObject$new()
}