library(leaflet)

dataFrame <- data.frame(lat=c(44.8672714490391,44.9), long = c(-0.617864221255729,-0.62),
                        label=c("test1","test2"))
lat <- c(44.8672714490391,44.9)
long <- c(-0.617864221255729,-0.62)
leaflet() %>%
  addTiles(group = "OpenStreetMap") %>%
  addProviderTiles("Stamen.Toner", group = "Toner by Stamen") %>%
  addMarkers(runif(20, -75, -74), runif(20, 41, 42), group = "Markers") %>%
  addLayersControl(
    baseGroups = c("OpenStreetMap", "Toner by Stamen"),
    overlayGroups = c("Markers")
  )

makeIcon <- function(shape){
  icon <- leaflet::awesomeIcons(icon = shape, library = "fa", markerColor = "lightgray",
                        iconColor = "blue", spin =F , extraClasses = NULL,
                        squareMarker = FALSE, iconRotate = 0, fontFamily = "monospace",
                        text = NULL)
  return(icon)
}

bool <- c(T,F)
iconsList <- do.call(makeIcon, args=list(shape=c("circle","shape"))) 
str(iconsList)
unlist(iconsList)
str(iconsList)
iconsList[[1]]
iconsList[[1]] 
str(oneIcon)
m <- leaflet() %>% addProviderTiles(providers$OpenStreetMap) %>% 
  addAwesomeMarkers(icon = list(iconsList[[1]],iconsList[[2]]), 
                    lng=long, 
                    lat=lat,
                    label = c("test1","test2"), group="autre",
                    layerId = c("test1","test2")
                    ) %>% 
  addLayersControl(overlayGroups="autre", options = layersControlOptions((collapsed=F)))



m <- leaflet() %>% addProviderTiles(providers$OpenStreetMap) %>% 
  addCircleMarkers(
                    lng=long, 
                    lat=lat,
                    label = c("test1","test2"),
                    radius=10, group="autre",
                    layerId = c("test1","test2")
  )
m <- removeMarker(m, layerId = "test2")
m

leaflet() %>% addProviderTiles(providers$OpenStreetMap) %>% 
  addCircleMarkers(lng=long, lat=lat, radius = c(1,10),label = c("1","10"),fillColor = "black",
                   fillOpacity = 1,labelOptions = labelOptions(noHide=T), popup = c("Bordeaux","Arcachon"))
awesomeIcons


## chargement : 
# projection RGF93
library(leaflet)
library(sp)
library(rgdal)
EPSG <- rgdal::make_EPSG()
bool <- grepl("Lambert",EPSG$note,ignore.case = T)
EPSG_lambert <- subset (EPSG, bool)
RGF93 <- EPSG_lambert$prj4[EPSG_lambert$code==2154 & !is.na(EPSG_lambert$code)]

# création d'un objet CRS 
RGF93prj4 <- CRS(RGF93)

# couches des codes géographiques PMSI 2014
fichier_couche <- "couchegeoPMSI2014.rdata"
load("../../shapeFiles/couchegeoPMSI2014.rdata")
dep33 <- couchegeoPMSI2014
# chargement des UNV et des SSR
dep33 <- subset (couchegeoPMSI2014, substr(couchegeoPMSI2014$layerId,1,2) == 33)
### transformation nécessaire dans un autre référentiel
dep33 <- spTransform(dep33, CRS("+init=epsg:4326"))

bool <- is.na(dep33@data$N)
dep33@data$N[bool] <- 0
pal <- colorNumeric(
  palette = "Blues",
  domain = c(10,50,100,NA)
)

pal(11)
leaflet::addLegend()
pal <- colorQuantile("RdYlBu", dep33$N, n = 5)
dep33@data$color <- pal(dep33$N)
dep33@data$popupLabel <- paste0(dep33@data$label,"(",dep33@data$N,")")
m <- leaflet(dep33)  %>%
  addPolygons(popup=dep33$popupLabel,label=as.character(dep33$label), 
              labelOptions = labelOptions(direction = 'auto'),
              stroke=T,opacity=1,weight=1,color=dep33$color,
              layerId = dep33$layerId,group = "groupe2",
              highlightOptions = highlightOptions(
                color='#00ff00',bringToFront = T, sendToBack=T)
              )
m <- m %>% 
  addLegend(position = "bottomleft", pal = pal, values = ~dep33@data$N,
            title = "N",
            labFormat = labelFormat(prefix = ""),
            opacity = 1, group = "groupe2"
  ) 
m
m <- leaflet::clearGroup(map=m,group="groupe2")
m
leaflet::clearControls(m)
leaflet::removeTiles(m, "layerId50")

ids <- dep33@data$id[1:50]
for (id in ids){
  m <- leaflet::removeShape(map = m, layerId = id)
}
dep33$id
m
colorQuantile
addGraticule()
leaflet::addEasyButton()

leaf <- leaflet() %>%
  addTiles() %>%
  addGraticule()

iconList()


iconData = data.frame(
  lat = c(rnorm(10, 0), rnorm(10, 1), rnorm(10, 2)),
  lng = c(rnorm(10, 0), rnorm(10, 3), rnorm(10, 6)),
  group = rep(sort(c('green', 'red', 'orange')), each = 10),
  stringsAsFactors = FALSE
)

leaflet() %>% addMarkers(
  data = iconData,
  icon = ~ icons(
    iconUrl = sprintf('http://leafletjs.com/docs/images/leaf-%s.png', group),
    shadowUrl = 'http://leafletjs.com/docs/images/leaf-shadow.png',
    iconWidth = 38, iconHeight = 95, shadowWidth = 50, shadowHeight = 64,
    iconAnchorX = 22, iconAnchorY = 94, shadowAnchorX = 4, shadowAnchorY = 62,
    popupAnchorX = -3, popupAnchorY = -76
  )
)
