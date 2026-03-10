# Data Dictionary

Dokumen ini menjelaskan struktur tabel pada database **db_bioskop** yang digunakan dalam project Dashboard Film.

---

# 1. Tabel users

Tabel ini menyimpan informasi pengguna yang memberikan ulasan film.

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| username | VARCHAR(100) | Primary key, username pengguna |
| date_of_birth | DATE | Tanggal lahir pengguna |
| city_origin | VARCHAR(100) | Kota asal pengguna |

---

# 2. Tabel films

Tabel ini menyimpan informasi utama film.

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| imdb_id | VARCHAR(20) | Primary key, ID unik film dari IMDb |
| title | VARCHAR(255) | Judul film |
| rating_imdb | DOUBLE | Rating film dari IMDb |
| rating_count | INT | Jumlah pemberi rating |
| storyline | TEXT | Ringkasan cerita film |
| certificates | TEXT | Klasifikasi atau sertifikat film |
| release_date | DATE | Tanggal rilis film |
| duration_min | INT | Durasi film dalam menit |
| imdb_url_film | TEXT | URL halaman film di IMDb |
| url_poster | TEXT | URL poster film |

---

# 3. Tabel actors

Tabel ini menyimpan daftar aktor.

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| actor_id | BIGINT | Primary key, ID unik aktor |
| actor_name | VARCHAR(255) | Nama aktor |

---

# 4. Tabel directors

Tabel ini menyimpan daftar sutradara.

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| director_id | BIGINT | Primary key, ID unik sutradara |
| director_name | VARCHAR(255) | Nama sutradara |

---

# 5. Tabel genres

Tabel ini menyimpan daftar genre film.

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| genre_id | BIGINT | Primary key, ID unik genre |
| genre_name | VARCHAR(255) | Nama genre |

---

# 6. Tabel production_companies

Tabel ini menyimpan daftar perusahaan produksi film.

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| company_id | BIGINT | Primary key, ID unik perusahaan produksi |
| company_name | VARCHAR(255) | Nama perusahaan produksi |

---

# 7. Tabel reviews

Tabel ini menyimpan ulasan pengguna terhadap film.

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| review_id | BIGINT | Primary key, ID unik review |
| imdb_id | VARCHAR(20) | Foreign key ke tabel films |
| username | VARCHAR(100) | Foreign key ke tabel users |
| imdb_url_review | TEXT | URL review pada IMDb |
| review_date | DATE | Tanggal review |
| review_summary | TEXT | Ringkasan singkat review |
| review_content | TEXT | Isi lengkap review |

---

# 8. Tabel film_actors

Tabel ini merupakan tabel relasi many-to-many antara film dan aktor.

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| imdb_id | VARCHAR(20) | Foreign key ke tabel films |
| actor_id | BIGINT | Foreign key ke tabel actors |

Primary key: `(imdb_id, actor_id)`

---

# 9. Tabel film_directors

Tabel ini merupakan tabel relasi many-to-many antara film dan sutradara.

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| imdb_id | VARCHAR(20) | Foreign key ke tabel films |
| director_id | BIGINT | Foreign key ke tabel directors |

Primary key: `(imdb_id, director_id)`

---

# 10. Tabel film_genres

Tabel ini merupakan tabel relasi many-to-many antara film dan genre.

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| imdb_id | VARCHAR(20) | Foreign key ke tabel films |
| genre_id | BIGINT | Foreign key ke tabel genres |

Primary key: `(imdb_id, genre_id)`

---

# 11. Tabel film_production_companies

Tabel ini merupakan tabel relasi many-to-many antara film dan perusahaan produksi.

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| imdb_id | VARCHAR(20) | Foreign key ke tabel films |
| company_id | BIGINT | Foreign key ke tabel production_companies |

Primary key: `(imdb_id, company_id)`
