### dockerfile recupéré sur le github de shiny apps puis personnalisation plus bas

FROM shiny:parcoursV4

MAINTAINER Sebastien Cossin "cossin.sebastien@gmail.com"

# =====================================================================
# R
# =====================================================================

## transfert du dossier de la V5 de l'application
COPY V5 /srv/shiny-server/V5

## remove the dev folder : not needed
RUN rm -R /srv/shiny-server/V5/dev

# installation du paquet sankeyD3 : (already done V4)
# RUN R -e "library(devtools);install_github('fbreitwieser/sankeyD3')"

# Autodetect packages needed for the examples (will install from CRAN)
RUN R -e "install.packages(packrat:::dirDependencies('/srv/shiny-server/V5'))"

# need the latest leaflet package (leaflet_1.1.0.9000) on Github or addLegend function will cause an error : 
 RUN R -e "library(devtools);devtools::install_github('rstudio/leaflet')"

########### 2 fichiers à remplacer : 
### modification du paramétrage javascript du paquet shinyTree (utilisant la libraire jstree.js) : 
## fichier : shinyTree/www/jsTree-3.0.2/jstree.js et jstree.min.js : 
# three_state			: false,
# de l'attribut : jstree.defaults.checkbox=

COPY jstree.min.js /usr/local/lib/R/site-library/shinyTree/www/jsTree-3.0.2/jstree.min.js
COPY jstree.js /usr/local/lib/R/site-library/shinyTree/www/jsTree-3.0.2/jstree

## permissions to write on the logs folder
RUN chmod 777 -R /srv/shiny-server/V5/logs/

## permissions to write on the queries folder
RUN chmod 777 -R /srv/shiny-server/V5/queries/


####  then inside the container run Rscript 

