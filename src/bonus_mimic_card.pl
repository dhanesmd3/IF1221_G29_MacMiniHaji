catat_kartu_aksi(Kartu) :-
    ( Kartu = kartu(_, skip) ; Kartu = kartu(_, reverse) ;
      Kartu = kartu(_, draw_two) ; Kartu = kartu(hitam, wild) ;
      Kartu = kartu(hitam, wild_draw_four) ),
    !,
    retractall(kartu_aksi_terakhir(_)),
    assertz(kartu_aksi_terakhir(Kartu)).
catat_kartu_aksi(_).

terapkan_efek_mimic(Pemain) :-
    write('Menelusuri riwayat permainan.'), nl,
    ( kartu_aksi_terakhir(KartuAksiTerakhir)
    ->  KartuAksiTerakhir = kartu(WAksi, JAksi),
        format('Kartu aksi terakhir yang dimainkan: ~w-~w.~n', [WAksi, JAksi]),
        format('Kartu mimic menyalin efek ~w!~n', [JAksi]),
        terapkan_efek_tiruan(KartuAksiTerakhir, Pemain)
    ;   write('Belum ada kartu aksi sebelumnya. Kartu mimic berlaku seperti wild.'), nl,
        pilih_warna_baru,
        next_turn
    ).

terapkan_efek_tiruan(kartu(_, skip), _) :- !,
    pilih_warna_baru,
    next_turn_skip.

terapkan_efek_tiruan(kartu(_, reverse), _) :- !,
    pilih_warna_baru,
    balik_arah,
    next_turn.

terapkan_efek_tiruan(kartu(_, draw_two), _) :- !,
    pilih_warna_baru,
    mulai_efek_ambil(draw_two).

terapkan_efek_tiruan(kartu(hitam, wild), _) :- !,
    pilih_warna_baru,
    next_turn.

terapkan_efek_tiruan(kartu(hitam, wild_draw_four), _) :- !,
    warna_aktif(WarnaLama),
    retractall(warna_sebelum_wdf(_)),
    assertz(warna_sebelum_wdf(WarnaLama)),
    pilih_warna_baru,
    mulai_efek_ambil(wild_draw_four).
