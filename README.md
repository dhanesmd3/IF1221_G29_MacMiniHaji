# IF1221_G29_MacMiniHaji
Implementasi permainan kartu **UNI** menggunakan bahasa **Prolog** untuk memenuhi tugas besar mata kuliah IF1221 Logika Komputasional. :contentReference[oaicite:0]{index=0}

## Deskripsi Program
Program ini merupakan simulasi permainan kartu UNI berbasis command line yang dibuat menggunakan Prolog. Permainan mendukung beberapa pemain, berbagai jenis kartu aksi, sistem turn, penyimpanan permainan, serta fitur tambahan seperti mode turnamen dan kartu bonus. :contentReference[oaicite:1]{index=1}

## Fitur Utama
- Start game dan inisialisasi pemain
- Distribusi kartu otomatis
- Sistem giliran pemain
- Validasi kartu
- Kartu aksi:
  - Skip
  - Reverse
  - Draw Two
  - Wild
  - Wild Draw Four
- Command UNI dan tangkap
- Save & Load game
- End game dan sistem poin
- Mode turnamen
- Bonus features:
  - God’s Hand
  - Mimic Card
  - Hidden Card

## Struktur Repository
```bash
├── src/
│   ├── main.pl
│   ├── player.pl
│   ├── card.pl
│   ├── game.pl
│   ├── utility.pl
│   └── ...
├── doc/
│   ├── Milestone1_XX.pdf
│   ├── Milestone2_XX.pdf
│   ├── Laporan_XX.pdf
│   └── ...
├── README.md
