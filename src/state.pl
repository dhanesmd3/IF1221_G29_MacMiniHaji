% FAKTA DINAMIS
:- dynamic(giliran/1).
:- dynamic(urutan_pemain/1).
:- dynamic(arah_permainan/1).
:- dynamic(warna_aktif/1).
:- dynamic(discard_top/1).
:- dynamic(kartu_pemain/2).
:- dynamic(status_uni/1).
:- dynamic(efek_aktif/1).
:- dynamic(discard_sebelum_wdf/1).
:- dynamic(warna_sebelum_wdf/1).

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

jumlah_valid(2).
jumlah_valid(3).
jumlah_valid(4).

minta_jumlah_pemain(N) :-
    write('Masukkan jumlah pemain: '),
    read(Input),
    ( jumlah_valid(Input)
    ->  N = Input
    ;   write('Mohon masukkan angka antara 2 - 4.'), nl,
        minta_jumlah_pemain(N)
    ).

minta_nama_pemain(0, Acc, Acc) :- !.

minta_nama_pemain(N, Acc, Hasil) :-
    N > 0,
    hitung_panjang(Acc, Pos0),
    Pos is Pos0 + 1,
    format('Masukkan nama pemain ~w (gunakan petik, contoh: ''Malik''): ', [Pos]),
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
    retractall(efek_aktif(_)),
    retractall(discard_sebelum_wdf(_)),
    retractall(warna_sebelum_wdf(_)).

% PINDAH GILIRAN

next_turn :-
    giliran(Sekarang),
    urutan_pemain(Urutan),
    arah_permainan(Arah),
    cari_pemain_berikut(Sekarang, Urutan, Arah, Berikut),
    retract(giliran(Sekarang)),
    assertz(giliran(Berikut)),
    format('Giliran ~w.~n', [Berikut]).

% pindah giliran tapi lewati satu pemain (efek skip)
next_turn_skip :-
    giliran(Sekarang),
    urutan_pemain(Urutan),
    arah_permainan(Arah),
    cari_pemain_berikut(Sekarang, Urutan, Arah, Lewat),
    cari_pemain_berikut(Lewat, Urutan, Arah, Berikut),
    retract(giliran(Sekarang)),
    assertz(giliran(Berikut)),
    write('Pemain berikutnya kehilangan giliran.'), nl,
    format('Giliran ~w.~n', [Berikut]).

cari_pemain_berikut(Sekarang, Urutan, kanan, Berikut) :-
    cari_index(Sekarang, Urutan, 1, Idx),
    hitung_panjang(Urutan, N),
    Idx1 is Idx + 1,
    ( Idx1 > N
    ->  IdxBerikut = 1
    ;   IdxBerikut = Idx1
    ),
    ambil_ke(IdxBerikut, Urutan, Berikut).

cari_pemain_berikut(Sekarang, Urutan, kiri, Berikut) :-
    cari_index(Sekarang, Urutan, 1, Idx),
    hitung_panjang(Urutan, N),
    Idx1 is Idx - 1,
    ( Idx1 < 1
    ->  IdxBerikut = N
    ;   IdxBerikut = Idx1
    ),
    ambil_ke(IdxBerikut, Urutan, Berikut).

% balik arah permainan (efek reverse)
balik_arah :-
    arah_permainan(Arah),
    retract(arah_permainan(Arah)),
    ( Arah = kanan
    ->  ArahBaru = kiri
    ;   ArahBaru = kanan
    ),
    assertz(arah_permainan(ArahBaru)).

% minta pemain pilih warna baru setelah mainkan wild
pilih_warna_baru :-
    write('Pilih warna (merah/kuning/hijau/biru): '),
    read(Warna),
    ( cek_member(Warna, [merah, kuning, hijau, biru])
    ->  set_warna_aktif(Warna),
        format('Warna aktif sekarang: ~w.~n', [Warna])
    ;   write('Warna tidak valid.'), nl,
        pilih_warna_baru
    ).

% END GAME

endGame :-
    urutan_pemain(Urutan),
    write('Berikut perhitungan poin sisa kartu.'), nl,
    hitung_poin_semua(Urutan),
    nl,
    kumpul_poin_semua(Urutan, ListPoin),
    urutkan_peringkat(ListPoin, Peringkat),
    write('Urutan pemenang:'), nl,
    tampilkan_peringkat(Peringkat, 1),
    Peringkat = [poin(_, Pemenang)|_],
    format('Selamat, ~w menjadi pemenang!~n', [Pemenang]).

% hitung dan tampilkan poin tiap pemain
hitung_poin_semua([]).
hitung_poin_semua([Pemain|Rest]) :-
    kartu_pemain(Pemain, ListKartu),
    ( ListKartu = []
    ->  format('~w: kartu habis = 0 poin~n', [Pemain])
    ;   hitung_total_poin(ListKartu, Total),
        tampilkan_detail_poin(Pemain, ListKartu, Total)
    ),
    hitung_poin_semua(Rest).

tampilkan_detail_poin(Pemain, ListKartu, Total) :-
    write(Pemain), write(': '),
    tampilkan_kartu_poin(ListKartu),
    format(' = ~w poin~n', [Total]).

tampilkan_kartu_poin([kartu(W,J)]) :- !,
    format('~w-~w', [W, J]).
tampilkan_kartu_poin([kartu(W,J)|Rest]) :-
    format('~w-~w + ', [W, J]),
    tampilkan_kartu_poin(Rest).

% hitung total poin dari list kartu
hitung_total_poin([], 0).
hitung_total_poin([K|Rest], Total) :-
    nilai_kartu(K, Poin),
    hitung_total_poin(Rest, TotalRest),
    Total is Poin + TotalRest.

kumpul_poin_semua([], []).
kumpul_poin_semua([Pemain|Rest], [poin(Total, Pemain)|RestPoin]) :-
    kartu_pemain(Pemain, ListKartu),
    hitung_total_poin(ListKartu, Total),
    kumpul_poin_semua(Rest, RestPoin).

% urutkan peringkat dari poin terkecil ke terbesar (insertion sort)
urutkan_peringkat([], []).
urutkan_peringkat([H|T], Hasil) :-
    urutkan_peringkat(T, TSorted),
    sisipkan_poin(H, TSorted, Hasil).

sisipkan_poin(X, [], [X]).
sisipkan_poin(poin(P1,N1), [poin(P2,N2)|Rest], [poin(P1,N1),poin(P2,N2)|Rest]) :-
    P1 =< P2, !.
sisipkan_poin(X, [H|T], [H|Hasil]) :-
    sisipkan_poin(X, T, Hasil).

% tampilkan peringkat
tampilkan_peringkat([], _).
tampilkan_peringkat([poin(Total, Pemain)|Rest], N) :-
    format('~w. ~w (~w poin)~n', [N, Pemain, Total]),
    N1 is N + 1,
    tampilkan_peringkat(Rest, N1).

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

cek_member(X, [X|_]) :- !.
cek_member(X, [_|Tail]) :-
    cek_member(X, Tail).

hitung_panjang([], 0).
hitung_panjang([_|Tail], N) :-
    hitung_panjang(Tail, N1),
    N is N1 + 1.

ambil_ke(1, [H|_], H) :- !.
ambil_ke(N, [_|Tail], Hasil) :-
    N > 1,
    N1 is N - 1,
    ambil_ke(N1, Tail, Hasil).

hapus_satu(X, [X|Tail], Tail) :- !.
hapus_satu(X, [H|Tail], [H|Sisa]) :-
    hapus_satu(X, Tail, Sisa).

cari_index(X, [X|_], Idx, Idx) :- !.
cari_index(X, [_|Tail], Acc, Idx) :-
    Acc1 is Acc + 1,
    cari_index(X, Tail, Acc1, Idx).
