# Data Dictionary

Dokumen ini menjelaskan struktur tabel yang digunakan dalam database Dashboard Film.

Setiap tabel berisi informasi mengenai atribut, tipe data, dan deskripsi dari masing-masing kolom.

---

# 1. Tabel Films

Tabel ini menyimpan informasi utama mengenai film.

| Kolom | Tipe Data | Deskripsi |
|------|------|------|
| film_id | INT | Primary key untuk mengidentifikasi film |
| title | VARCHAR | Judul film |
| release_date | DATE | Tanggal rilis film |
| duration | INT | Durasi film dalam menit |
| imdb_id | VARCHAR | ID film pada database IMDb |
| storyline | TEXT | Ringkasan cerita film |

---

# 2. Tabel Users

Tabel ini menyimpan informasi pengguna yang memberikan ulasan film.

| Kolom | Tipe Data | Deskripsi |
|------|------|------|
| user_id | INT | Primary key untuk pengguna |
| username | VARCHAR | Nama pengguna |
| date_of_birth | DATE | Tanggal lahir pengguna |
| city_origin | VARCHAR | Kota asal pengguna |

---

# 3. Tabel Reviews

Tabel ini menyimpan ulasan dan rating film dari pengguna.

| Kolom | Tipe Data | Deskripsi |
|------|------|------|
| review_id | INT | Primary key untuk ulasan |
| film_id | INT | Foreign key yang mengacu ke tabel films |
| user_id | INT | Foreign key yang mengacu ke tabel users |
| rating | FLOAT | Nilai rating yang diberikan pengguna |
| review_text | TEXT | Isi ulasan film |
| review_date | DATE | Tanggal ulasan dibuat |

---

# 4. Tabel Actors

Tabel ini menyimpan daftar aktor yang bermain dalam film.

| Kolom | Tipe Data | Deskripsi |
|------|------|------|
| actor_id | INT | Primary key aktor |
| actor_name | VARCHAR | Nama aktor |

---

# 5. Tabel Directors

Tabel ini menyimpan informasi sutradara film.

| Kolom | Tipe Data | Deskripsi |
|------|------|------|
| director_id | INT | Primary key sutradara |
| director_name | VARCHAR | Nama sutradara |

---

# 6. Tabel Genres

Tabel ini menyimpan daftar genre film.

| Kolom | Tipe Data | Deskripsi |
|------|------|------|
| genre_id | INT | Primary key genre |
| genre_name | VARCHAR | Nama genre film |

---

# 7. Tabel Production Companies

Tabel ini menyimpan informasi perusahaan produksi film.

| Kolom | Tipe Data | Deskripsi |
|------|------|------|
| company_id | INT | Primary key perusahaan produksi |
| company_name | VARCHAR | Nama perusahaan produksi |

---

# 8. Tabel Film_Actors

Tabel ini merupakan tabel relasi many-to-many antara film dan aktor.

| Kolom | Tipe Data | Deskripsi |
|------|------|------|
| film_id | INT | Foreign key ke tabel films |
| actor_id | INT | Foreign key ke tabel actors |

---

# 9. Tabel Film_Directors

Tabel ini menyimpan relasi antara film dan sutradara.

| Kolom | Tipe Data | Deskripsi |
|------|------|------|
| film_id | INT | Foreign key ke tabel films |
| director_id | INT | Foreign key ke tabel directors |

---

# 10. Tabel Film_Genres

Tabel ini menyimpan relasi antara film dan genre.

| Kolom | Tipe Data | Deskripsi |
|------|------|------|
| film_id | INT | Foreign key ke tabel films |
| genre_id | INT | Foreign key ke tabel genres |

---

# 11. Tabel Film_Production_Companies

Tabel ini menyimpan relasi antara film dan perusahaan produksi.

| Kolom | Tipe Data | Deskripsi |
|------|------|------|
| film_id | INT | Foreign key ke tabel films |
| company_id | INT | Foreign key ke tabel production_companies |
