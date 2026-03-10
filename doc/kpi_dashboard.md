# KPI Dashboard Film

Dokumen ini menjelaskan Key Performance Indicators (KPI) yang digunakan dalam dashboard film. KPI ini membantu pengguna memahami kondisi data film serta memberikan insight mengenai tren dan kualitas film dalam dataset.

---

# 1. Total Film

KPI ini menunjukkan jumlah total film yang tersedia dalam database.

Tujuan indikator ini adalah memberikan gambaran umum mengenai ukuran dataset yang digunakan dalam sistem dashboard.

Nilai ini dihitung dari seluruh data film yang tersimpan pada tabel films.

Query yang digunakan:

SELECT COUNT(*) FROM films;

Insight yang diperoleh:
- Menunjukkan jumlah film yang tersedia dalam sistem
- Memberikan gambaran skala data yang digunakan dalam analisis

---

# 2. Rata-rata Rating Film

KPI ini menunjukkan nilai rata-rata rating film berdasarkan ulasan yang diberikan oleh pengguna.

Nilai ini dihitung dari seluruh rating yang terdapat pada tabel reviews.

Query yang digunakan:

SELECT AVG(rating) FROM reviews;

Insight yang diperoleh:
- Menunjukkan kualitas film secara umum berdasarkan penilaian pengguna
- Memberikan gambaran apakah mayoritas film memiliki rating tinggi atau rendah

---

# 3. Genre Terpopuler

KPI ini menunjukkan genre film yang paling banyak muncul dalam dataset.

Genre dengan jumlah film terbanyak dianggap sebagai genre yang paling dominan atau populer.

Query yang digunakan:

SELECT genre, COUNT(*) AS total_film
FROM films
GROUP BY genre
ORDER BY total_film DESC;

Insight yang diperoleh:
- Mengetahui genre yang paling banyak diproduksi
- Membantu memahami preferensi pasar terhadap jenis film tertentu

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
- Mengetahui tahun dengan produksi film terbanyak
- Mengidentifikasi tren pertumbuhan atau penurunan produksi film

---

# 5. Top Film Berdasarkan Rating

KPI ini menampilkan film dengan rating tertinggi berdasarkan ulasan pengguna.

Film dengan rating rata-rata tertinggi dianggap sebagai film terbaik menurut pengguna.

Query yang digunakan:

SELECT title, AVG(rating) AS avg_rating
FROM reviews r
JOIN films f ON r.film_id = f.film_id
GROUP BY title
ORDER BY avg_rating DESC
LIMIT 5;

Insight yang diperoleh:
- Mengetahui film dengan kualitas terbaik menurut pengguna
- Membantu pengguna menemukan rekomendasi film dengan rating tinggi

---

# Kesimpulan

KPI yang digunakan dalam dashboard ini membantu pengguna memahami berbagai aspek penting dalam data film, seperti jumlah film, kualitas film berdasarkan rating, genre yang dominan, tren produksi film, serta film dengan rating tertinggi.

Melalui KPI ini, dashboard dapat memberikan insight yang lebih jelas dan membantu pengguna dalam mengeksplorasi data film secara interaktif.
