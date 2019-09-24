# Defacto Rent Stabilized Properties Explorer

This app is designed to help identify properties in Brooklyn that could potentially be "defacto rent stabilized", and provide useful information about the properties from public data for exploration and download. 

This site is built on top of the critical work done by [@aepyornis](https://github.com/aepyornis), and other members of the Housing Data Coalition, on the [nycdb](https://github.com/nycdb/nycdb) project. nycdb is used to cleanly extract, sanitize, and load various NYC housing datasets into a PostgreSQL instance.

**This project is currently in active development!**


## Setup

This app is built using R's [Shiny](https://shiny.rstudio.com/) package and uses a PostgreSQL database created by [nycdb](https://github.com/nycdb/nycdb). 

I have not yet dockerized the project, so for now you can follow these steps to get the app running locally. 


Download and install [R](https://cloud.r-project.org/).  

Create your own instance of [nycdb](https://github.com/nycdb/nycdb).  

Clone or download this repository.  

From the top level of this repo, run the following command (filling in your nycdb instance's hostname and username) to execute the SQL script that creates the Postgres materialized view that provides the data for the app.

```bash
psql -h hostname -U user -d nycdb -f sql/defacto_bk_bbl_details.sql
```

Edit the file `sample_config.yaml` to fill in the credentials for your local nycdb instance, then rename the file to `config.yaml`. 

From the top level of this repo, run the following command to install the required R packages and launch the app.  

```bash
RScript run-app.R
```

You can now visit your local version of the app at http://localhost:3838. 
