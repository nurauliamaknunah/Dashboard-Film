library(DBI)
library(RMariaDB)

con <- dbConnect(
  RMariaDB::MariaDB(),
  dbname = "db_bioskop",
  host = "127.0.0.1",
  port = 3307,
  user = "root",
  password = ""
)
