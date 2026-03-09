# Pembahasan Project Dashboard Film

## 1. Gambaran Umum Dataset

Dataset yang digunakan dalam project ini merupakan dataset film yang berisi informasi mengenai film, aktor, sutradara, genre, perusahaan produksi, serta ulasan dari pengguna.

Data ini digunakan untuk membangun sebuah dashboard interaktif yang memungkinkan pengguna untuk mengeksplorasi informasi film secara lebih mudah melalui visualisasi data.

Melalui dashboard ini, pengguna dapat:

- melihat distribusi rating film
- menemukan film dengan rating tertinggi
- mengeksplorasi film berdasarkan genre
- melihat tren produksi film berdasarkan tahun rilis
- membaca ulasan pengguna terhadap film

---

# 2. Perancangan Database

Database dirancang menggunakan model relasional yang terdiri dari beberapa entitas utama, yaitu:

- films
- users
- reviews
- actors
- directors
- genres
- production_companies

Setiap entitas memiliki primary key yang digunakan untuk mengidentifikasi setiap record secara unik.

Untuk menjaga integritas data, hubungan antar entitas direpresentasikan menggunakan foreign key.

Beberapa hubungan antar entitas adalah:

- Film → Director (1:N)
- Film → Actor (M:N)
- Film → Genre (M:N)
- Film → Review (1:N)
- User → Review (1:N)

Relasi many-to-many seperti hubungan antara film dengan aktor dan genre direpresentasikan menggunakan tabel relasi seperti:

- film_actors
- film_genres
- film_directors

---

# 3. Normalisasi Database

Proses normalisasi dilakukan untuk mengurangi redundansi data dan memastikan konsistensi data dalam database.

Database pada project ini telah dinormalisasi hingga **Third Normal Form (3NF)**.

## First Normal Form (1NF)

Pada tahap ini setiap atribut dalam tabel harus memiliki nilai atomik dan tidak boleh memiliki atribut multi-value.

Contohnya, genre film tidak disimpan sebagai beberapa nilai dalam satu kolom, tetapi dipisahkan melalui tabel relasi.

## Second Normal Form (2NF)

Pada tahap ini setiap atribut non-key harus bergantung sepenuhnya pada primary key.

Contohnya, informasi aktor tidak disimpan langsung pada tabel film, tetapi dipisahkan ke dalam tabel actors.

## Third Normal Form (3NF)

Pada tahap ini tidak boleh ada dependensi transitif antar atribut non-key.

Sebagai contoh:

- data sutradara dipisahkan ke tabel directors
- data aktor dipisahkan ke tabel actors
- data genre dipisahkan ke tabel genres

Struktur ini membuat database lebih efisien dan mudah untuk dikembangkan.

---

# 4. Analisis Dashboard

Dashboard yang dibangun menggunakan R Shiny menampilkan beberapa indikator utama (KPI) untuk membantu pengguna memahami data film.

Beberapa KPI yang ditampilkan antara lain:

### Total Film

Menampilkan jumlah total film dalam database.

### Rata-rata Rating

Menampilkan nilai rata-rata rating film berdasarkan ulasan pengguna.

### Genre Terpopuler

Menampilkan genre dengan jumlah film terbanyak.

### Distribusi Rating Film

Menampilkan sebaran rating film untuk mengetahui pola kualitas film secara umum.

### Tren Produksi Film

Menampilkan jumlah film yang dirilis setiap tahun untuk melihat perkembangan produksi film.

---

# 5. Validasi Analisis

Untuk memastikan hasil analisis pada dashboard akurat, setiap indikator dihitung menggunakan query SQL yang mengambil data langsung dari database.

Sebagai contoh:

- total film dihitung menggunakan COUNT(*)
- rata-rata rating dihitung menggunakan AVG(rating)
- genre terpopuler dihitung menggunakan GROUP BY genre

Dengan menggunakan query langsung dari database, hasil visualisasi pada dashboard dapat dipastikan konsisten dengan data yang tersimpan.
