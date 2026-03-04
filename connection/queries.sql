-- ==================================================
-- QUERY DASHBOARD FINAL (Revisi 3NF)
-- ==================================================

-- 1 & 2. KPI
SELECT 
  COUNT(imdb_id) AS Total_Film,
  ROUND(AVG(rating_imdb), 2) AS Rata_Rata_Rating_Global
FROM films;

-- 3 & 4. Analisis Genre (3NF)
SELECT g.genre_name AS genre
FROM film_genres fg
JOIN genres g ON fg.genre_id = g.genre_id;

-- 5. Top 5 Film Terbaik (min. 100 review)
SELECT 
  f.title AS Judul_Film, 
  f.rating_imdb AS Rating_IMDb, 
  COUNT(r.review_id) AS Jumlah_Review
FROM films f
JOIN reviews r ON f.imdb_id = r.imdb_id
GROUP BY f.imdb_id, f.title, f.rating_imdb
HAVING COUNT(r.review_id) >= 100
ORDER BY f.rating_imdb DESC
LIMIT 5;

-- 6 & 7. Analisis Sinopsis
SELECT storyline FROM films WHERE storyline IS NOT NULL;

-- 8. Distribusi Rating
SELECT rating_imdb AS rating FROM films WHERE rating_imdb IS NOT NULL;

-- 9. Distribusi Tahun Rilis
SELECT 
  YEAR(STR_TO_DATE(release_date, '%Y-%m-%d')) AS tahun_rilis,
  COUNT(imdb_id) AS jumlah_film
FROM films
WHERE release_date IS NOT NULL AND release_date <> ''
GROUP BY tahun_rilis
ORDER BY tahun_rilis ASC;

-- 10. Klasifikasi Usia Penonton
SELECT 
  CASE 
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 17 THEN 'Anak-anak (<17)'
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 17 AND 25 THEN 'Remaja (17-25)'
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 26 AND 40 THEN 'Dewasa Muda (26-40)'
    ELSE 'Dewasa (>40)'
  END AS kategori_usia,
  COUNT(username) AS jumlah_user
FROM users
WHERE date_of_birth IS NOT NULL
GROUP BY kategori_usia;

-- 11. Durasi vs Rating
SELECT duration_min AS duration, rating_imdb AS rating 
FROM films 
WHERE duration_min > 0 AND rating_imdb IS NOT NULL;

-- 12. Top 10 Kota User
SELECT city_origin, COUNT(username) AS jumlah_user
FROM users
GROUP BY city_origin
ORDER BY jumlah_user DESC
LIMIT 10;
