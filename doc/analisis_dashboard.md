# Analisis Dashboard Film

Dokumen ini menjelaskan analisis data yang ditampilkan pada dashboard film.

Dashboard dibuat untuk membantu pengguna memahami pola data film melalui visualisasi interaktif menggunakan R Shiny.

---

# 1. Total Film

Indikator ini menampilkan jumlah total film yang terdapat dalam database.

Nilai ini dihitung menggunakan query SQL berikut:

SELECT COUNT(*) AS total_film
FROM films;

Tujuan indikator ini adalah memberikan gambaran umum mengenai jumlah data film yang tersedia dalam sistem.

---

# 2. Rata-rata Rating Film

Indikator ini menunjukkan rata-rata rating film berdasarkan data rating IMDb.

Query yang digunakan:

SELECT AVG(rating_imdb) AS avg_rating
FROM films;

Nilai rata-rata rating membantu menggambarkan kualitas film secara umum berdasarkan data rating yang tersedia pada database.

---

# 3. Genre Terpopuler

Analisis ini menampilkan genre dengan jumlah film terbanyak.

Karena satu film dapat memiliki lebih dari satu genre, perhitungan dilakukan melalui tabel relasi `film_genres` dan tabel `genres`.

Query yang digunakan:

SELECT g.genre_name, COUNT(*) AS total_film
FROM film_genres fg
JOIN genres g ON fg.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY total_film DESC;

Visualisasi ini membantu pengguna mengetahui genre film yang paling dominan dalam dataset.

---

# 4. Distribusi Rating Film

Distribusi rating film ditampilkan menggunakan grafik histogram.

Grafik ini menunjukkan bagaimana penyebaran nilai `rating_imdb` dalam dataset.

Analisis ini membantu mengetahui:

- apakah mayoritas film memiliki rating tinggi
- apakah terdapat film dengan rating rendah
- bagaimana pola distribusi kualitas film secara keseluruhan

---

# 5. Tren Produksi Film

Analisis ini menampilkan jumlah film yang dirilis setiap tahun.

Query yang digunakan:

SELECT YEAR(release_date) AS year, COUNT(*) AS total_film
FROM films
GROUP BY YEAR(release_date)
ORDER BY year;

Visualisasi tren produksi film membantu melihat perkembangan jumlah film dari waktu ke waktu.

---

# 6. Top Film Berdasarkan Rating IMDb

Dashboard juga menampilkan film dengan rating IMDb tertinggi.

Query yang digunakan:

SELECT title, rating_imdb
FROM films
ORDER BY rating_imdb DESC
LIMIT 5;

Analisis ini membantu pengguna menemukan film dengan rating tertinggi berdasarkan data IMDb.

---

# 7. Hubungan Durasi Film dan Rating

Dashboard juga dapat menampilkan hubungan antara durasi film dan rating IMDb.

Visualisasi ini biasanya menggunakan scatter plot.

Analisis ini bertujuan untuk mengetahui apakah terdapat hubungan antara durasi film (`duration_min`) dan tingkat rating film (`rating_imdb`).

---

# Kesimpulan Analisis

Berdasarkan analisis dashboard, pengguna dapat memperoleh informasi penting mengenai:

- jumlah film dalam database
- kualitas film berdasarkan rating IMDb
- genre film yang paling dominan
- perkembangan produksi film dari waktu ke waktu
- film dengan rating tertinggi

Visualisasi ini membantu pengguna memahami data film secara lebih mudah dan interaktif.
