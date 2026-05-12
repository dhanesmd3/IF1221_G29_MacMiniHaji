% CEK ANGKA

is_angka(0). is_angka(1). is_angka(2). is_angka(3). is_angka(4).
is_angka(5). is_angka(6). is_angka(7). is_angka(8). is_angka(9).

kumpul_kartu([
    kartu(merah,0),   kartu(merah,1),   kartu(merah,2),   kartu(merah,3),   kartu(merah,4),
    kartu(merah,5),   kartu(merah,6),   kartu(merah,7),   kartu(merah,8),   kartu(merah,9),
    kartu(kuning,0),  kartu(kuning,1),  kartu(kuning,2),  kartu(kuning,3),  kartu(kuning,4),
    kartu(kuning,5),  kartu(kuning,6),  kartu(kuning,7),  kartu(kuning,8),  kartu(kuning,9),
    kartu(hijau,0),   kartu(hijau,1),   kartu(hijau,2),   kartu(hijau,3),   kartu(hijau,4),
    kartu(hijau,5),   kartu(hijau,6),   kartu(hijau,7),   kartu(hijau,8),   kartu(hijau,9),
    kartu(biru,0),    kartu(biru,1),    kartu(biru,2),    kartu(biru,3),    kartu(biru,4),
    kartu(biru,5),    kartu(biru,6),    kartu(biru,7),    kartu(biru,8),    kartu(biru,9),
    kartu(merah,skip),    kartu(kuning,skip),   kartu(hijau,skip),   kartu(biru,skip),
    kartu(merah,reverse), kartu(kuning,reverse),kartu(hijau,reverse),kartu(biru,reverse),
    kartu(merah,draw_two),kartu(kuning,draw_two),kartu(hijau,draw_two),kartu(biru,draw_two),
    kartu(hitam,wild),
    kartu(hitam,wild_draw_four)
]).

% JENIS KARTU

kartu_angka(kartu(_, J)) :- is_angka(J).
kartu_aksi(kartu(_, skip)).
kartu_aksi(kartu(_, reverse)).
kartu_aksi(kartu(_, draw_two)).
kartu_wild(kartu(hitam, wild)).
kartu_wild(kartu(hitam, wild_draw_four)).

% kartu yang boleh jadi awal discard pile (hanya kartu angka)
kartu_awal_valid(K) :- kartu_angka(K).

% NILAI KARTU (untuk hitung poin)

nilai_kartu(kartu(_, J), J)  :- is_angka(J), !.
nilai_kartu(kartu(_, skip),               10).
nilai_kartu(kartu(_, reverse),            10).
nilai_kartu(kartu(_, draw_two),           10).
nilai_kartu(kartu(hitam, wild),           20).
nilai_kartu(kartu(hitam, wild_draw_four), 20).

% AMBIL KARTU ACAK DARI DECK

kartu_acak(K) :-
    kumpul_kartu(SemuaKartu),
    hitung_panjang(SemuaKartu, Total),
    random(0, Total, Idx),
    Idx1 is Idx + 1,
    ambil_ke(Idx1, SemuaKartu, K).

% DISTRIBUSI KARTU

distribusiKartu :-
    urutan_pemain(ListPemain),
    bagikan_ke_semua(ListPemain).

bagikan_ke_semua([]).
bagikan_ke_semua([Pemain|Rest]) :-
    ambil_kartu_acak(7, [], TujuhKartu),
    assertz(kartu_pemain(Pemain, TujuhKartu)),
    bagikan_ke_semua(Rest).

% ambil N kartu acak, simpan di Acc
ambil_kartu_acak(0, Acc, Acc) :- !.
ambil_kartu_acak(N, Acc, Hasil) :-
    N > 0,
    kartu_acak(K),
    N1 is N - 1,
    ambil_kartu_acak(N1, [K|Acc], Hasil).

% INISIALISASI DISCARD PILE

inisialisasiDiscardPile :-
    kartu_acak(K),
    ( kartu_awal_valid(K)
    ->  assertz(discard_top(K)),
        K = kartu(W, _),
        set_warna_aktif(W)
    ;   inisialisasiDiscardPile
    ).