# IF1221_G29_MacMiniHaji

Implementasi permainan kartu **UNI** menggunakan bahasa **Prolog** untuk memenuhi tugas besar mata kuliah **IF1221 Logika Komputasional**.

## Anggota Kelompok

| Nama | NIM |
|------|-----|
| Malik Arsyafiandra Madani | 13525008 |
| Avicenna Ananda Musthafa | 13525018 |
| Dhanesworo Muhammad Datiputro | 13525034 |
| Axeleon Justin Algianto | 13525074 |

## Gambaran Singkat Proyek

Program ini merupakan simulasi permainan kartu **UNI** berbasis *command line* yang dibuat dengan Prolog. Permainan mendukung 2–4 pemain secara bergiliran pada satu perangkat. Setiap pemain memulai dengan 7 kartu, lalu berusaha menghabiskan kartunya lebih dulu dengan memainkan kartu yang sesuai warna atau jenis dengan kartu teratas pada tumpukan buang. Permainan mendukung kartu angka, kartu aksi (skip, reverse, draw two), kartu wild, sistem giliran dua arah, penyeruan UNI, penyimpanan/pemuatan permainan, serta beberapa fitur bonus.

## Cara Menjalankan Program

Program dijalankan menggunakan **GNU Prolog (gprolog)**. Cukup memuat `main.pl`, karena berkas ini sudah meng-`include` seluruh modul permainan (`kartu.pl`, `state.pl`, `aksi.pl`, `pendukung.pl`) beserta seluruh modul bonus.

Buka GNU Prolog console, pilih menu **File → Consult...**, arahkan ke `src/main.pl`, lalu jalankan:

```prolog
| ?- startGame.
```

Setiap perintah diakhiri tanda titik (`.`). Setelah `startGame.`, program meminta jumlah pemain dan nama tiap pemain (ditulis sebagai atom diawali huruf kapital, contoh: `'Malik'`).

Contoh perintah selama permainan:

```prolog
| ?- mainkanKartu(1).        % mainkan kartu nomor 1 di tangan
| ?- ambilKartu.             % ambil kartu dari dek
| ?- uni(2).                 % mainkan kartu terakhir sambil menyerukan UNI
| ?- lihatKartu.             % lihat kartu di tangan
| ?- cekInfo.                % lihat info permainan saat ini
| ?- lihatCommand.           % lihat daftar perintah yang tersedia
```

## Fitur Utama

**Aksi utama**

- `startGame` — memulai permainan baru (input jumlah & nama pemain).
- `mainkanKartu(N)` — memainkan kartu nomor `N` dari tangan.
- `ambilKartu` — mengambil kartu dari dek, atau menuntaskan efek draw two / wild draw four.
- `uni(N)` — memainkan kartu terakhir sambil menyerukan UNI (wajib saat sisa 1 kartu).
- `tantang` — menantang kartu wild draw four yang dimainkan lawan.

**Aksi pendukung**

- `lihatKartu` — menampilkan kartu di tangan pemain yang sedang bergiliran.
- `cekInfo` — menampilkan kartu teratas, warna aktif, urutan, dan jumlah kartu tiap pemain.
- `lihatCommand` — menampilkan daftar perintah yang valid sesuai kondisi permainan.
- `tangkap(NamaPemain)` — menangkap pemain yang lupa menyerukan UNI.
- `saveGame` / `loadGame` — menyimpan dan memuat status permainan ke/dari berkas `.txt`.

**Jenis kartu**

- Kartu angka 0–9 untuk empat warna (merah, kuning, hijau, biru).
- Kartu aksi: *skip*, *reverse*, *draw two*.
- Kartu wild: *wild* dan *wild draw four* (dengan mekanisme tantang).

**Fitur bonus**

- **God's Hand** (`godsHand`) — aksi dengan peluang 10% memindahkan satu kartu acak antar pemain.
- **Kartu Tersembunyi** (`sembunyikanKartu(N)` / `tampilkanKartu`) — menyembunyikan satu kartu yang tetap dihitung dan tetap bisa dimainkan.
- **Mimic Card** — kartu hitam spesial yang meniru efek kartu aksi terakhir yang dimainkan; berlaku seperti wild bila belum ada kartu aksi sebelumnya.

> Catatan: mode turnamen tidak diimplementasikan.

## Struktur Repository

```
.
├── src/
│   ├── main.pl                       # Entry point; memuat seluruh modul
│   ├── kartu.pl                      # Definisi kartu, dek, jenis, dan nilai kartu
│   ├── state.pl                      # State permainan, giliran, save/load, utilitas list
│   ├── aksi.pl                       # Logika aksi utama (mainkan, ambil, uni, tantang)
│   ├── pendukung.pl                  # Command bantuan & informasi (lihatKartu, cekInfo, dll.)
│   ├── bonus_gods_hand.pl            # Bonus: God's Hand
│   ├── bonus_kartu_tersembunyi.pl    # Bonus: kartu tersembunyi
│   └── bonus_mimic_card.pl           # Bonus: mimic card
├── doc/
│   ├── Milestone1_G29.pdf            # Laporan Milestone 1
│   └── Milestone2_G29.pdf            # Laporan Milestone 2
└── README.md
```
