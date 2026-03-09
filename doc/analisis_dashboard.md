# Analisis Dashboard Film

Dokumen ini menjelaskan analisis data yang ditampilkan pada dashboard film.

Dashboard dibuat untuk membantu pengguna memahami pola data film melalui visualisasi interaktif menggunakan R Shiny.

---

# 1. Total Film

Indikator ini menampilkan jumlah total film yang terdapat dalam database.

Nilai ini dihitung menggunakan query SQL berikut:

SELECT COUNT(*) FROM films;

Tujuan indikator ini adalah memberikan gambaran umum mengenai jumlah data film yang tersedia dalam sistem.

---

# 2. Rata-rata Rating Film

Indikator ini menunjukkan rata-rata rating film berdasarkan ulasan pengguna.

Query yang digunakan:

SELECT AVG(rating) FROM reviews;

Nilai rata-rata rating membantu menggambarkan kualitas film secara umum berdasarkan penilaian pengguna.

---

# 3. Genre Terpopuler

Analisis ini menampilkan genre dengan jumlah film terbanyak.

Query yang digunakan:

SELECT g.genre_name, COUNT(*) AS total_film
FROM film_genres fg
JOIN genres g ON fg.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY total_film DESC;

Visualisasi ini membantu pengguna mengetahui genre film yang paling banyak diproduksi atau paling populer dalam dataset.

---

# 4. Distribusi Rating Film

Distribusi rating film ditampilkan menggunakan grafik histogram.

Grafik ini menunjukkan bagaimana penyebaran nilai rating film dalam dataset.

Analisis ini membantu mengetahui:

- apakah mayoritas film memiliki rating tinggi
- apakah terdapat film dengan rating sangat rendah
- bagaimana pola distribusi kualitas film secara keseluruhan

---

# 5. Tren Produksi Film

Analisis ini menampilkan jumlah film yang dirilis setiap tahun.

Query yang digunakan:

SELECT YEAR(release_date) AS year, COUNT(*) AS total_film
FROM films
GROUP BY YEAR(release_date)
ORDER BY year;

Visualisasi tren produksi film membantu melihat perkembangan industri film dari waktu ke waktu.

---

# 6. Top Film Berdasarkan Rating

Dashboard juga menampilkan film dengan rating tertinggi.

Query yang digunakan:

SELECT title, AVG(rating) AS avg_rating
FROM reviews r
JOIN films f ON r.film_id = f.film_id
GROUP BY title
ORDER BY avg_rating DESC
LIMIT 5;

Analisis ini membantu pengguna menemukan film yang memiliki penilaian terbaik dari pengguna.

---

# 7. Hubungan Durasi Film dan Rating

Dashboard juga dapat menampilkan hubungan antara durasi film dan rating.

Visualisasi ini biasanya menggunakan scatter plot.

Analisis ini bertujuan untuk mengetahui apakah terdapat hubungan antara durasi film dan tingkat penilaian pengguna terhadap film tersebut.

---

# Kesimpulan Analisis

Berdasarkan analisis dashboard, pengguna dapat memperoleh informasi penting mengenai:

- jumlah film dalam database
- kualitas film berdasarkan rating pengguna
- genre film yang paling dominan
- perkembangan produksi film dari waktu ke waktu
- film dengan rating tertinggi

Visualisasi ini membantu pengguna memahami data film secara lebih mudah dan interaktif.
