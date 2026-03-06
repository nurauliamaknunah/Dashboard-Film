raw <- read.csv("data/raw/Dataset Film Raw.csv", stringsAsFactors = FALSE)

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

clean_list <- function(x) {
  x <- as.character(x)
  x[is.na(x)] <- ""
  x <- gsub("\\[|\\]|'|\"", "", x)
  x <- trimws(x)
  x
}

remove_number_prefix <- function(x) {
  x <- gsub("^\\d+\\s*", "", x)
  trimws(x)
}

split_items <- function(x) {
  x <- clean_list(x)
  unlist(strsplit(x, ","))
}

# USERS
users <- unique(raw[, c("username", "date_of_birth", "city_origin")])
users <- users[users$username != "" & !is.na(users$username), ]

# FILMS
films <- unique(raw[, c(
  "imdb_id", "title", "rating", "rating_count", "storyline",
  "certificates", "release_date", "duration",
  "imdb_url_film", "url_poster"
)])
names(films)[names(films) == "rating"] <- "rating_imdb"
names(films)[names(films) == "duration"] <- "duration_min"

# REVIEWS
reviews <- unique(raw[, c(
  "imdb_id", "username", "imdb_url_review",
  "review_date", "review_summary", "review_content"
)])
reviews <- reviews[reviews$imdb_id != "" & reviews$username != "", ]
reviews$review_id <- seq_len(nrow(reviews))
reviews <- reviews[, c(
  "review_id", "imdb_id", "username", "imdb_url_review",
  "review_date", "review_summary", "review_content"
)]

# ACTORS
actors_vec <- unique(trimws(unlist(lapply(raw$cast, split_items))))
actors_vec <- remove_number_prefix(actors_vec)
actors_vec <- actors_vec[actors_vec != ""]
actors <- data.frame(
  actor_id = seq_along(unique(actors_vec)),
  actor_name = sort(unique(actors_vec)),
  stringsAsFactors = FALSE
)

# DIRECTORS
directors_vec <- unique(trimws(unlist(lapply(raw$director, split_items))))
directors_vec <- remove_number_prefix(directors_vec)
directors_vec <- directors_vec[directors_vec != ""]
directors <- data.frame(
  director_id = seq_along(unique(directors_vec)),
  director_name = sort(unique(directors_vec)),
  stringsAsFactors = FALSE
)

# GENRES
genres_vec <- unique(trimws(unlist(lapply(raw$genre, split_items))))
genres_vec <- genres_vec[genres_vec != ""]
genres <- data.frame(
  genre_id = seq_along(unique(genres_vec)),
  genre_name = sort(unique(genres_vec)),
  stringsAsFactors = FALSE
)

# PRODUCTION COMPANIES
companies_vec <- unique(trimws(unlist(lapply(raw$production_companies, split_items))))
companies_vec <- remove_number_prefix(companies_vec)
companies_vec <- companies_vec[companies_vec != "" & tolower(companies_vec) != "production company"]
production_companies <- data.frame(
  company_id = seq_along(unique(companies_vec)),
  company_name = sort(unique(companies_vec)),
  stringsAsFactors = FALSE
)

# Junction helper
make_junction <- function(raw_ids, raw_col, master_df, name_col, id_col) {
  out <- data.frame()
  for (i in seq_along(raw_ids)) {
    items <- trimws(split_items(raw_col[i]))
    items <- remove_number_prefix(items)
    items <- items[items != ""]
    if (length(items) == 0) next
    ids <- master_df[[id_col]][match(items, master_df[[name_col]])]
    temp <- data.frame(imdb_id = raw_ids[i], id = ids, stringsAsFactors = FALSE)
    out <- rbind(out, temp)
  }
  unique(out)
}

film_actors <- make_junction(raw$imdb_id, raw$cast, actors, "actor_name", "actor_id")
names(film_actors)[2] <- "actor_id"

film_directors <- make_junction(raw$imdb_id, raw$director, directors, "director_name", "director_id")
names(film_directors)[2] <- "director_id"

film_genres <- make_junction(raw$imdb_id, raw$genre, genres, "genre_name", "genre_id")
names(film_genres)[2] <- "genre_id"

film_production_companies <- make_junction(raw$imdb_id, raw$production_companies, production_companies, "company_name", "company_id")
names(film_production_companies)[2] <- "company_id"

write.csv(users, "data/processed/users.csv", row.names = FALSE)
write.csv(films, "data/processed/films.csv", row.names = FALSE)
write.csv(reviews, "data/processed/reviews.csv", row.names = FALSE)
write.csv(actors, "data/processed/actors.csv", row.names = FALSE)
write.csv(directors, "data/processed/directors.csv", row.names = FALSE)
write.csv(genres, "data/processed/genres.csv", row.names = FALSE)
write.csv(production_companies, "data/processed/production_companies.csv", row.names = FALSE)
write.csv(film_actors, "data/processed/film_actors.csv", row.names = FALSE)
write.csv(film_directors, "data/processed/film_directors.csv", row.names = FALSE)
write.csv(film_genres, "data/processed/film_genres.csv", row.names = FALSE)
write.csv(film_production_companies, "data/processed/film_production_companies.csv", row.names = FALSE)
