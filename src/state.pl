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
:- dynamic(kartu_tersembunyi/2).
:- dynamic(kartu_aksi_terakhir/1).

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

jumlah_valid(N) :- N == 2.
jumlah_valid(N) :- N == 3.
jumlah_valid(N) :- N == 4.

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
    baca_nama_valid(Acc, Nama),
    N1 is N - 1,
    minta_nama_pemain(N1, [Nama|Acc], Hasil).

baca_nama_valid(Acc, Nama) :-
    read(Input),
    ( nama_valid(Input)
    ->  ( cek_member(Input, Acc)
        ->  write('Nama sudah digunakan. Masukkan nama lain: '),
            baca_nama_valid(Acc, Nama)
        ;   Nama = Input
        )
    ;   write('Nama harus diawali huruf kapital dan ditulis sebagai atom, contoh: ''Malik''.'), nl,
        baca_nama_valid(Acc, Nama)
    ).

nama_valid(Nama) :-
    name(Nama, [KodeAwal|_]),
    KodeAwal >= 65,
    KodeAwal =< 90.

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
    retractall(warna_sebelum_wdf(_)),
    retractall(kartu_tersembunyi(_, _)),
    retractall(kartu_aksi_terakhir(_)).

% PINDAH GILIRAN

next_turn :-
    giliran(Sekarang),
    urutan_pemain(Urutan),
    arah_permainan(Arah),
    cari_pemain_berikut(Sekarang, Urutan, Arah, Berikut),
    retract(giliran(Sekarang)),
    assertz(giliran(Berikut)),
    format('Giliran ~w.~n', [Berikut]).

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
    ( Idx1 > N -> IdxBerikut = 1 ; IdxBerikut = Idx1 ),
    ambil_ke(IdxBerikut, Urutan, Berikut).

cari_pemain_berikut(Sekarang, Urutan, kiri, Berikut) :-
    cari_index(Sekarang, Urutan, 1, Idx),
    hitung_panjang(Urutan, N),
    Idx1 is Idx - 1,
    ( Idx1 < 1 -> IdxBerikut = N ; IdxBerikut = Idx1 ),
    ambil_ke(IdxBerikut, Urutan, Berikut).

balik_arah :-
    arah_permainan(Arah),
    retract(arah_permainan(Arah)),
    ( Arah = kanan -> ArahBaru = kiri ; ArahBaru = kanan ),
    assertz(arah_permainan(ArahBaru)).

pilih_warna_baru :-
    write('Pilih warna (merah/kuning/hijau/biru): '),
    read(Warna),
    ( cek_member(Warna, [merah, kuning, hijau, biru])
    ->  set_warna_aktif(Warna),
        format('Warna aktif sekarang: ~w.~n', [Warna])
    ;   write('Warna tidak valid.'), nl,
        pilih_warna_baru
    ).

% STATUS UNI DAN KARTU PEMAIN

kartu_tersembunyi_opt(Pemain, ada(Kartu)) :-
    kartu_tersembunyi(Pemain, Kartu),
    !.
kartu_tersembunyi_opt(_, tidak_ada).

gabung_kartu_tersembunyi(ListKartu, tidak_ada, ListKartu).
gabung_kartu_tersembunyi(ListKartu, ada(Kartu), SemuaKartu) :-
    tambah_akhir(ListKartu, Kartu, SemuaKartu).

semua_kartu_pemain(Pemain, SemuaKartu) :-
    kartu_pemain(Pemain, ListKartu),
    kartu_tersembunyi_opt(Pemain, Hidden),
    gabung_kartu_tersembunyi(ListKartu, Hidden, SemuaKartu).

jumlah_kartu_total(Pemain, Jumlah) :-
    semua_kartu_pemain(Pemain, SemuaKartu),
    hitung_panjang(SemuaKartu, Jumlah).

simpan_kartu_pemain(Pemain, ListBaru, HiddenBaru) :-
    retractall(kartu_pemain(Pemain, _)),
    assertz(kartu_pemain(Pemain, ListBaru)),
    retractall(kartu_tersembunyi(Pemain, _)),
    simpan_hidden(Pemain, HiddenBaru).

simpan_hidden(_, tidak_ada) :- !.
simpan_hidden(Pemain, ada(Kartu)) :-
    assertz(kartu_tersembunyi(Pemain, Kartu)).

pilih_kartu_pemain(Pemain, Nomor, Kartu, ListBaru, HiddenBaru, SisaSemua) :-
    kartu_pemain(Pemain, ListKartu),
    kartu_tersembunyi_opt(Pemain, HiddenLama),
    hitung_panjang(ListKartu, JumlahTerlihat),
    ( Nomor =< JumlahTerlihat
    ->  ambil_dan_hapus_kartu(Nomor, ListKartu, Kartu, ListBaru),
        HiddenBaru = HiddenLama
    ;   NomorHidden is JumlahTerlihat + 1,
        Nomor =:= NomorHidden,
        HiddenLama = ada(Kartu),
        ListBaru = ListKartu,
        HiddenBaru = tidak_ada
    ),
    gabung_kartu_tersembunyi(ListBaru, HiddenBaru, SisaSemua).

tambah_banyak_kartu_pemain(Pemain, KartuBaru) :-
    kartu_pemain(Pemain, ListLama),
    gabung_list(KartuBaru, ListLama, ListBaru),
    retract(kartu_pemain(Pemain, ListLama)),
    assertz(kartu_pemain(Pemain, ListBaru)),
    hapus_status_uni(Pemain).

tambah_satu_kartu_pemain(Pemain, KartuBaru) :-
    tambah_banyak_kartu_pemain(Pemain, [KartuBaru]).

hapus_status_uni(Pemain) :-
    status_uni(ListUNI),
    hapus_semua(Pemain, ListUNI, ListBaru),
    retract(status_uni(ListUNI)),
    assertz(status_uni(ListBaru)).

% END GAME

endGame :-
    urutan_pemain(Urutan),
    write('Berikut perhitungan poin sisa kartu.'), nl,
    hitung_poin_semua(Urutan),
    nl,
    kumpul_peringkat_semua(Urutan, 1, ListPeringkat),
    urutkan_peringkat(ListPeringkat, Peringkat),
    write('Urutan pemenang:'), nl,
    tampilkan_peringkat(Peringkat, 1),
    Peringkat = [peringkat(_, _, _, Pemenang)|_],
    format('Selamat, ~w menjadi pemenang!~n', [Pemenang]).

hitung_poin_semua([]).
hitung_poin_semua([Pemain|Rest]) :-
    semua_kartu_pemain(Pemain, ListKartu),
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

hitung_total_poin([], 0).
hitung_total_poin([K|Rest], Total) :-
    nilai_kartu(K, Poin),
    hitung_total_poin(Rest, TotalRest),
    Total is Poin + TotalRest.

kumpul_peringkat_semua([], _, []).
kumpul_peringkat_semua([Pemain|Rest], UrutanAwal, [peringkat(Total, JumlahKartu, UrutanAwal, Pemain)|RestPoin]) :-
    semua_kartu_pemain(Pemain, ListKartu),
    hitung_panjang(ListKartu, JumlahKartu),
    hitung_total_poin(ListKartu, Total),
    UrutanNext is UrutanAwal + 1,
    kumpul_peringkat_semua(Rest, UrutanNext, RestPoin).

urutkan_peringkat([], []).
urutkan_peringkat([H|T], Hasil) :-
    urutkan_peringkat(T, TSorted),
    sisipkan_peringkat(H, TSorted, Hasil).

sisipkan_peringkat(X, [], [X]).
sisipkan_peringkat(X, [H|T], [X,H|T]) :-
    peringkat_lebih_baik(X, H),
    !.
sisipkan_peringkat(X, [H|T], [H|Hasil]) :-
    sisipkan_peringkat(X, T, Hasil).

peringkat_lebih_baik(peringkat(P1, _, _, _), peringkat(P2, _, _, _)) :-
    P1 < P2,
    !.
peringkat_lebih_baik(peringkat(P1, J1, _, _), peringkat(P2, J2, _, _)) :-
    P1 =:= P2,
    J1 < J2,
    !.
peringkat_lebih_baik(peringkat(P1, J1, U1, _), peringkat(P2, J2, U2, _)) :-
    P1 =:= P2,
    J1 =:= J2,
    U1 < U2.

tampilkan_peringkat([], _).
tampilkan_peringkat([peringkat(Total, _, _, Pemain)|Rest], N) :-
    format('~w. ~w (~w poin)~n', [N, Pemain, Total]),
    N1 is N + 1,
    tampilkan_peringkat(Rest, N1).

% SAVE GAME

saveGame :-
    efek_aktif(none),
    !,
    write('Masukkan nama file penyimpanan (contoh: permainan1): '),
    read(NamaFile),
    nama_file_txt(NamaFile, NamaFileTxt),
    open(NamaFileTxt, write, Stream),
    urutan_pemain(Urutan),
    write(Stream, 'urutan_pemain:'),
    tulis_list_pemain(Stream, Urutan),
    write(Stream, '.'), nl(Stream),
    giliran(Giliran),
    write(Stream, 'giliran:'),
    tulis_nama_pemain(Stream, Giliran),
    write(Stream, '.'), nl(Stream),
    discard_top(Kartu),
    write(Stream, 'discard_top:'),
    tulis_kartu_save(Stream, Kartu),
    write(Stream, '.'), nl(Stream),
    warna_aktif(Warna),
    write(Stream, 'warna_aktif:'), write(Stream, Warna), write(Stream, '.'), nl(Stream),
    arah_permainan(Arah),
    write(Stream, 'arah_permainan:'), write(Stream, Arah), write(Stream, '.'), nl(Stream),
    status_uni(ListUNI),
    write(Stream, 'status_UNI:'),
    tulis_list_pemain(Stream, ListUNI),
    write(Stream, '.'), nl(Stream),
    tulis_kartu_semua_pemain(Stream, Urutan),
    tulis_kartu_tersembunyi_semua(Stream, Urutan),
    tulis_kartu_aksi_terakhir(Stream),
    close(Stream),
    format('Status permainan berhasil disimpan ke ~w.~n', [NamaFileTxt]),
    bersihkan_state.

saveGame :-
    write('Tidak dapat menyimpan permainan ketika ada efek kartu yang harus diselesaikan.'), nl.

tulis_kartu_semua_pemain(_, []).
tulis_kartu_semua_pemain(Stream, [Pemain|Rest]) :-
    kartu_pemain(Pemain, ListKartu),
    write(Stream, 'kartu('),
    tulis_nama_pemain(Stream, Pemain),
    write(Stream, '):'),
    tulis_list_kartu(Stream, ListKartu),
    write(Stream, '.'),
    nl(Stream),
    tulis_kartu_semua_pemain(Stream, Rest).

tulis_kartu_tersembunyi_semua(_, []).
tulis_kartu_tersembunyi_semua(Stream, [Pemain|Rest]) :-
    ( kartu_tersembunyi(Pemain, Kartu)
    ->  write(Stream, 'kartu_tersembunyi('),
        tulis_nama_pemain(Stream, Pemain),
        write(Stream, '):'),
        tulis_kartu_save(Stream, Kartu),
        write(Stream, '.'),
        nl(Stream)
    ;   true
    ),
    tulis_kartu_tersembunyi_semua(Stream, Rest).

tulis_kartu_aksi_terakhir(Stream) :-
    ( kartu_aksi_terakhir(Kartu)
    ->  write(Stream, 'kartu_aksi_terakhir:'),
        tulis_kartu_save(Stream, Kartu),
        write(Stream, '.'),
        nl(Stream)
    ;   write(Stream, 'kartu_aksi_terakhir:none.'),
        nl(Stream)
    ).

tulis_nama_pemain(Stream, Nama) :-
    write(Stream, ''''),
    write(Stream, Nama),
    write(Stream, '''').

tulis_list_pemain(Stream, []) :-
    write(Stream, '[]').
tulis_list_pemain(Stream, [P|Rest]) :-
    write(Stream, '['),
    tulis_isi_list_pemain(Stream, [P|Rest]),
    write(Stream, ']').

tulis_isi_list_pemain(Stream, [P]) :- !,
    tulis_nama_pemain(Stream, P).
tulis_isi_list_pemain(Stream, [P|Rest]) :-
    tulis_nama_pemain(Stream, P),
    write(Stream, ','),
    tulis_isi_list_pemain(Stream, Rest).

tulis_list_kartu(Stream, []) :-
    write(Stream, '[]').
tulis_list_kartu(Stream, [K|Rest]) :-
    write(Stream, '['),
    tulis_isi_list_kartu(Stream, [K|Rest]),
    write(Stream, ']').

tulis_isi_list_kartu(Stream, [K]) :- !,
    tulis_kartu_save(Stream, K).
tulis_isi_list_kartu(Stream, [K|Rest]) :-
    tulis_kartu_save(Stream, K),
    write(Stream, ','),
    tulis_isi_list_kartu(Stream, Rest).

tulis_kartu_save(Stream, kartu(W, J)) :-
    write(Stream, W),
    write(Stream, '-'),
    write(Stream, J).

% LOAD GAME

loadGame :-
    giliran(_),
    !,
    write('loadGame hanya dapat dilakukan sebelum startGame atau setelah permainan dihentikan.'), nl.

loadGame :-
    write('Masukkan nama file yang akan dimuat (contoh: permainan1): '),
    read(NamaFile),
    nama_file_txt(NamaFile, NamaFileTxt),
    ( file_exists(NamaFileTxt)
    ->  open(NamaFileTxt, read, Stream),
        bersihkan_state,
        baca_semua_term(Stream),
        close(Stream),
        pastikan_state_default,
        format('Status permainan berhasil dimuat dari ~w.~n', [NamaFileTxt]),
        giliran(Lanjut),
        format('Melanjutkan giliran ~w.~n', [Lanjut])
    ;   format('File ~w tidak ditemukan.~n', [NamaFileTxt])
    ).

baca_semua_term(Stream) :-
    read(Stream, Term),
    ( Term = end_of_file
    ->  true
    ;   proses_term(Term),
        baca_semua_term(Stream)
    ).

proses_term(urutan_pemain:ListPemain) :- !,
    assertz(urutan_pemain(ListPemain)).
proses_term(giliran:Pemain) :- !,
    assertz(giliran(Pemain)).
proses_term(discard_top:TermKartu) :- !,
    term_ke_kartu(TermKartu, Kartu),
    assertz(discard_top(Kartu)).
proses_term(warna_aktif:Warna) :- !,
    assertz(warna_aktif(Warna)).
proses_term(arah_permainan:Arah) :- !,
    assertz(arah_permainan(Arah)).
proses_term(status_UNI:ListUNI) :- !,
    assertz(status_uni(ListUNI)).
proses_term(kartu(Pemain):ListTermKartu) :- !,
    list_term_ke_kartu(ListTermKartu, ListKartu),
    assertz(kartu_pemain(Pemain, ListKartu)).
proses_term(kartu_tersembunyi(Pemain):TermKartu) :- !,
    term_ke_kartu(TermKartu, Kartu),
    assertz(kartu_tersembunyi(Pemain, Kartu)).
proses_term(kartu_aksi_terakhir:none) :- !.
proses_term(kartu_aksi_terakhir:TermKartu) :- !,
    term_ke_kartu(TermKartu, Kartu),
    assertz(kartu_aksi_terakhir(Kartu)).
proses_term(_).

pastikan_state_default :-
    ( status_uni(_) -> true ; assertz(status_uni([])) ),
    ( efek_aktif(_) -> true ; assertz(efek_aktif(none)) ).

term_ke_kartu(Warna-Jenis, kartu(Warna, Jenis)).

list_term_ke_kartu([], []).
list_term_ke_kartu([Term|Rest], [Kartu|RestKartu]) :-
    term_ke_kartu(Term, Kartu),
    list_term_ke_kartu(Rest, RestKartu).

nama_file_txt(NamaFile, NamaFileTxt) :-
    name(NamaFile, ListChar),
    tambah_ext_txt(ListChar, ListCharTxt),
    name(NamaFileTxt, ListCharTxt).

tambah_ext_txt([], [46,116,120,116]).
tambah_ext_txt([H|T], [H|Rest]) :-
    tambah_ext_txt(T, Rest).

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

hapus_semua(_, [], []).
hapus_semua(X, [X|Tail], Hasil) :- !,
    hapus_semua(X, Tail, Hasil).
hapus_semua(X, [H|Tail], [H|Hasil]) :-
    hapus_semua(X, Tail, Hasil).

cari_index(X, [X|_], Idx, Idx) :- !.
cari_index(X, [_|Tail], Acc, Idx) :-
    Acc1 is Acc + 1,
    cari_index(X, Tail, Acc1, Idx).

gabung_list([], L, L).
gabung_list([H|T], L, [H|R]) :-
    gabung_list(T, L, R).

tambah_akhir([], X, [X]).
tambah_akhir([H|T], X, [H|R]) :-
    tambah_akhir(T, X, R).
