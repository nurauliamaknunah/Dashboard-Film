-- ==================================================
-- DDL Database Film (Revisi 3NF)
-- ==================================================

DROP TABLE IF EXISTS film_genres;
DROP TABLE IF EXISTS film_actors;
DROP TABLE IF EXISTS film_directors;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS actors;
DROP TABLE IF EXISTS directors;
DROP TABLE IF EXISTS films;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  username VARCHAR(255) PRIMARY KEY,
  city_origin VARCHAR(100),
  date_of_birth DATE
) ENGINE=InnoDB;

CREATE TABLE films (
  imdb_id VARCHAR(50) PRIMARY KEY,
  title VARCHAR(255),
  duration_min INT,
  release_date DATE,
  rating_imdb DECIMAL(3,1),
  rating_count INT,
  storyline TEXT,
  certificates TEXT,
  production_companies TEXT,
  url_poster TEXT,
  imdb_url_film TEXT
) ENGINE=InnoDB;

CREATE TABLE reviews (
  review_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  imdb_id VARCHAR(50) NOT NULL,
  username VARCHAR(255) NOT NULL,
  imdb_url_review TEXT,
  review_date DATE,
  review_summary VARCHAR(255),
  review_content TEXT,
  rating_user DECIMAL(3,1),
  CONSTRAINT fk_reviews_film FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
  CONSTRAINT fk_reviews_user FOREIGN KEY (username) REFERENCES users(username),
  UNIQUE KEY uq_review_nodup (imdb_id, username, review_date, review_summary)
) ENGINE=InnoDB;

CREATE TABLE actors (
  actor_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  actor_name VARCHAR(255) NOT NULL,
  UNIQUE KEY uq_actor_name (actor_name)
) ENGINE=InnoDB;

CREATE TABLE directors (
  director_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  director_name VARCHAR(255) NOT NULL,
  UNIQUE KEY uq_director_name (director_name)
) ENGINE=InnoDB;

CREATE TABLE genres (
  genre_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  genre_name VARCHAR(100) NOT NULL,
  UNIQUE KEY uq_genre_name (genre_name)
) ENGINE=InnoDB;

CREATE TABLE film_actors (
  imdb_id VARCHAR(50) NOT NULL,
  actor_id BIGINT NOT NULL,
  PRIMARY KEY (imdb_id, actor_id),
  CONSTRAINT fk_fa_film FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
  CONSTRAINT fk_fa_actor FOREIGN KEY (actor_id) REFERENCES actors(actor_id)
) ENGINE=InnoDB;

CREATE TABLE film_directors (
  imdb_id VARCHAR(50) NOT NULL,
  director_id BIGINT NOT NULL,
  PRIMARY KEY (imdb_id, director_id),
  CONSTRAINT fk_fd_film FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
  CONSTRAINT fk_fd_director FOREIGN KEY (director_id) REFERENCES directors(director_id)
) ENGINE=InnoDB;

CREATE TABLE film_genres (
  imdb_id VARCHAR(50) NOT NULL,
  genre_id BIGINT NOT NULL,
  PRIMARY KEY (imdb_id, genre_id),
  CONSTRAINT fk_fg_film FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
  CONSTRAINT fk_fg_genre FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
) ENGINE=InnoDB;

CREATE INDEX idx_reviews_imdb ON reviews(imdb_id);
CREATE INDEX idx_reviews_user ON reviews(username);
CREATE INDEX idx_films_release ON films(release_date);
