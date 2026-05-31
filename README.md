# UNI Prolog

## Deskripsi

UNI Prolog adalah implementasi permainan kartu UNI berbasis command-line menggunakan bahasa Prolog.
Program ini mensimulasikan mekanisme permainan UNI dengan beberapa fitur tambahan, termasuk kartu spesial dan sistem penalti.

Permainan mendukung:
- Kartu angka (0–9)
- Skip
- Reverse
- Draw Two
- Wild
- Wild Draw Four
- Mimic (kartu tambahan)
- Sistem UNI
- Challenge Wild Draw Four
- Perhitungan skor pemain

---

## Anggota Kelompok

| NIM | Nama |
|------|------|
| 13525128 | Mochamad Fachri Alfaridzi |
| 13525021 | NHaikal Muhammad Royyan |
| 13525095 | Moch Naufal Zaki Basara |
| 13525132 | Zidane Uland Fakhry |

---

## Environment

Program dikembangkan dan diuji menggunakan GNU Prolog.

---

## Cara Menjalankan Program

1. Buka GNU Prolog.
2. Masuk ke direktori proyek.
3. Load file utama:

```prolog
['main.pl'].
```

atau

```prolog
consult('main.pl').
```

4. Jalankan permainan:

```prolog
startGame.
```

## Struktur Program

```text
.
├── main.pl
├── deck.pl
├── command.pl
├── gameplay.pl
├── player.pl
├── ingfo.pl
├── setup.pl
└── save_load.pl
```

## Fitur yang Diimplementasikan

### Fitur Utama

- [x] Inisialisasi permainan
- [x] Pembagian kartu awal
- [x] Sistem giliran pemain
- [x] Validasi kartu
- [x] Draw card
- [x] Skip
- [x] Reverse
- [x] Draw Two
- [x] Wild
- [x] Wild Draw Four
- [x] Penentuan pemenang

### Fitur Tambahan

- [x] Mimic Card
- [x] Sistem UNI
- [x] Tangkap pemain yang lupa UNI
- [x] Challenge Wild Draw Four
- [x] Perhitungan skor akhir

---

## Aturan Permainan

1. Setiap pemain menerima 7 kartu di awal permainan.
2. Pemain hanya dapat memainkan kartu yang valid terhadap kartu aktif.
3. Jika tidak memiliki kartu yang dapat dimainkan, pemain harus mengambil kartu dari deck.
4. Pemain wajib mengucapkan UNI ketika hanya memiliki satu kartu tersisa.
5. Pemain yang kehabisan kartu terlebih dahulu menjadi pemenang ronde.
6. Skor dihitung berdasarkan kartu yang masih dimiliki pemain lain.

---

## Kontributor

Praktikum Logika Komputasional

Institut Teknologi Bandung
