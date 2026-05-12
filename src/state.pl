% fakta dinamis
:- dynamic(giliran/1).
:- dynamic(urutan_pemain/1).
:- dynamic(arah_permainan/1).
:- dynamic(warna_aktif/1).
:- dynamic(discard_top/1).
:- dynamic(kartu_pemain/2).
:- dynamic(status_uni/1).
:- dynamic(efek_aktif/1).

% START GAME

startGame :-
    nl,
    minta_jumlah_pemain(N),
    minta_nama_pemain(N, [], ListNama),
    acak_list(ListNama, UrutanAcak),
    write('Urutan pemain: '),
    tampilkan_urutan(UrutanAcak),
    simpan_state_awal(UrutanAcak),
    distribusiKartu,
    write('Setiap pemain mendapatkan 7 kartu acak.'), nl,
    inisialisasiDiscardPile,
    discard_top(kartu(W, J)),
    format('Kartu discard top: ~w-~w.~n', [W, J]),
    giliran(PemainPertama),
    format('Giliran ~w.~n', [PemainPertama]).


minta_jumlah_pemain(N) :-
    write('Masukkan jumlah pemain: '),
    read(Input),
    ( integer(Input), Input >= 2, Input =< 4
    ->  N = Input
    ;   write('Mohon masukkan angka antara 2 - 4.'), nl,
        minta_jumlah_pemain(N)
    ).


minta_nama_pemain(0, Acc, Acc) :- !.

minta_nama_pemain(N, Acc, Hasil) :-
    N > 0,
    hitung_panjang(Acc, Pos0),
    Pos is Pos0 + 1,
    format('Masukkan nama pemain ~w (awali huruf besar, contoh: Malik): ', [Pos]),
    read(Nama),
    ( cek_member(Nama, Acc)
    ->  write('Nama sudah digunakan. Masukkan nama lain: '),
        minta_nama_unik(Acc, NamaValid),
        N1 is N - 1,
        minta_nama_pemain(N1, [NamaValid|Acc], Hasil)
    ;   N1 is N - 1,
        minta_nama_pemain(N1, [Nama|Acc], Hasil)
    ).

minta_nama_unik(Acc, Nama) :-
    read(Input),
    ( cek_member(Input, Acc)
    ->  write('Nama sudah digunakan. Masukkan nama lain: '),
        minta_nama_unik(Acc, Nama)
    ;   Nama = Input
    ).


simpan_state_awal(UrutanPemain) :-
    bersihkan_state,
    assertz(urutan_pemain(UrutanPemain)),
    UrutanPemain = [Pertama|_],
    assertz(giliran(Pertama)),
    assertz(arah_permainan(kanan)),
    assertz(warna_aktif(none)),
    assertz(efek_aktif(none)),
    assertz(status_uni([])).

bersihkan_state :-
    retractall(giliran(_)),
    retractall(urutan_pemain(_)),
    retractall(arah_permainan(_)),
    retractall(warna_aktif(_)),
    retractall(discard_top(_)),
    retractall(kartu_pemain(_, _)),
    retractall(status_uni(_)),
    retractall(efek_aktif(_)).


next_turn :-
    giliran(Sekarang),
    urutan_pemain(Urutan),
    arah_permainan(Arah),
    cari_pemain_berikut(Sekarang, Urutan, Arah, Berikut),
    retract(giliran(Sekarang)),
    assertz(giliran(Berikut)),
    format('Giliran ~w.~n', [Berikut]).

% arah kanan: maju ke index berikutnya, kalau sudah ujung balik ke 1
cari_pemain_berikut(Sekarang, Urutan, kanan, Berikut) :-
    cari_index(Sekarang, Urutan, 1, Idx),
    hitung_panjang(Urutan, N),
    Idx1 is Idx + 1,
    ( Idx1 > N
    ->  IdxBerikut = 1
    ;   IdxBerikut = Idx1
    ),
    ambil_ke(IdxBerikut, Urutan, Berikut).

% arah kiri: mundur ke index sebelumnya, kalau sudah ujung balik ke N
cari_pemain_berikut(Sekarang, Urutan, kiri, Berikut) :-
    cari_index(Sekarang, Urutan, 1, Idx),
    hitung_panjang(Urutan, N),
    Idx1 is Idx - 1,
    ( Idx1 < 1
    ->  IdxBerikut = N
    ;   IdxBerikut = Idx1
    ),
    ambil_ke(IdxBerikut, Urutan, Berikut).


% ACAK LIST

acak_list([], []).
acak_list(List, [Pilihan|Sisa]) :-
    hitung_panjang(List, N),
    random(0, N, Idx),
    Idx1 is Idx + 1,
    ambil_ke(Idx1, List, Pilihan),
    hapus_satu(Pilihan, List, Sisanya),
    acak_list(Sisanya, Sisa).

tampilkan_urutan([]) :- write('.'), nl.
tampilkan_urutan([P]) :- !,
    format('~w.', [P]), nl.
tampilkan_urutan([P|Rest]) :-
    format('~w - ', [P]),
    tampilkan_urutan(Rest).

set_warna_aktif(Warna) :-
    retractall(warna_aktif(_)),
    assertz(warna_aktif(Warna)).

% UTILITAS LIST

% cek_member(X, List) - cek apakah X ada di dalam List
cek_member(X, [X|_]) :- !.
cek_member(X, [_|Tail]) :-
    cek_member(X, Tail).

% hitung_panjang(List, N) - hitung jumlah elemen di List
hitung_panjang([], 0).
hitung_panjang([_|Tail], N) :-
    hitung_panjang(Tail, N1),
    N is N1 + 1.

% ambil_ke(N, List, Elemen) - ambil elemen ke-N dari List (index mulai 1)
ambil_ke(1, [H|_], H) :- !.
ambil_ke(N, [_|Tail], Hasil) :-
    N > 1,
    N1 is N - 1,
    ambil_ke(N1, Tail, Hasil).

% hapus_satu(Elemen, List, Sisa) - hapus SATU kemunculan Elemen dari List
hapus_satu(X, [X|Tail], Tail) :- !.
hapus_satu(X, [H|Tail], [H|Sisa]) :-
    hapus_satu(X, Tail, Sisa).

% cari_index(X, List, IndexAwal, Index) - cari posisi X di List (index mulai 1)
cari_index(X, [X|_], Idx, Idx) :- !.
cari_index(X, [_|Tail], Acc, Idx) :-
    Acc1 is Acc + 1,
    cari_index(X, Tail, Acc1, Idx).


