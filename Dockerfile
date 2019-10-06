## Modified from https://github.com/rocker-org/shiny

FROM rocker/r-ver:3.6.1

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget

## RPostgres install fails without libpq-dev
RUN apt-get install -y libpq-dev

## Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    R -e "install.packages(c('shiny', 'DBI', 'pool', 'DT', 'config', 'RPostgres', 'markdown'), repos='$MRAN')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    chown shiny:shiny /var/lib/shiny-server

## Set Renviron for config package
RUN echo "R_CONFIG_ACTIVE='docker'" >> /usr/local/lib/R/etc/Renviron


EXPOSE 3838

## If you add a custom configuration file (shiny-server.conf) uncomment the line
## COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

COPY shiny-server.sh /usr/bin/shiny-server.sh

## Make sure all users have permission to execute this
RUN ["chmod", "a+x", "/usr/bin/shiny-server.sh"]

CMD ["/usr/bin/shiny-server.sh"]
