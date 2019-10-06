library(pool) # Database Connection Pooling
library(config) # Manage configuration values across multiple environments
library(glue) # Interpreted string literals
library(DT) # JS DataTables
library(DBI) # Database interface
library(markdown) # Render markdown


# Connect to NYCDB --------------------------------------------------------

nycdb <- get("nycdbconnection")

con <- dbPool(
  drv = RPostgres::Postgres(),
  dbname = nycdb$dbname,
  host = nycdb$host,
  user = nycdb$user,
  password = nycdb$password,
  port = nycdb$port
)


# Load Modules ------------------------------------------------------------

source("tool_tips.R")
source("details_module.R")
