### dockerfile recupéré sur le github de shiny apps puis personnalisation plus bas

FROM shiny:parcoursV2

MAINTAINER Sebastien Cossin "cossin.sebastien@gmail.com"

# =====================================================================
# R
# =====================================================================

## retire les apps par défaut
#RUN rm -R /srv/shiny-server/
#RUN mkdir /srv/shiny-server/

## transfert du dossier de la V3 de l'application
COPY V3 /srv/shiny-server/V3

# installation du paquet GoogleVis : 
RUN R -e "install.packages('googleVis')"

# installation du paquet GoogleVis : 
RUN R -e "library(devtools);install_github('metrumresearchgroup/d3Tree')"
