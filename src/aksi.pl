gabung_list([], L, L).
gabung_list([H|T], L, [H|R]) :- gabung_list(T, L, R).

mainkanKartu(Nomor) :-
    giliran(Pemain),
    kartu_pemain(Pemain, ListKartu),
    ( ambil_dan_hapus_kartu(Nomor, ListKartu, Kartu, ListBaru) -> true ; write('Nomor kartu tidak valid.'), nl, fail ),
    ( bisa_dimainkan(Kartu) -> true ; write('Kartu tidak bisa dimainkan.'), nl, fail ),
    retract(kartu_pemain(Pemain, ListKartu)),
    assertz(kartu_pemain(Pemain, ListBaru)),
    retract(discard_top(_)),
    assertz(discard_top(Kartu)),
    Kartu = kartu(Warna, Jenis),
    format('~w memainkan kartu: ~w-~w.~n', [Pemain, Warna, Jenis]),
    ( ListBaru = [] ->
        format('~w menghabiskan semua kartunya!~n', [Pemain]), endGame
    ; terapkan_efek(Kartu) ).

ambil_dan_hapus_kartu(1, [Head|Tail], Head, Tail) :- !.
ambil_dan_hapus_kartu(N, [Head|Tail], Kartu, [Head|TailSisa]) :-
    N > 1,
    N1 is N - 1,
    ambil_dan_hapus_kartu(N1, Tail, Kartu, TailSisa).

bisa_dimainkan(kartu(hitam, wild)) :- !.
bisa_dimainkan(kartu(hitam, wild_draw_four)) :- !.
bisa_dimainkan(kartu(Warna, _)) :- warna_aktif(Warna), !.
bisa_dimainkan(kartu(_, Jenis)) :- discard_top(kartu(_, Jenis)), !.

punya_kartu_cocok([]).
punya_kartu_cocok([kartu(hitam, wild_draw_four)|Rest]) :- punya_kartu_cocok(Rest).
punya_kartu_cocok([K|_]) :- K \= kartu(hitam, wild_draw_four), bisa_dimainkan_non_wdf(K), !.
punya_kartu_cocok([_|Rest]) :- punya_kartu_cocok(Rest).

bisa_dimainkan_non_wdf(kartu(hitam, wild)) :- !.
bisa_dimainkan_non_wdf(kartu(Warna, _)) :- warna_aktif(Warna), !.
bisa_dimainkan_non_wdf(kartu(_, Jenis)) :- discard_top(kartu(_, Jenis)), !.

terapkan_efek(kartu(Warna, N)) :- is_angka(N), !, set_warna_aktif(Warna), next_turn.
terapkan_efek(kartu(Warna, skip)) :- !, set_warna_aktif(Warna), next_turn_skip.
terapkan_efek(kartu(Warna, reverse)) :- !, set_warna_aktif(Warna), balik_arah, next_turn.
terapkan_efek(kartu(Warna, draw_two)) :- !,
    set_warna_aktif(Warna),
    giliran(Sekarang),
    urutan_pemain(Urutan),
    arah_permainan(Arah),
    cari_pemain_berikut(Sekarang, Urutan, Arah, Korban),
    ambil_kartu_acak(2, [], DuaKartu),
    kartu_pemain(Korban, ListLama),
    gabung_list(DuaKartu, ListLama, ListBaru),
    retract(kartu_pemain(Korban, ListLama)),
    assertz(kartu_pemain(Korban, ListBaru)),
    format('~w mendapatkan 2 kartu dan melewati giliran.~n', [Korban]),
    next_turn_skip.

terapkan_efek(kartu(hitam, wild)) :- !, pilih_warna_baru, next_turn.

terapkan_efek(kartu(hitam, wild_draw_four)) :- !,
    discard_top(KartuSebelumnya),
    retractall(discard_sebelum_wdf(_)),
    assertz(discard_sebelum_wdf(KartuSebelumnya)),
    pilih_warna_baru,
    retractall(efek_aktif(_)),
    assertz(efek_aktif(wild_draw_four)),
    giliran(Sekarang),
    urutan_pemain(Urutan),
    arah_permainan(Arah),
    cari_pemain_berikut(Sekarang, Urutan, Arah, Berikut),
    retract(giliran(Sekarang)),
    assertz(giliran(Berikut)),
    format('Giliran ~w. Ketik ambilKartu. atau tantang.~n', [Berikut]).

ambilKartu :-
    giliran(Pemain),
    efek_aktif(Efek),
    ( Efek = wild_draw_four ->
        ambil_kartu_acak(4, [], EmpatKartu),
        kartu_pemain(Pemain, ListLama),
        gabung_list(EmpatKartu, ListLama, ListBaru),
        retract(kartu_pemain(Pemain, ListLama)),
        assertz(kartu_pemain(Pemain, ListBaru)),
        retractall(efek_aktif(_)),
        assertz(efek_aktif(none)),
        format('~w mendapatkan 4 kartu.~n', [Pemain]),
        next_turn
    ;   
        kartu_acak(KartuBaru),
        kartu_pemain(Pemain, ListLama),
        retract(kartu_pemain(Pemain, ListLama)),
        assertz(kartu_pemain(Pemain, [KartuBaru|ListLama])),
        KartuBaru = kartu(W, J),
        format('~w mendapatkan kartu: ~w-~w.~n', [Pemain, W, J]),
        next_turn
    ).

ambil_kartu_acak(0, Acc, Acc) :- !.
ambil_kartu_acak(N, Acc, Hasil) :-
    N > 0,
    kartu_acak(K),
    N1 is N - 1,
    ambil_kartu_acak(N1, [K|Acc], Hasil).

tantang :-
    efek_aktif(wild_draw_four),
    !,
    write('Tantangan dilakukan!'), nl,
    giliran(Penantang),
    urutan_pemain(Urutan),
    arah_permainan(Arah),
    arah_kebalikan(Arah, ArahBalik),
    cari_pemain_berikut(Penantang, Urutan, ArahBalik, Tertantang),
    format('Memeriksa kartu ~w...~n', [Tertantang]),
    kartu_pemain(Tertantang, ListKartuTertantang),
    discard_sebelum_wdf(kartu(WarnaSebelum, JenisSebelum)),
    ( ada_kartu_cocok_tantang(ListKartuTertantang, WarnaSebelum, JenisSebelum) ->
        ambil_kartu_acak(4, [], EmpatKartu),
        kartu_pemain(Tertantang, ListLama),
        gabung_list(EmpatKartu, ListLama, ListBaru),
        retract(kartu_pemain(Tertantang, ListLama)),
        assertz(kartu_pemain(Tertantang, ListBaru)),
        retractall(efek_aktif(_)),
        assertz(efek_aktif(none)),
        format('Tantangan berhasil! ~w mendapatkan 4 kartu acak.~n', [Tertantang]),
        next_turn
    ;
        ambil_kartu_acak(6, [], EnamKartu),
        kartu_pemain(Penantang, ListLamaPenantang),
        gabung_list(EnamKartu, ListLamaPenantang, ListBaruPenantang),
        retract(kartu_pemain(Penantang, ListLamaPenantang)),
        assertz(kartu_pemain(Penantang, ListBaruPenantang)),
        retractall(efek_aktif(_)),
        assertz(efek_aktif(none)),
        format('Tantangan gagal. ~w mendapatkan 6 kartu acak.~n', [Penantang]),
        next_turn
    ).

ada_kartu_cocok_tantang([kartu(hitam,wild_draw_four)|Rest], W, J) :- ada_kartu_cocok_tantang(Rest, W, J).
ada_kartu_cocok_tantang([kartu(hitam, wild)|_], _, _) :- !.
ada_kartu_cocok_tantang([kartu(W, _)|_], W, _) :- !.
ada_kartu_cocok_tantang([kartu(_, J)|_], _, J) :- !.
ada_kartu_cocok_tantang([_|Rest], W, J) :- ada_kartu_cocok_tantang(Rest, W, J).

tantang :- write('Tidak ada wild draw four yang bisa ditantang.'), nl.

punya_kartu_cocok_tantang([K|_]) :- K \= kartu(hitam, wild_draw_four), bisa_dimainkan_non_wdf(K), !.
punya_kartu_cocok_tantang([_|Rest]) :- punya_kartu_cocok_tantang(Rest).

arah_kebalikan(kanan, kiri).
arah_kebalikan(kiri, kanan).

uni(Nomor) :-
    giliran(Pemain),
    kartu_pemain(Pemain, ListKartu),
    hitung_panjang(ListKartu, Jumlah),
    ( Jumlah =:= 2 ->
        ( ambil_dan_hapus_kartu(Nomor, ListKartu, Kartu, ListBaru) -> true ; write('Nomor kartu tidak valid.'), nl, fail ),
        ( bisa_dimainkan(Kartu) -> true ; write('Kartu tidak bisa dimainkan.'), nl, fail ),
        retract(kartu_pemain(Pemain, ListKartu)),
        assertz(kartu_pemain(Pemain, ListBaru)),
        retract(discard_top(_)),
        assertz(discard_top(Kartu)),
        Kartu = kartu(Warna, Jenis),
        format('~w memainkan kartu: ~w-~w.~n', [Pemain, Warna, Jenis]),
        format('~w menyerukan UNI!~n', [Pemain]),
        status_uni(ListUNI),
        retract(status_uni(ListUNI)),
        assertz(status_uni([Pemain|ListUNI])),
        ( ListBaru = [] ->
            format('~w menghabiskan semua kartunya!~n', [Pemain]), endGame
        ; terapkan_efek(Kartu) )
    ;   
        write('Perintah uni tidak valid. Kartu harus berjumlah 2.'), nl,
        kartu_acak(KartuPenalti),
        kartu_pemain(Pemain, ListLama),
        retract(kartu_pemain(Pemain, ListLama)),
        assertz(kartu_pemain(Pemain, [KartuPenalti|ListLama])),
        write('Mendapatkan 1 kartu penalti.'), nl,
        next_turn
    ).

tangkap(NamaPemain) :-
    kartu_pemain(NamaPemain, ListKartu),
    hitung_panjang(ListKartu, Jumlah),
    status_uni(ListUNI),
    ( Jumlah =:= 1, \+ cek_member(NamaPemain, ListUNI) ->
        ambil_kartu_acak(2, [], DuaKartu),
        gabung_list(DuaKartu, ListKartu, ListBaru),
        retract(kartu_pemain(NamaPemain, ListKartu)),
        assertz(kartu_pemain(NamaPemain, ListBaru)),
        format('~w tertangkap tidak menyerukan UNI.~n', [NamaPemain]),
        format('~w mendapatkan 2 kartu penalti.~n', [NamaPemain]),
        giliran(Penangkap),
        next_turn
    ;   
        giliran(Penangkap),
        write('Perintah tangkap tidak valid.'),nl,
        kartu_acak(KartuPenalti),
        kartu_pemain(Penangkap, ListLamaPenangkap),
        retract(kartu_pemain(Penangkap, ListLamaPenangkap)),
        assertz(kartu_pemain(Penangkap, [KartuPenalti|ListLamaPenangkap])),
        format('~w mendapatkan 1 kartu penalti.~n', [Penangkap]),
        next_turn
    ).

update_warna_aktif(hitam) :- !, pilih_warna_baru.
update_warna_aktif(Warna) :- set_warna_aktif(Warna).