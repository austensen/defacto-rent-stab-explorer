#!/usr/bin/Rscript

# Install R packages that are required
pkgs <- c('shiny', 'DBI', 'pool', 'DT', 'config')
new_pkgs <- pkgs[!(pkgs %in% installed.packages()[,'Package'])]
if(length(new_pkgs)) install.packages(new_pkgs, repos='http://cran.rstudio.com/')

## Run Shiny app
shiny::runApp('app', 3838)
