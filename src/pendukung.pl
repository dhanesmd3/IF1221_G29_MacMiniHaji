% pendukung.pl

lihatCommand :-
    nl,
    write('Aksi utama yang tersedia:'), nl,
    write('1. mainkanKartu(N)'), nl,
    write('2. ambilKartu'), nl,
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.

lihatKartu :-
    giliran(Pemain),
    kartu_pemain(Pemain, ListKartu),
    nl,
    write('Berikut kartu yang anda miliki.'), nl,
    tampilkan_list_kartu(ListKartu, 1).

tampilkan_list_kartu([], _).
tampilkan_list_kartu([kartu(W, J)|Rest], N) :-
    format('~w. ~w-~w~n', [N, W, J]),
    N1 is N + 1,
    tampilkan_list_kartu(Rest, N1).

cekInfo :-
    nl,
    discard_top(kartu(W, J)),
    format('Kartu discard top: ~w-~w.~n', [W, J]),
    urutan_pemain(Urutan),
    write('Urutan pemain: '),
    tampilkan_urutan(Urutan),
    nl,
    tampilkan_info_semua_pemain(Urutan, 1).

tampilkan_info_semua_pemain([], _).
tampilkan_info_semua_pemain([Pemain|Rest], N) :-
    kartu_pemain(Pemain, ListKartu),
    hitung_jumlah_kartu(ListKartu, Jumlah),
    format('Nama pemain ~w: ~w~n', [N, Pemain]),
    format('Jumlah kartu : ~w~n', [Jumlah]),
    nl,
    N1 is N + 1,
    tampilkan_info_semua_pemain(Rest, N1).

% hitung jumlah kartu pemain
hitung_jumlah_kartu([], 0).
hitung_jumlah_kartu([_|Rest], Jumlah) :-
    hitung_jumlah_kartu(Rest, JumlahRest),
    Jumlah is JumlahRest + 1.