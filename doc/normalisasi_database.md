# Normalisasi Database

Dokumen ini menjelaskan proses normalisasi database yang digunakan dalam project Dashboard Film.

Normalisasi dilakukan untuk mengurangi redundansi data dan memastikan konsistensi data dalam database.

Struktur database pada project ini telah dinormalisasi hingga **Third Normal Form (3NF)**.

---

## 1. First Normal Form (1NF)

First Normal Form (1NF) mengharuskan setiap atribut dalam tabel memiliki nilai yang bersifat atomik dan tidak memiliki atribut yang berulang.

Pada tahap ini dilakukan pemisahan atribut yang sebelumnya dapat memiliki banyak nilai menjadi tabel terpisah.

Contoh penerapan 1NF pada database ini adalah pemisahan data aktor, sutradara, genre, dan perusahaan produksi ke dalam tabel masing-masing.

Dengan demikian, tabel `films` hanya menyimpan informasi utama film seperti `imdb_id`, `title`, `rating_imdb`, `rating_count`, `storyline`, `certificates`, `release_date`, `duration_min`, `imdb_url_film`, dan `url_poster`, tanpa menyimpan daftar aktor, genre, sutradara, atau perusahaan produksi secara langsung.

---

## 2. Second Normal Form (2NF)

Second Normal Form (2NF) mengharuskan setiap atribut non-key bergantung sepenuhnya pada primary key.

Pada tahap ini, atribut yang tidak bergantung langsung pada primary key dipisahkan ke dalam tabel yang sesuai.

Contohnya:

- Informasi aktor disimpan pada tabel `actors`
- Informasi sutradara disimpan pada tabel `directors`
- Informasi genre disimpan pada tabel `genres`
- Informasi perusahaan produksi disimpan pada tabel `production_companies`

Relasi antara tabel-tabel tersebut dengan tabel `films` direpresentasikan menggunakan tabel relasi seperti:

- `film_actors`
- `film_directors`
- `film_genres`
- `film_production_companies`

Selain itu, ulasan pengguna juga dipisahkan ke dalam tabel `reviews`, sehingga informasi review tidak disimpan langsung di tabel `films`.

---

## 3. Third Normal Form (3NF)

Third Normal Form (3NF) mengharuskan tidak adanya dependensi transitif dalam tabel.

Artinya atribut non-key tidak boleh bergantung pada atribut non-key lainnya.

Pada database ini, setiap tabel hanya menyimpan atribut yang secara langsung berkaitan dengan entitas tersebut.

Sebagai contoh:

- Tabel `films` hanya menyimpan informasi terkait film
- Tabel `users` hanya menyimpan informasi terkait pengguna
- Tabel `actors` hanya menyimpan informasi aktor
- Tabel `directors` hanya menyimpan informasi sutradara
- Tabel `genres` hanya menyimpan informasi genre
- Tabel `production_companies` hanya menyimpan informasi perusahaan produksi
- Tabel `reviews` hanya menyimpan informasi ulasan pengguna terhadap film

Dengan struktur ini, database menjadi lebih efisien, mudah dikelola, dan mengurangi kemungkinan inkonsistensi data.

---

## 4. Kesimpulan

Dengan menerapkan proses normalisasi hingga **Third Normal Form (3NF)**, struktur database pada project Dashboard Film menjadi lebih terorganisir dan efisien.

Normalisasi membantu mengurangi redundansi data, meningkatkan konsistensi data, serta mempermudah proses pengelolaan dan analisis data.
