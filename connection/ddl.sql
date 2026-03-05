-- ==================================================
-- DDL Database Film (Revisi 3NF)
-- ==================================================

CREATE DATABASE IF NOT EXISTS db_bioskop;
USE db_bioskop;

-- USERS
CREATE TABLE users (
    username VARCHAR(100) PRIMARY KEY,
    date_of_birth DATE,
    city_origin VARCHAR(100)
);

-- FILMS
CREATE TABLE films (
    imdb_id VARCHAR(20) PRIMARY KEY,
    title VARCHAR(255),
    rating_imdb FLOAT,
    rating_count INT,
    storyline TEXT,
    certificates TEXT,
    release_date DATE,
    duration_min INT,
    imdb_url_film TEXT,
    url_poster TEXT
);

-- REVIEWS
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    imdb_id VARCHAR(20),
    username VARCHAR(100),
    imdb_url_review TEXT,
    review_date DATE,
    review_summary TEXT,
    review_content TEXT,
    FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
    FOREIGN KEY (username) REFERENCES users(username)
);

-- ACTORS
CREATE TABLE actors (
    actor_id INT AUTO_INCREMENT PRIMARY KEY,
    actor_name VARCHAR(255) UNIQUE
);

-- DIRECTORS
CREATE TABLE directors (
    director_id INT AUTO_INCREMENT PRIMARY KEY,
    director_name VARCHAR(255) UNIQUE
);

-- GENRES
CREATE TABLE genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(100) UNIQUE
);

-- PRODUCTION COMPANIES
CREATE TABLE production_companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(255) UNIQUE
);

-- RELATION TABLES

CREATE TABLE film_actors (
    imdb_id VARCHAR(20),
    actor_id INT,
    PRIMARY KEY (imdb_id, actor_id),
    FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
    FOREIGN KEY (actor_id) REFERENCES actors(actor_id)
);

CREATE TABLE film_directors (
    imdb_id VARCHAR(20),
    director_id INT,
    PRIMARY KEY (imdb_id, director_id),
    FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
    FOREIGN KEY (director_id) REFERENCES directors(director_id)
);

CREATE TABLE film_genres (
    imdb_id VARCHAR(20),
    genre_id INT,
    PRIMARY KEY (imdb_id, genre_id),
    FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

CREATE TABLE film_production_companies (
    imdb_id VARCHAR(20),
    company_id INT,
    PRIMARY KEY (imdb_id, company_id),
    FOREIGN KEY (imdb_id) REFERENCES films(imdb_id),
    FOREIGN KEY (company_id) REFERENCES production_companies(company_id)
);
