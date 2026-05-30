% aksi.pl - aksi utama permainan

aksi_boleh :-
    efek_aktif(none),
    !.
aksi_boleh :-
    write('Masih ada efek kartu yang harus diselesaikan. Gunakan command yang sesuai.'), nl,
    fail.

mainkanKartu(Nomor) :-
    aksi_boleh,
    giliran(Pemain),
    ( pilih_kartu_pemain(Pemain, Nomor, Kartu, ListBaru, HiddenBaru, SisaSemua)
    ->  true
    ;   write('Nomor kartu tidak valid.'), nl,
        fail
    ),
    ( bisa_dimainkan(Kartu, SisaSemua)
    ->  true
    ;   write('Kartu tidak bisa dimainkan.'), nl,
        fail
    ),
    discard_top(DiscardLama),
    retractall(discard_sebelum_wdf(_)),
    assertz(discard_sebelum_wdf(DiscardLama)),
    simpan_kartu_pemain(Pemain, ListBaru, HiddenBaru),
    retract(discard_top(_)),
    assertz(discard_top(Kartu)),
    Kartu = kartu(Warna, Jenis),
    format('~w memainkan kartu: ~w-~w.~n', [Pemain, Warna, Jenis]),
    catat_kartu_aksi(Kartu),
    ( SisaSemua = []
    ->  format('~w menghabiskan semua kartunya!~n', [Pemain]),
        endGame
    ;   terapkan_efek(Kartu)
    ).

ambil_dan_hapus_kartu(1, [Head|Tail], Head, Tail) :- !.
ambil_dan_hapus_kartu(N, [Head|Tail], Kartu, [Head|TailSisa]) :-
    N > 1,
    N1 is N - 1,
    ambil_dan_hapus_kartu(N1, Tail, Kartu, TailSisa).

bisa_dimainkan(kartu(hitam, wild_draw_four), _) :-
    !,
    \+ discard_top(kartu(hitam, wild_draw_four)).
bisa_dimainkan(kartu(hitam, wild), _) :-
    !,
    \+ discard_top(kartu(hitam, wild)).
bisa_dimainkan(kartu(hitam, mimic), _) :-
    !.
bisa_dimainkan(kartu(Warna, draw_two), _) :-
    !,
    \+ discard_top(kartu(_, draw_two)),
    warna_aktif(Warna).
bisa_dimainkan(kartu(Warna, _), _) :-
    warna_aktif(Warna),
    !.
bisa_dimainkan(kartu(_, Jenis), _) :-
    discard_top(kartu(_, Jenis)),
    !.

terapkan_efek(kartu(Warna, N)) :-
    is_angka(N),
    !,
    set_warna_aktif(Warna),
    next_turn.
terapkan_efek(kartu(Warna, skip)) :-
    !,
    set_warna_aktif(Warna),
    next_turn_skip.
terapkan_efek(kartu(Warna, reverse)) :-
    !,
    set_warna_aktif(Warna),
    balik_arah,
    next_turn.
terapkan_efek(kartu(Warna, draw_two)) :-
    !,
    set_warna_aktif(Warna),
    mulai_efek_ambil(draw_two).
terapkan_efek(kartu(hitam, wild)) :-
    !,
    pilih_warna_baru,
    next_turn.
terapkan_efek(kartu(hitam, wild_draw_four)) :-
    !,
    warna_aktif(WarnaLama),
    retractall(warna_sebelum_wdf(_)),
    assertz(warna_sebelum_wdf(WarnaLama)),
    pilih_warna_baru,
    mulai_efek_ambil(wild_draw_four).
terapkan_efek(kartu(hitam, mimic)) :-
    !,
    giliran(Pemain),
    terapkan_efek_mimic(Pemain).

mulai_efek_ambil(Efek) :-
    retractall(efek_aktif(_)),
    assertz(efek_aktif(Efek)),
    giliran(Sekarang),
    urutan_pemain(Urutan),
    arah_permainan(Arah),
    cari_pemain_berikut(Sekarang, Urutan, Arah, Berikut),
    retract(giliran(Sekarang)),
    assertz(giliran(Berikut)),
    pesan_efek_ambil(Efek, Berikut).

pesan_efek_ambil(draw_two, Berikut) :-
    format('Giliran ~w. Ketik ambilKartu untuk mengambil 2 kartu.~n', [Berikut]).
pesan_efek_ambil(wild_draw_four, Berikut) :-
    format('Giliran ~w. Ketik ambilKartu. atau tantang.~n', [Berikut]).

ambilKartu :-
    giliran(Pemain),
    efek_aktif(wild_draw_four),
    !,
    ambil_kartu_acak(4, [], EmpatKartu),
    tambah_banyak_kartu_pemain(Pemain, EmpatKartu),
    retractall(efek_aktif(_)),
    assertz(efek_aktif(none)),
    format('~w mendapatkan 4 kartu.~n', [Pemain]),
    next_turn.

ambilKartu :-
    giliran(Pemain),
    efek_aktif(draw_two),
    !,
    ambil_kartu_acak(2, [], DuaKartu),
    tambah_banyak_kartu_pemain(Pemain, DuaKartu),
    retractall(efek_aktif(_)),
    assertz(efek_aktif(none)),
    format('~w mendapatkan 2 kartu.~n', [Pemain]),
    next_turn.

ambilKartu :-
    efek_aktif(none),
    !,
    giliran(Pemain),
    kartu_acak(KartuBaru),
    tambah_satu_kartu_pemain(Pemain, KartuBaru),
    KartuBaru = kartu(W, J),
    format('~w mendapatkan kartu: ~w-~w.~n', [Pemain, W, J]),
    next_turn.

ambilKartu :-
    write('Command ambilKartu tidak sesuai dengan efek kartu saat ini.'), nl.

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
    semua_kartu_pemain(Tertantang, ListKartuTertantang),
    warna_sebelum_wdf(WarnaSebelum),
    discard_sebelum_wdf(kartu(_, JenisSebelum)),
    proses_tantang(ListKartuTertantang, WarnaSebelum, JenisSebelum, Penantang, Tertantang).

tantang :-
    write('Tidak ada wild draw four yang bisa ditantang.'), nl.

proses_tantang(ListKartuTertantang, WarnaSebelum, JenisSebelum, _Penantang, Tertantang) :-
    ada_kartu_cocok_tantang(ListKartuTertantang, WarnaSebelum, JenisSebelum),
    !,
    ambil_kartu_acak(4, [], EmpatKartu),
    tambah_banyak_kartu_pemain(Tertantang, EmpatKartu),
    retractall(efek_aktif(_)),
    assertz(efek_aktif(none)),
    format('Tantangan berhasil! ~w mendapatkan 4 kartu acak.~n', [Tertantang]),
    next_turn.

proses_tantang(_ListKartuTertantang, _WarnaSebelum, _JenisSebelum, Penantang, _Tertantang) :-
    ambil_kartu_acak(6, [], EnamKartu),
    tambah_banyak_kartu_pemain(Penantang, EnamKartu),
    retractall(efek_aktif(_)),
    assertz(efek_aktif(none)),
    format('Tantangan gagal. ~w mendapatkan 6 kartu acak.~n', [Penantang]),
    next_turn.

ada_kartu_cocok_tantang([kartu(W, _)|_], W, _) :- !.
ada_kartu_cocok_tantang([kartu(_, J)|_], _, JenisSebelum) :-
    is_angka(JenisSebelum),
    is_angka(J),
    J =:= JenisSebelum,
    !.
ada_kartu_cocok_tantang([_|Rest], W, J) :-
    ada_kartu_cocok_tantang(Rest, W, J).

arah_kebalikan(kanan, kiri).
arah_kebalikan(kiri, kanan).

uni(Nomor) :-
    aksi_boleh,
    giliran(Pemain),
    jumlah_kartu_total(Pemain, Jumlah),
    ( Jumlah =:= 2
    ->  ( pilih_kartu_pemain(Pemain, Nomor, Kartu, ListBaru, HiddenBaru, SisaSemua)
        ->  ( bisa_dimainkan(Kartu, SisaSemua)
            ->  discard_top(DiscardLama),
                retractall(discard_sebelum_wdf(_)),
                assertz(discard_sebelum_wdf(DiscardLama)),
                simpan_kartu_pemain(Pemain, ListBaru, HiddenBaru),
                retract(discard_top(_)),
                assertz(discard_top(Kartu)),
                Kartu = kartu(Warna, Jenis),
                format('~w memainkan kartu: ~w-~w.~n', [Pemain, Warna, Jenis]),
                format('~w menyerukan UNI!~n', [Pemain]),
                catat_kartu_aksi(Kartu),
                status_uni(ListUNI),
                retract(status_uni(ListUNI)),
                assertz(status_uni([Pemain|ListUNI])),
                ( SisaSemua = []
                ->  format('~w menghabiskan semua kartunya!~n', [Pemain]),
                    endGame
                ;   terapkan_efek(Kartu)
                )
            ;   write('Kartu tidak bisa dimainkan.'), nl,
                penalti_uni(Pemain)
            )
        ;   write('Nomor kartu tidak valid.'), nl,
            penalti_uni(Pemain)
        )
    ;   write('Perintah uni tidak valid. Kartu harus berjumlah 2.'), nl,
        penalti_uni(Pemain)
    ).

penalti_uni(Pemain) :-
    kartu_acak(KartuPenalti),
    tambah_satu_kartu_pemain(Pemain, KartuPenalti),
    write('Mendapatkan 1 kartu penalti.'), nl,
    next_turn.

tangkap(NamaPemain) :-
    aksi_boleh,
    giliran(Penangkap),
    status_uni(ListUNI),
    ( jumlah_kartu_total(NamaPemain, Jumlah),
      Jumlah =:= 1,
      \+ cek_member(NamaPemain, ListUNI) ->
        ambil_kartu_acak(2, [], DuaKartu),
        tambah_banyak_kartu_pemain(NamaPemain, DuaKartu),
        format('~w tertangkap tidak menyerukan UNI.~n', [NamaPemain]),
        format('~w mendapatkan 2 kartu penalti.~n', [NamaPemain]),
        next_turn
    ;   ( kartu_tersembunyi(NamaPemain, _) ->
            write('Terdapat kartu yang disembunyikan oleh '),
            write(NamaPemain), write('.'), nl
        ;   true
        ),
        write('Perintah tangkap tidak valid.'), nl,
        kartu_acak(KartuPenalti),
        tambah_satu_kartu_pemain(Penangkap, KartuPenalti),
        format('~w mendapatkan 1 kartu penalti.~n', [Penangkap]),
        next_turn
    ).

update_warna_aktif(hitam) :- !,
    pilih_warna_baru.
update_warna_aktif(Warna) :-
    set_warna_aktif(Warna).
