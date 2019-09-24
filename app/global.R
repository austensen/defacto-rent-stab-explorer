library(pool)
library(config)

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
