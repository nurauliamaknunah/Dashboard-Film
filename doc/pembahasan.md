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

## 2. Perancangan Database

Database dirancang menggunakan model relasional yang terdiri dari beberapa entitas utama, yaitu:

- films
- users
- reviews
- actors
- directors
- genres
- production_companies

Setiap entitas memiliki primary key yang digunakan untuk mengidentifikasi setiap record secara unik.

Primary key yang digunakan pada beberapa tabel utama adalah:

- `imdb_id` pada tabel `films`
- `username` pada tabel `users`
- `review_id` pada tabel `reviews`
- `actor_id` pada tabel `actors`
- `director_id` pada tabel `directors`
- `genre_id` pada tabel `genres`
- `company_id` pada tabel `production_companies`

Untuk menjaga integritas data, hubungan antar entitas direpresentasikan menggunakan foreign key.

Beberapa hubungan antar entitas adalah:

- Film → Review (1:N)
- User → Review (1:N)
- Film → Actor (M:N)
- Film → Director (M:N)
- Film → Genre (M:N)
- Film → Production Company (M:N)

Relasi many-to-many direpresentasikan menggunakan tabel penghubung, yaitu:

- film_actors
- film_directors
- film_genres
- film_production_companies

Dengan struktur ini, data film tidak disimpan secara berulang dalam satu tabel, tetapi dipisahkan ke tabel-tabel yang sesuai dengan entitasnya masing-masing.

---

## 3. Normalisasi Database

Proses normalisasi dilakukan untuk mengurangi redundansi data dan memastikan konsistensi data dalam database.

Database pada project ini telah dinormalisasi hingga **Third Normal Form (3NF)**.

### First Normal Form (1NF)

Pada tahap ini setiap atribut dalam tabel harus memiliki nilai atomik dan tidak boleh memiliki atribut multi-value.

Contohnya, genre film tidak disimpan sebagai beberapa nilai dalam satu kolom pada tabel `films`, tetapi dipisahkan melalui tabel `film_genres` dan `genres`.

### Second Normal Form (2NF)

Pada tahap ini setiap atribut non-key harus bergantung sepenuhnya pada primary key.

Contohnya, informasi aktor tidak disimpan langsung pada tabel `films`, tetapi dipisahkan ke dalam tabel `actors` dan dihubungkan melalui tabel `film_actors`.

Hal yang sama juga diterapkan pada sutradara, genre, dan perusahaan produksi.

### Third Normal Form (3NF)

Pada tahap ini tidak boleh ada dependensi transitif antar atribut non-key.

Sebagai contoh:

- data sutradara dipisahkan ke tabel `directors`
- data aktor dipisahkan ke tabel `actors`
- data genre dipisahkan ke tabel `genres`
- data perusahaan produksi dipisahkan ke tabel `production_companies`

Struktur ini membuat database lebih efisien, mengurangi redundansi, dan mempermudah proses query analitik.

---

## 4. Analisis Dashboard

Dashboard yang dibangun menggunakan R Shiny menampilkan beberapa indikator utama (KPI) untuk membantu pengguna memahami data film.

Beberapa KPI yang ditampilkan antara lain:

### Total Film

Menampilkan jumlah total film dalam database.

### Rata-rata Rating Film

Menampilkan nilai rata-rata rating film berdasarkan kolom `rating_imdb` pada tabel `films`.

### Genre Terpopuler

Menampilkan genre dengan jumlah film terbanyak berdasarkan relasi antara tabel `film_genres` dan `genres`.

### Distribusi Rating Film

Menampilkan sebaran nilai `rating_imdb` untuk mengetahui pola kualitas film secara umum.

### Tren Produksi Film

Menampilkan jumlah film yang dirilis setiap tahun berdasarkan kolom `release_date`.

### Top Film Berdasarkan Rating IMDb

Menampilkan film dengan nilai `rating_imdb` tertinggi.

---

## 5. Validasi Analisis

Untuk memastikan hasil analisis pada dashboard akurat, setiap indikator dihitung menggunakan query SQL yang mengambil data langsung dari database.

Sebagai contoh:

- total film dihitung menggunakan `COUNT(*)` pada tabel `films`
- rata-rata rating dihitung menggunakan `AVG(rating_imdb)` pada tabel `films`
- genre terpopuler dihitung menggunakan relasi `film_genres` dan `genres`
- tren produksi film dihitung dari kolom `release_date`

Dengan menggunakan query langsung dari database, hasil visualisasi pada dashboard dapat dipastikan konsisten dengan data yang tersimpan.

---

## 6. Kesimpulan

Project Dashboard Film memanfaatkan database relasional yang telah dinormalisasi hingga 3NF untuk mendukung analisis data film secara efisien.

Melalui dashboard ini, pengguna dapat memahami berbagai informasi penting mengenai film, seperti kualitas film berdasarkan rating IMDb, genre yang dominan, tren produksi film, serta film dengan rating tertinggi.

Struktur database yang baik dan dashboard yang interaktif diharapkan dapat membantu proses eksplorasi data film menjadi lebih mudah dan informatif.
