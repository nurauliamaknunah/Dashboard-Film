<img width="4688" height="1563" alt="Header Dashboard Film" src="https://github.com/user-attachments/assets/7ccb5cc2-6395-4f67-a0f3-d6fab171f5ce" />

<h1 align="center">🎬 <b>Selamat Datang di Dashboard Film!</b> 🚀🍿</h1>

<h2 align="center"><i>"Explore Movies Through Data"</i></h2>

---

## 📑 Menu

- [📌 Informasi](#informasi)
- [📋 Tentang Project](#tentang)
- [📷 Screenshot Tampilan](#screenshot)
- [💾 Skema Basis Data](#database)
- [🔗 ERD](#erd)
- [📜 Deskripsi Data](#deskripsi)
- [📂 Struktur Folder](#folder)
- [🛠 Teknologi yang Digunakan](#tech)
- [👥 Tim Pengembang](#tim)

---

<h2 id="informasi">📌 Informasi</h2>

🎬 **Dashboard Film - Platform Analisis Data Film**

Platform ini memungkinkan pengguna untuk mengeksplorasi informasi film melalui visualisasi data interaktif menggunakan **R Shiny**.

Pengguna dapat:

- Menelusuri film berdasarkan genre
- Melihat distribusi rating film
- Menemukan film dengan rating tertinggi
- Melihat tren produksi film berdasarkan tahun rilis
- Membaca ulasan film dari pengguna lain

---

<h2 id="tentang">📋 Tentang Project</h2>

Project ini dibuat sebagai bagian dari praktikum **Pemrosesan Data Besar**.

Tujuan utama proyek ini adalah:

1. Merancang **database relasional** untuk dataset film.
2. Melakukan **normalisasi database hingga Third Normal Form (3NF)**.
3. Mengembangkan **dashboard interaktif menggunakan R Shiny**.
4. Menyediakan visualisasi untuk membantu eksplorasi data film.

Database mencakup beberapa entitas seperti:

- Film
- Aktor
- Sutradara
- Genre
- Perusahaan produksi
- Pengguna
- Review film

---

<h2 id="screenshot">📷 Screenshot Tampilan</h2>

### 1️⃣ Halaman Dashboard

Menampilkan ringkasan statistik film seperti:

- Total film
- Rata-rata rating
- Genre terpopuler
- Distribusi rating film

![](images/dashboard.png)

---

### 2️⃣ Halaman Daftar Film

Pengguna dapat:

- Menelusuri film
- Melihat informasi film
- Menggunakan filter genre dan rating

![](images/movie.png)

---

### 3️⃣ Halaman Review Film

Menampilkan ulasan pengguna terhadap film.

Informasi yang ditampilkan:

- Nama pengguna
- Rating
- Komentar
- Tanggal review

![](images/review.png)

---

<h2 id="database">💾 Skema Basis Data</h2>

Database dirancang menggunakan model relasional dengan beberapa entitas utama:

- **films**
- **users**
- **reviews**
- **actors**
- **directors**
- **genres**
- **production_companies**

Relasi many-to-many direpresentasikan melalui tabel penghubung seperti:

- film_actors
- film_directors
- film_genres
- film_production_companies

Struktur database dirancang untuk menjaga **integritas referensial dan konsistensi data**.

---

<h2 id="erd">🔗 ERD</h2>

ERD (Entity Relationship Diagram) menjelaskan hubungan antar entitas dalam database.

![](doc/ERD.png)

### 🌐 Relasi Antar Entitas

| Hubungan | Penjelasan |
|--------|--------|
| Film → Director (1:N) | Satu sutradara dapat menyutradarai banyak film |
| Film → Actor (M:N) | Film dapat memiliki banyak aktor |
| Film → Genre (M:N) | Film dapat memiliki lebih dari satu genre |
| Film → Review (1:N) | Film dapat memiliki banyak ulasan |
| User → Review (1:N) | Satu user dapat memberikan banyak ulasan |

---

<h2 id="deskripsi">📜 Deskripsi Data</h2>

Database dibuat menggunakan **MySQL**.

Contoh pembuatan database:

```sql
CREATE DATABASE film_dashboard;
USE film_dashboard;

Contoh pembuatan tabel film:

CREATE TABLE films (
  film_id INT PRIMARY KEY,
  title VARCHAR(255),
  release_date DATE,
  duration INT
);

Struktur lengkap tabel dapat dilihat pada file:

connection/ddl.sql
<h2 id="folder">📂 Struktur Folder</h2>
Dashboard-Film/
│
├── app/                # Aplikasi dashboard R Shiny
│   ├── app.R
│   ├── ui.R
│   └── server.R
│
├── connection/         # Konfigurasi database
│   ├── db_setup.R
│   ├── ddl.sql
│   └── queries.sql
│
├── doc/                # Dokumentasi proyek
│   └── ERD.png
│
├── images/             # Gambar dashboard
│
└── README.md
<h2 id="tech">🛠 Teknologi yang Digunakan</h2>

R Shiny – Framework dashboard interaktif

ShinyDashboard / bs4Dash – UI dashboard

MySQL – Database

DBI & RMySQL – Koneksi database

tidyverse – Manipulasi data

ggplot2 – Visualisasi data

Plotly – Grafik interaktif

<h2 id="tim">👥 Tim Pengembang</h2>

Database Manager
Mengelola struktur database, integritas data, dan performa database.

Backend Developer
Mengembangkan query database dan integrasi dengan dashboard.

Frontend Developer
Mendesain tampilan dashboard agar interaktif dan user-friendly.

Data Analyst
Menyusun dokumentasi analisis data, mendefinisikan KPI, serta memastikan konsistensi antara database dan dashboard.

📜 Lisensi

Project ini dibuat sebagai tugas praktikum mata kuliah Pemrosesan Data Besar.


---

✅ **Cara pakai:**

1. Buka repo GitHub kamu  
2. Klik **README.md**  
3. Klik **Edit**  
4. **Paste semua teks di atas**  
5. Commit

Commit message yang bagus:


update README to follow project documentation structure


---
