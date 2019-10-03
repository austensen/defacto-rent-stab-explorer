# Defacto Rent Stabilized Properties Explorer

This app is designed to help identify properties in Brooklyn that could potentially be "defacto rent stabilized", and provide useful information about the properties from public data for exploration and download. 

This site is built on top of the critical work done by [@aepyornis](https://github.com/aepyornis), and other members of the [Housing Data Coalition](https://www.housingdatanyc.org/), on the [NYC-DB](https://github.com/nycdb/nycdb) project. NYC-DB is used to cleanly extract, sanitize, and load various NYC housing datasets into a PostgreSQL instance.

**This project is currently in active development!**


## Setup

This app is built using R's [Shiny](https://shiny.rstudio.com/) package and uses a PostgreSQL database created by [NYC-DB](https://github.com/nycdb/nycdb). 

To run this app locally, with or without Docker, you'll need to create your own instance of [NYC-DB](https://github.com/nycdb/nycdb).

Once you have NYC-DB set up, you'll need to execute [`sql/defacto_bk_bbl_details.sql`](sql/defacto_bk_bbl_details.sql) to create a materialized view that provides the data for the app. If you also want the data for the app to update as the underlying NYC-DB table change you can also execute [`sql/refresh_triggers.sql`](sql/refresh_triggers.sql). From the top level of this repo, you can run these scripts with the following command (filling in your NYC-DB instance's hostname and username).

```
psql -h hostname -U user -d nycdb -f sql/defacto_bk_bbl_details.sql
```

You will also need to edit the file [`config_sample.yaml`](config_sample.yaml) to fill in these credentials for your local NYC-DB instance, then rename the file to `config.yaml`. 

From this point on there are two options for getting the app running locally:


### Non-Docker Option

First, you need to download and install [R](https://cloud.r-project.org/).

Then, from the top level of this repo, run the following command to install the required R packages and launch the app.  

```
RScript run-app.R
```

Now to view the app you can visit http://localhost:80/ in your browser.


### Docker Option

To allow your local NYC-DB database to be reached from the app inside the docker container you'll need to edit the PostgreSQL configuration file `postgresql.conf` to change the line `listen_addresses='localhost'` to `listen_addresses='*'`. You can locate this file with the following command:

```
psql -U postgres -c 'SHOW config_file'
```

Finally, you can [install Docker](https://www.docker.com/get-started) and run the following commands from the top level of this repo.

```
docker-compose build
docker-compose up
```

Now to view the app you can visit http://localhost:80/ in your browser.

#### Logs

For developing the app you can access To access these logs, while the container is running, run `docker exec -it shiny bash` and then `ls /var/log/shiny-server` to see the available logs. To copy these logs to the host system for inspection, while the container is running, you can use, for example, `docker cp shiny:/var/log/shiny-server ./logs_for_inspection`.
