% bonus_gods_hand.pl
% God's Hand adalah aksi utama dengan peluang kejadian 10%.

godsHand :-
    aksi_boleh,
    urutan_pemain(Urutan),
    ( semua_punya_satu_kartu(Urutan)
    ->  write('Semua pemain hanya memiliki 1 kartu. God''s Hand tidak dijalankan.'), nl,
        next_turn
    ;   random(0, 10, Roll),
        ( Roll =:= 0
        ->  jalankan_gods_hand(Urutan, Status)
        ;   write('Tuhan tidak berkehendak saat ini.'), nl,
            Status = lanjut
        ),
        lanjut_setelah_gods_hand(Status)
    ).

lanjut_setelah_gods_hand(selesai) :- !.
lanjut_setelah_gods_hand(lanjut) :-
    next_turn.

semua_punya_satu_kartu([]).
semua_punya_satu_kartu([Pemain|Rest]) :-
    jumlah_kartu_total(Pemain, Jumlah),
    Jumlah =:= 1,
    semua_punya_satu_kartu(Rest).

jalankan_gods_hand(Urutan, Status) :-
    cari_pemain_dengan_kartu(Urutan, ListCalonSumber),
    hitung_panjang(ListCalonSumber, NSumber),
    random(0, NSumber, IdxSumber),
    IdxSumber1 is IdxSumber + 1,
    ambil_ke(IdxSumber1, ListCalonSumber, PemainSumber),
    semua_kartu_pemain(PemainSumber, ListSemuaKartu),
    hitung_panjang(ListSemuaKartu, NKartu),
    random(0, NKartu, IdxKartu),
    NomorKartu is IdxKartu + 1,
    pilih_kartu_pemain(PemainSumber, NomorKartu, KartuPilih, ListSumberBaru, HiddenSumberBaru, SisaSumber),
    hapus_satu(PemainSumber, Urutan, ListCalonTujuan),
    hitung_panjang(ListCalonTujuan, NTujuan),
    random(0, NTujuan, IdxTujuan),
    IdxTujuan1 is IdxTujuan + 1,
    ambil_ke(IdxTujuan1, ListCalonTujuan, PemainTujuan),
    simpan_kartu_pemain(PemainSumber, ListSumberBaru, HiddenSumberBaru),
    tambah_satu_kartu_pemain(PemainTujuan, KartuPilih),
    KartuPilih = kartu(W, J),
    write('Tuhan telah berkehendak.'), nl,
    format('Kartu ~w-~w milik ~w berpindah ke tangan ~w!~n', [W, J, PemainSumber, PemainTujuan]),
    ( SisaSumber = []
    ->  format('~w menghabiskan semua kartunya!~n', [PemainSumber]),
        endGame,
        Status = selesai
    ;   Status = lanjut
    ).

cari_pemain_dengan_kartu([], []).
cari_pemain_dengan_kartu([Pemain|Rest], [Pemain|HasilRest]) :-
    jumlah_kartu_total(Pemain, Jumlah),
    Jumlah > 0,
    !,
    cari_pemain_dengan_kartu(Rest, HasilRest).
cari_pemain_dengan_kartu([_|Rest], Hasil) :-
    cari_pemain_dengan_kartu(Rest, Hasil).
