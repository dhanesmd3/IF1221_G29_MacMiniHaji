% Cek apakah sesuatu termasuk angka 0-9
% (dipakai buat validasi kartu angka)
is_angka(0). is_angka(1). is_angka(2). is_angka(3). is_angka(4).
is_angka(5). is_angka(6). is_angka(7). is_angka(8). is_angka(9).

% Menghitung panjang list
% Pengganti bawaan length/2
panjang([], 0).
panjang([_|T], N) :-
    panjang(T, N1),
    N is N1 + 1.

% Mengambil elemen list berdasarkan index (0-based)
ambil_ke(0, [X|_], X) :- !.
ambil_ke(N, [_|T], X) :-
    N > 0,
    N1 is N - 1,
    ambil_ke(N1, T, X).

% Mengembalikan semua kartu valid dalam bentuk list
semua_kartu(L) :-
    kumpul_kartu(L).

% Isi seluruh deck UNO
kumpul_kartu([
    kartu(merah,0), kartu(merah,1), kartu(merah,2), kartu(merah,3), kartu(merah,4),
    kartu(merah,5), kartu(merah,6), kartu(merah,7), kartu(merah,8), kartu(merah,9),

    kartu(kuning,0), kartu(kuning,1), kartu(kuning,2), kartu(kuning,3), kartu(kuning,4),
    kartu(kuning,5), kartu(kuning,6), kartu(kuning,7), kartu(kuning,8), kartu(kuning,9),

    kartu(hijau,0), kartu(hijau,1), kartu(hijau,2), kartu(hijau,3), kartu(hijau,4),
    kartu(hijau,5), kartu(hijau,6), kartu(hijau,7), kartu(hijau,8), kartu(hijau,9),

    kartu(biru,0),  kartu(biru,1),  kartu(biru,2),  kartu(biru,3),  kartu(biru,4),
    kartu(biru,5),  kartu(biru,6),  kartu(biru,7),  kartu(biru,8),  kartu(biru,9),

    % Kartu aksi
    kartu(merah,skip), kartu(kuning,skip), kartu(hijau,skip), kartu(biru,skip),
    kartu(merah,reverse), kartu(kuning,reverse), kartu(hijau,reverse), kartu(biru,reverse),
    kartu(merah,draw_two), kartu(kuning,draw_two), kartu(hijau,draw_two), kartu(biru,draw_two),

    % Kartu wild
    kartu(hitam,wild),
    kartu(hitam,wild_draw_four)
]).



% Validasi kartu


% Mengecek apakah kartu termasuk kartu yang valid
kartu_valid(K) :-
    semua_kartu(L),
    anggota(K, L).

% Versi sederhana member/2
anggota(X, [X|_]).
anggota(X, [_|T]) :-
    anggota(X, T).



% Jenis kartu


% Kartu angka
kartu_angka(kartu(_, J)) :-
    is_angka(J).

% Kartu aksi
kartu_aksi(kartu(_, skip)).
kartu_aksi(kartu(_, reverse)).
kartu_aksi(kartu(_, draw_two)).

% Kartu wild
kartu_wild(kartu(hitam, wild)).
kartu_wild(kartu(hitam, wild_draw_four)).

% Kartu pertama di discard pile
% harus berupa kartu angka
kartu_awal_valid(K) :-
    kartu_angka(K).


% Nilai kartu

% Nilai kartu angka = angka itu sendiri
nilai_kartu(kartu(_, J), J) :-
    is_angka(J), !.

% Nilai kartu aksi
nilai_kartu(kartu(_, skip), 10).
nilai_kartu(kartu(_, reverse), 10).
nilai_kartu(kartu(_, draw_two), 10).

% Nilai kartu wild
nilai_kartu(kartu(hitam, wild), 20).
nilai_kartu(kartu(hitam, wild_draw_four), 20).



% Distribusi kartu pemain


% Membagikan 7 kartu ke semua pemain
distribusiKartu :-
    urutan_pemain(ListPemain),
    bagikan_ke_semua(ListPemain).

% Basis rekursi
bagikan_ke_semua([]).

% Ambil 7 kartu untuk tiap pemain
bagikan_ke_semua([Pemain|Rest]) :-
    ambil_kartu_acak(7, [], TujuhKartu),
    assertz(kartu_pemain(Pemain, TujuhKartu)),
    bagikan_ke_semua(Rest).

% Mengambil N kartu random
ambil_kartu_acak(0, Acc, Acc) :- !.

ambil_kartu_acak(N, Acc, Hasil) :-
    N > 0,
    kartu_acak(K),
    N1 is N - 1,
    ambil_kartu_acak(N1, [K|Acc], Hasil).

% Mengambil 1 kartu random dari deck
kartu_acak(K) :-
    semua_kartu(SemuaKartu),
    panjang(SemuaKartu, Total),
    random(0, Total, Idx),
    ambil_ke(Idx, SemuaKartu, K).



% Inisialisasi discard pile

% Mengambil kartu awal untuk discard pile
% Kartu pertama harus kartu angka
inisialisasiDiscardPile :-
    kartu_acak(K),
    ( kartu_awal_valid(K)
    ->  assertz(discard_top(K)),
        K = kartu(W, _),
        set_warna_aktif(W)
    ;   inisialisasiDiscardPile
    ).