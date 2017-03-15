### dockerfile recupéré sur le github de shiny apps puis personnalisation plus bas

FROM shiny:parcours

MAINTAINER Sebastien Cossin "cossin.sebastien@gmail.com"

# =====================================================================
# R
# =====================================================================

## retire les apps par défaut
#RUN rm -R /srv/shiny-server/
#RUN mkdir /srv/shiny-server/

## transfert du dossier de la V1 de l'application
COPY V2 /srv/shiny-server/V2

# Autodetect packages needed for the examples (will install from CRAN)
RUN R -e "install.packages(packrat:::dirDependencies('/srv/shiny-server'))"

# installation d'un paquet venant de github : 
RUN R -e "library(devtools);install_github('metrumresearchgroup/d3Tree')"
