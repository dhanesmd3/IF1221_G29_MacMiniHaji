lihatCommand :-
    nl,
    efek_aktif(wild_draw_four),
    !,
    write('Aksi utama yang tersedia:'), nl,
    write('1. ambilKartu'), nl,
    write('2. tantang'), nl,
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.

lihatCommand :-
    nl,
    efek_aktif(draw_two),
    !,
    write('Aksi utama yang tersedia:'), nl,
    write('1. ambilKartu'), nl,
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.

lihatCommand :-
    nl,
    write('Aksi utama yang tersedia:'), nl,
    write('1. mainkanKartu(N)'), nl,
    write('2. ambilKartu'), nl,
    write('3. uni(N)'), nl,
    write('4. godsHand'), nl,
    write('5. sembunyikanKartu(N)'), nl,
    write('6. tampilkanKartu'), nl,
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl,
    write('4. tangkap(NamaPemain)'), nl,
    write('5. saveGame'), nl.

% LIHAT KARTU

lihatKartu :-
    giliran(Pemain),
    kartu_pemain(Pemain, ListKartu),
    nl,
    write('Berikut kartu yang anda miliki.'), nl,
    tampilkan_list_kartu(ListKartu, 1, NomorBerikut),
    tampilkan_kartu_tersembunyi(Pemain, NomorBerikut).

tampilkan_list_kartu([], N, N).
tampilkan_list_kartu([kartu(W, J)|Rest], N, NomorAkhir) :-
    format('~w. ~w-~w~n', [N, W, J]),
    N1 is N + 1,
    tampilkan_list_kartu(Rest, N1, NomorAkhir).

tampilkan_kartu_tersembunyi(Pemain, N) :-
    ( kartu_tersembunyi(Pemain, kartu(W, J))
    ->  format('~w. ~w-~w (disembunyikan)~n', [N, W, J])
    ;   true
    ).

% CEK INFO

cekInfo :-
    nl,
    discard_top(kartu(W, J)),
    format('Kartu discard top: ~w-~w.~n', [W, J]),
    warna_aktif(Warna),
    format('Warna aktif: ~w.~n', [Warna]),
    urutan_pemain(Urutan),
    write('Urutan pemain: '),
    tampilkan_urutan(Urutan),
    nl,
    tampilkan_info_semua_pemain(Urutan, 1).

tampilkan_info_semua_pemain([], _).
tampilkan_info_semua_pemain([Pemain|Rest], N) :-
    jumlah_kartu_total(Pemain, Jumlah),
    format('Nama pemain ~w: ~w~n', [N, Pemain]),
    format('Jumlah kartu : ~w~n', [Jumlah]),
    nl,
    N1 is N + 1,
    tampilkan_info_semua_pemain(Rest, N1).
