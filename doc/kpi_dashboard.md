# KPI Dashboard Film

Dokumen ini menjelaskan Key Performance Indicators (KPI) yang digunakan dalam dashboard film. KPI ini membantu pengguna memahami kondisi data film serta memberikan insight mengenai tren dan kualitas film dalam dataset.

---

# 1. Total Film

KPI ini menunjukkan jumlah total film yang tersedia dalam database.

Nilai ini dihitung dari seluruh data film yang tersimpan pada tabel `films`.

Query yang digunakan:

SELECT COUNT(*) AS total_film
FROM films;

Insight yang diperoleh:
- Menunjukkan jumlah film yang tersedia dalam sistem
- Memberikan gambaran skala data yang digunakan dalam analisis

---

# 2. Rata-rata Rating Film

KPI ini menunjukkan nilai rata-rata rating film berdasarkan data rating IMDb.

Nilai ini dihitung dari kolom `rating_imdb` pada tabel `films`.

Query yang digunakan:

SELECT AVG(rating_imdb) AS avg_rating
FROM films;

Insight yang diperoleh:
- Menunjukkan kualitas film secara umum berdasarkan rating IMDb
- Memberikan gambaran apakah mayoritas film memiliki rating tinggi atau rendah

---

# 3. Genre Terpopuler

KPI ini menunjukkan genre film yang paling banyak muncul dalam dataset.

Karena satu film dapat memiliki lebih dari satu genre, perhitungan dilakukan melalui tabel relasi `film_genres` dan tabel master `genres`.

Query yang digunakan:

SELECT g.genre_name, COUNT(*) AS total_film
FROM film_genres fg
JOIN genres g ON fg.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY total_film DESC;

Insight yang diperoleh:
- Mengetahui genre yang paling dominan dalam dataset
- Membantu memahami kecenderungan kategori film yang paling sering muncul

---

# 4. Tren Produksi Film per Tahun

KPI ini menunjukkan jumlah film yang dirilis setiap tahun.

Analisis ini membantu memahami perkembangan produksi film dari waktu ke waktu.

Query yang digunakan:

SELECT YEAR(release_date) AS tahun, COUNT(*) AS jumlah_film
FROM films
GROUP BY YEAR(release_date)
ORDER BY tahun;

Insight yang diperoleh:
- Mengetahui tahun dengan jumlah rilis film terbanyak
- Mengidentifikasi pola pertumbuhan atau penurunan jumlah film

---

# 5. Top Film Berdasarkan Rating IMDb

KPI ini menampilkan film dengan rating IMDb tertinggi.

Film dengan nilai `rating_imdb` tertinggi dianggap sebagai film dengan performa terbaik berdasarkan data yang tersedia.

Query yang digunakan:

SELECT title, rating_imdb
FROM films
ORDER BY rating_imdb DESC
LIMIT 5;

Insight yang diperoleh:
- Mengetahui film dengan rating tertinggi
- Membantu pengguna menemukan rekomendasi film terbaik

---

# Kesimpulan

KPI yang digunakan dalam dashboard ini membantu pengguna memahami berbagai aspek penting dalam data film, seperti jumlah film, kualitas film berdasarkan rating IMDb, genre yang dominan, tren produksi film, serta film dengan rating tertinggi.

Melalui KPI ini, dashboard dapat memberikan insight yang lebih jelas dan membantu pengguna dalam mengeksplorasi data film secara interaktif.
