# IF1221_G29_MacMiniHaji
Implementasi permainan kartu **UNI** menggunakan bahasa **Prolog** untuk memenuhi tugas besar mata kuliah IF1221 Logika Komputasional.

# Anggota Kelompok
Malik Arsyafiandra Madani - 13525008
Avicenna Ananda  Musthafa - 13525018
Dhanesworo Muhammad Datiputro - 13525034
Axeleon Justin Algianto - 13525074

## Deskripsi Program
Program ini merupakan simulasi permainan kartu UNI berbasis command line yang dibuat menggunakan Prolog. Permainan mendukung beberapa pemain, berbagai jenis kartu aksi, sistem turn, penyimpanan permainan, serta fitur tambahan seperti mode turnamen dan kartu bonus. :contentReference[oaicite:1]{index=1}

## Fitur Utama
| ?- startGame.        % mulai game
| ?- lihatKartu.       % cek kartu di tangan
| ?- cekInfo.          % cek info permainan
| ?- lihatCommand.     % cek daftar perintah
| ?- mainkanKartu(1).  % coba mainkan kartu pertama
| ?- ambilKartu.       % coba ambil kartu

## Struktur Repository
```bash
├── src/
│   ├── main.pl
│   ├── kartu.pl
│   ├── aksi.pl
│   ├── pendukung.pl
│   └── ...
├── doc/
│   ├── Milestone1_G29.pdf
│   └── ...
├── README.md
