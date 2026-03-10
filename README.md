![Header Dashboard Film](images/Header%20Dashboard%20Film.png)

<h1 align="center">🎬 <b>Selamat Datang di Dashboard Film!</b> 🚀🍿</h1>

<h2 align="center"><i>"Explore Movies Through Data"</i></h2>

---

## 📑 Menu

- [📌 Informasi](#-informasi)
- [📋 Tentang Project](#-tentang-project)
- [💾 Skema Basis Data](#-skema-basis-data)
- [🔗 ERD](#-erd)
- [📜 Dokumentasi Analisis](#-dokumentasi-analisis)
- [📂 Struktur Folder](#-struktur-folder)
- [🛠 Teknologi yang Digunakan](#-teknologi-yang-digunakan)
- [👥 Tim Pengembang](#-tim-pengembang)

---

## 📌 Informasi

**Dashboard Film** adalah platform analisis data film berbasis **R Shiny** yang dirancang untuk membantu pengguna mengeksplorasi informasi film melalui visualisasi data interaktif.

Dashboard ini memungkinkan pengguna untuk:

- melihat jumlah film dalam database
- melihat rata-rata rating film
- menemukan genre yang paling dominan
- menganalisis tren produksi film berdasarkan tahun rilis
- mengeksplorasi film dengan rating tertinggi
- membaca dokumentasi struktur database dan analisis data

---

## 📋 Tentang Project

Project ini dibuat sebagai bagian dari praktikum **Pemrosesan Data Besar**.

Tujuan utama project ini adalah:

1. Merancang database relasional untuk dataset film
2. Melakukan normalisasi database hingga **Third Normal Form (3NF)**
3. Mengembangkan dashboard interaktif menggunakan **R Shiny**
4. Menyediakan dokumentasi analisis dan struktur database yang mendukung pengambilan insight dari data film

Database yang digunakan mencakup beberapa entitas utama seperti:

- `films`
- `users`
- `reviews`
- `actors`
- `directors`
- `genres`
- `production_companies`

Relasi many-to-many direpresentasikan menggunakan tabel penghubung seperti:

- `film_actors`
- `film_directors`
- `film_genres`
- `film_production_companies`

---

## 💾 Skema Basis Data

Database dibangun menggunakan **MySQL** dengan nama basis data:

`db_bioskop`

Contoh pembuatan database:

```sql
CREATE DATABASE IF NOT EXISTS db_bioskop;
USE db_bioskop;
```

Contoh pembuatan tabel `films`:

```sql
CREATE TABLE films (
  imdb_id VARCHAR(20) PRIMARY KEY,
  title VARCHAR(255),
  rating_imdb DOUBLE,
  rating_count INT,
  storyline TEXT,
  certificates TEXT,
  release_date DATE,
  duration_min INT,
  imdb_url_film TEXT,
  url_poster TEXT
);
```

Struktur lengkap tabel dapat dilihat pada file:

`connection/ddl.sql`

---

## 🔗 ERD

ERD (*Entity Relationship Diagram*) menjelaskan hubungan antar entitas dalam database Dashboard Film.

File ERD tersedia pada folder:

`doc/ERD.png`

Relasi utama dalam database ini meliputi:

| Hubungan | Penjelasan |
|---|---|
| Film → Review (1:N) | Satu film dapat memiliki banyak review |
| User → Review (1:N) | Satu user dapat memberikan banyak review |
| Film → Actor (M:N) | Satu film dapat memiliki banyak aktor |
| Film → Director (M:N) | Satu film dapat memiliki lebih dari satu sutradara |
| Film → Genre (M:N) | Satu film dapat memiliki lebih dari satu genre |
| Film → Production Company (M:N) | Satu film dapat diproduksi oleh lebih dari satu perusahaan |

---

## 📜 Dokumentasi Analisis

Dokumentasi yang mendukung project ini tersedia pada folder `doc/`, yaitu:

- `pembahasan.md` → pembahasan umum project Dashboard Film
- `data_dictionary.md` → penjelasan struktur tabel dan atribut database
- `normalisasi_database.md` → penjelasan proses normalisasi hingga 3NF
- `analisis_dashboard.md` → pembahasan KPI dan analisis dashboard
- `kpi_dashboard.md` → definisi KPI utama yang digunakan dalam dashboard

Dokumentasi ini dibuat untuk memastikan bahwa struktur database, analisis, dan dashboard saling konsisten.

---

## 📂 Struktur Folder

```text
Dashboard-Film/
│
├── app/                         # Kode aplikasi dashboard R Shiny
│   ├── app.R
│   ├── ui.R
│   └── server.R
│
├── connection/                  # Koneksi database dan query SQL
│   ├── db_connection.R
│   ├── ddl.sql
│   └── queries.sql
│
├── etl/                         # Proses ETL data
│   ├── 01_load_raw_to_db.R
│   ├── 02_etl_clean_to_csv.R
│   └── 03_load_processed_to_db.R
│
├── data/
│   ├── raw/                     # Data mentah
│   └── clean/                   # Data hasil pembersihan
│
├── doc/                         # Dokumentasi project
│   ├── ERD.png
│   ├── analisis_dashboard.md
│   ├── data_dictionary.md
│   ├── kpi_dashboard.md
│   ├── normalisasi_database.md
│   └── pembahasan.md
│
├── images/                      # Gambar pendukung project
│
└── README.md
```

---

## 🛠 Teknologi yang Digunakan

- **R Shiny** – framework untuk membangun dashboard interaktif
- **MySQL** – sistem manajemen basis data
- **DBI / RMySQL** – koneksi database dari R
- **tidyverse** – manipulasi data
- **ggplot2** – visualisasi data
- **Plotly** – grafik interaktif

---

## 👥 Tim Pengembang

- **Database Manager**  
  Bertanggung jawab dalam perancangan struktur database, DDL, dan pengelolaan integritas data.

- **Backend Developer**  
  Bertanggung jawab dalam integrasi query database dengan dashboard serta logika server.

- **Frontend Developer**  
  Bertanggung jawab dalam membangun tampilan dashboard yang interaktif dan mudah digunakan.

- **Data Analyst**  
  Bertanggung jawab dalam dokumentasi analisis, pembahasan database, definisi KPI, serta validasi konsistensi antara dashboard dan database.

---

## 📜 Lisensi

Project ini dibuat sebagai tugas praktikum mata kuliah **Pemrosesan Data Besar**.
