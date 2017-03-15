### dockerfile recupéré sur le github de shiny apps puis personnalisation plus bas

FROM ubuntu:16.04

MAINTAINER Sebastien Cossin "cossin.sebastien@gmail.com"

# =====================================================================
# R
# =====================================================================

# Don't print "debconf: unable to initialize frontend: Dialog" messages
ARG DEBIAN_FRONTED=noninteractive

# Need this to add R repo
RUN apt-get update && apt-get install -y software-properties-common

# Add R apt repository
RUN add-apt-repository "deb http://cran.r-project.org/bin/linux/ubuntu $(lsb_release -cs)/"
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

# Install basic stuff and R
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    vim-tiny \
    less \
    wget \
    r-base \
    r-base-dev \
    r-recommended \
    fonts-texgyre

RUN echo 'options(\n\
  repos = c(CRAN = "https://cran.r-project.org/"),\n\
  download.file.method = "libcurl",\n\
  # Detect number of physical cores\n\
  Ncpus = parallel::detectCores(logical=FALSE)\n\
)' >> /etc/R/Rprofile.site

# Create docker user with empty password (will have uid and gid 1000)
RUN useradd --create-home --shell /bin/bash docker \
    && passwd docker -d \
    && adduser docker sudo

# =====================================================================
# Shiny Server
# =====================================================================

RUN apt-get install -y \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev

# Download and install shiny server
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    R -e "install.packages(c('shiny', 'rmarkdown'))" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]

# =====================================================================
# Shiny Examples
# =====================================================================

RUN apt-get update && apt-get install -y \
    libxml2-dev

RUN R -e "install.packages(c('devtools', 'packrat'))"

# For deploying apps from a container
RUN R -e "devtools::install_github('rstudio/rsconnect')"


# Packages that need to be installed from GitHub
# For 087-crandash
RUN R -e "devtools::install_github('hadley/shinySignals')"
RUN R -e "devtools::install_github('jcheng5/bubbles')"

# Install latest shiny from GitHub
RUN R -e "devtools::install_github('rstudio/shiny')"





####### personnalisation :
## mettre en francais sinon pb d encodage
RUN locale-gen fr_FR.UTF-8
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR

## retire les apps par défaut
RUN rm -R /srv/shiny-server/
RUN mkdir /srv/shiny-server/

## transfert du dossier de la V1 de l'application
COPY V1 /srv/shiny-server/V1

## lib necessaire pour installer le paquet R rgdal
RUN apt-get install libgdal1-dev libproj-dev -y

# Autodetect packages needed for the examples (will install from CRAN)
RUN R -e "install.packages(packrat:::dirDependencies('/srv/shiny-server'))"

# il ne détecte pas le paquet rgeos ?! : installation manuelle
RUN R -e "install.packages('rgeos')"
