source("connection/db_connection.R")

raw <- read.csv("data/raw/Dataset Film Raw.csv", stringsAsFactors = FALSE)

dbWriteTable(con, "raw_film_dataset", raw, overwrite = TRUE, row.names = FALSE)

dbDisconnect(con)
