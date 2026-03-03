# =========================================================
# db_setup.R - Setup Database Film (Revisi 3NF)
# Kelompok 5 - Role: Database Manager
# DB: MariaDB/MySQL (DBngin)
# =========================================================

library(DBI)
library(RMariaDB)

# -------------------- CONFIG --------------------
csv_path <- "data/raw/Dataset Film Raw.csv"  

db_config <- list(
  host = "127.0.0.1",
  port = 3307,
  user = "root",
  password = "",
  dbname = "db_bioskop"
)

# -------------------- CONNECT --------------------
con <- dbConnect(MariaDB(),
                 user = db_config$user,
                 password = db_config$password,
                 host = db_config$host,
                 port = db_config$port)

on.exit(try(dbDisconnect(con), silent = TRUE), add = TRUE)

dbExecute(con, paste("CREATE DATABASE IF NOT EXISTS", db_config$dbname))
dbExecute(con, paste("USE", db_config$dbname))

cat("Connected OK\n")
cat("Next: run DDL from connection/ddl.sql (or run via RMarkdown)\n")
