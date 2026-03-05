# =========================================================
# db_setup.R - Setup Database Film (Revisi 3NF)
# Kelompok 5 - Role: Database Manager
# DB: MariaDB/MySQL (DBngin)
# =========================================================

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

csv_path <- "data/raw/Dataset Film Raw.csv"

raw <- read.csv(csv_path, stringsAsFactors = FALSE)

clean_list <- function(x){
  x <- gsub("\\[|\\]|'|\"", "", x)
  trimws(x)
}

remove_number_prefix <- function(x){
  gsub("^\\d+\\s*", "", x)
}

# USERS
users <- unique(raw[,c("username","date_of_birth","city_origin")])
users <- users[users$username != "",]

# FILMS
films <- unique(raw[,c(
"imdb_id","title","rating","rating_count","storyline",
"certificates","release_date","duration",
"imdb_url_film","url_poster"
)])

names(films)[names(films)=="rating"] <- "rating_imdb"
names(films)[names(films)=="duration"] <- "duration_min"

# ACTORS
actors_list <- strsplit(clean_list(raw$cast), ",")
actors <- unique(trimws(unlist(actors_list)))
actors <- remove_number_prefix(actors)
actors <- actors[actors!=""]

actors_df <- data.frame(actor_name=actors)

# DIRECTORS
directors_list <- strsplit(clean_list(raw$director), ",")
directors <- unique(trimws(unlist(directors_list)))
directors <- remove_number_prefix(directors)
directors <- directors[directors!=""]

directors_df <- data.frame(director_name=directors)

# GENRES
genre_list <- strsplit(clean_list(raw$genre), ",")
genres <- unique(trimws(unlist(genre_list)))
genres <- genres[genres!=""]

genres_df <- data.frame(genre_name=genres)

# COMPANIES
company_list <- strsplit(clean_list(raw$production_companies), ",")
companies <- unique(trimws(unlist(company_list)))
companies <- remove_number_prefix(companies)
companies <- companies[companies!=""]

companies_df <- data.frame(company_name=companies)

dbWriteTable(con,"users",users,append=TRUE,row.names=FALSE)
dbWriteTable(con,"films",films,append=TRUE,row.names=FALSE)
dbWriteTable(con,"actors",actors_df,append=TRUE,row.names=FALSE)
dbWriteTable(con,"directors",directors_df,append=TRUE,row.names=FALSE)
dbWriteTable(con,"genres",genres_df,append=TRUE,row.names=FALSE)
dbWriteTable(con,"production_companies",companies_df,append=TRUE,row.names=FALSE)

dbDisconnect(con)
