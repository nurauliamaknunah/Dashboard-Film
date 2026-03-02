# Normalisasi Database

## Bentuk Awal
Data awal menyimpan genre dalam satu kolom yang memungkinkan multi-value.

## 1NF
Data dipecah agar setiap atribut bernilai atomik.

## 2NF
Setiap atribut non-key bergantung penuh pada primary key.

## 3NF
Tidak ada dependensi transitif.
Relasi many-to-many direpresentasikan melalui tabel film_genre.

Struktur database telah memenuhi 3NF.
