% bonus_kartu_tersembunyi.pl
% Pemain dapat menyembunyikan satu kartu. Kartu tersembunyi tetap bagian
% dari tangan pemain, tetap dihitung, dan tetap dapat dimainkan.

% SEMBUNYIKAN KARTU

sembunyikanKartu(N) :-
    aksi_boleh,
    giliran(Pemain),
    jumlah_kartu_total(Pemain, JumlahTotal),
    kartu_pemain(Pemain, ListKartu),
    ( JumlahTotal =< 1
    ->  write('Tidak bisa menyembunyikan kartu. Kartu hanya tersisa 1.'), nl
    ;   ( kartu_tersembunyi(Pemain, _)
        ->  write('Kamu sudah menyembunyikan satu kartu. Tampilkan dulu sebelum menyembunyikan lagi.'), nl
        ;   ( ambil_dan_hapus_kartu(N, ListKartu, Kartu, ListBaru)
            ->  simpan_kartu_pemain(Pemain, ListBaru, ada(Kartu)),
                Kartu = kartu(W, J),
                format('Kartu ~w-~w berhasil disembunyikan.~n', [W, J]),
                next_turn
            ;   write('Nomor kartu tidak valid.'), nl
            )
        )
    ).

% TAMPILKAN KARTU

tampilkanKartu :-
    aksi_boleh,
    giliran(Pemain),
    ( kartu_tersembunyi(Pemain, Kartu)
    ->  kartu_pemain(Pemain, ListKartu),
        simpan_kartu_pemain(Pemain, [Kartu|ListKartu], tidak_ada),
        Kartu = kartu(W, J),
        format('Kartu ~w-~w berhasil ditampilkan kembali.~n', [W, J]),
        next_turn
    ;   write('Tidak ada kartu yang disembunyikan.'), nl
    ).

info_kartu_tersembunyi(Pemain) :-
    ( kartu_tersembunyi(Pemain, kartu(W,J))
    ->  format('(disembunyikan: ~w-~w)~n', [W, J])
    ;   true
    ).
