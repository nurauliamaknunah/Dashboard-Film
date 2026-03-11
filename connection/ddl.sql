CREATE DATABASE IF NOT EXISTS db_bioskop;
USE db_bioskop;

DROP TABLE IF EXISTS film_production_companies;
DROP TABLE IF EXISTS film_genres;
DROP TABLE IF EXISTS film_directors;
DROP TABLE IF EXISTS film_actors;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS production_companies;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS directors;
DROP TABLE IF EXISTS actors;
DROP TABLE IF EXISTS films;
DROP TABLE IF EXISTS users;

-- =========================
-- 1. MASTER TABLES
-- =========================

CREATE TABLE users (
    username VARCHAR(100) PRIMARY KEY,
    date_of_birth DATE NULL,
    city_origin VARCHAR(100) NULL
) ENGINE=InnoDB;

CREATE TABLE films (
    imdb_id VARCHAR(20) PRIMARY KEY,
    title VARCHAR(255) NULL,
    rating_imdb DOUBLE NULL,
    rating_count INT NULL,
    storyline TEXT NULL,
    certificates TEXT NULL,
    release_date DATE NULL,
    duration_min INT NULL,
    imdb_url_film TEXT NULL,
    url_poster TEXT NULL
) ENGINE=InnoDB;

CREATE TABLE actors (
    actor_id BIGINT PRIMARY KEY,
    actor_name VARCHAR(255) NOT NULL,
    UNIQUE KEY uq_actor_name (actor_name)
) ENGINE=InnoDB;

CREATE TABLE directors (
    director_id BIGINT PRIMARY KEY,
    director_name VARCHAR(255) NOT NULL,
    UNIQUE KEY uq_director_name (director_name)
) ENGINE=InnoDB;

CREATE TABLE genres (
    genre_id BIGINT PRIMARY KEY,
    genre_name VARCHAR(255) NOT NULL,
    UNIQUE KEY uq_genre_name (genre_name)
) ENGINE=InnoDB;

CREATE TABLE production_companies (
    company_id BIGINT PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    UNIQUE KEY uq_company_name (company_name)
) ENGINE=InnoDB;

-- =========================
-- 2. TRANSACTION TABLE
-- =========================

CREATE TABLE reviews (
    review_id BIGINT PRIMARY KEY,
    imdb_id VARCHAR(20) NOT NULL,
    username VARCHAR(100) NOT NULL,
    imdb_url_review TEXT NULL,
    review_date DATE NULL,
    review_summary TEXT NULL,
    review_content TEXT NULL,
    CONSTRAINT fk_reviews_film
        FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
    CONSTRAINT fk_reviews_user
        FOREIGN KEY (username) REFERENCES users(username),
    UNIQUE KEY uq_review_nodup (imdb_id, username, review_date, review_summary(100))
) ENGINE=InnoDB;

-- =========================
-- 3. JUNCTION TABLES
-- =========================

CREATE TABLE film_actors (
    imdb_id VARCHAR(20) NOT NULL,
    actor_id BIGINT NOT NULL,
    PRIMARY KEY (imdb_id, actor_id),
    CONSTRAINT fk_film_actors_film
        FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
    CONSTRAINT fk_film_actors_actor
        FOREIGN KEY (actor_id) REFERENCES actors(actor_id)
) ENGINE=InnoDB;

CREATE TABLE film_directors (
    imdb_id VARCHAR(20) NOT NULL,
    director_id BIGINT NOT NULL,
    PRIMARY KEY (imdb_id, director_id),
    CONSTRAINT fk_film_directors_film
        FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
    CONSTRAINT fk_film_directors_director
        FOREIGN KEY (director_id) REFERENCES directors(director_id)
) ENGINE=InnoDB;

CREATE TABLE film_genres (
    imdb_id VARCHAR(20) NOT NULL,
    genre_id BIGINT NOT NULL,
    PRIMARY KEY (imdb_id, genre_id),
    CONSTRAINT fk_film_genres_film
        FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
    CONSTRAINT fk_film_genres_genre
        FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
) ENGINE=InnoDB;

CREATE TABLE film_production_companies (
    imdb_id VARCHAR(20) NOT NULL,
    company_id BIGINT NOT NULL,
    PRIMARY KEY (imdb_id, company_id),
    CONSTRAINT fk_film_companies_film
        FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
    CONSTRAINT fk_film_companies_company
        FOREIGN KEY (company_id) REFERENCES production_companies(company_id)
) ENGINE=InnoDB;
