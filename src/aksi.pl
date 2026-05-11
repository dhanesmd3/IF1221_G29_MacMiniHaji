% mainkanKartu(Nomor)
mainkanKartu(Nomor) :-
    giliran(Pemain),
    kartu_pemain(Pemain, ListKartu),
    
    % ambil dan hapus kartu dari list
    ( ambil_dan_hapus_kartu(Nomor, ListKartu, Kartu, ListBaru)
    ->  true
    ;   write('Nomor kartu tidak valid.'), nl, fail
    ),
    
    % validasi kartu
    ( bisa_dimainkan(Kartu)
    ->  true
    ;   write('Kartu tidak bisa dimainkan.'), nl, fail
    ),
    
    % update state pemain dan meja
    retract(kartu_pemain(Pemain, ListKartu)),
    assertz(kartu_pemain(Pemain, ListBaru)),
    retract(discard_top(_)),
    assertz(discard_top(Kartu)),
    
    Kartu = kartu(Warna, Jenis),
    format('~w memainkan kartu: ~w-~w.~n', [Pemain, Warna, Jenis]),
    
    update_warna_aktif(Warna),
    
    % cek kondisi menang
    ( ListBaru = []
    ->  format('~w menghabiskan semua kartunya!~n', [Pemain])
    ;   next_turn
    ).

% helper: ambil dan hapus kartu ke-N (pengganti nth1 & select)
ambil_dan_hapus_kartu(1, [Head|Tail], Head, Tail) :- !.
ambil_dan_hapus_kartu(N, [Head|Tail], Kartu, [Head|TailSisa]) :-
    N > 1,
    N1 is N - 1,
    ambil_dan_hapus_kartu(N1, Tail, Kartu, TailSisa).

% helper: update warna aktif
update_warna_aktif(hitam) :-
    !, 
    write('Pilih warna (merah/kuning/hijau/biru): '),
    read(WarnaBaru),
    set_warna_aktif(WarnaBaru).

update_warna_aktif(Warna) :-
    set_warna_aktif(Warna).

% helper: cek kartu valid dimainkan
bisa_dimainkan(kartu(hitam, _)) :- !.
bisa_dimainkan(kartu(Warna, _)) :- warna_aktif(Warna), !.
bisa_dimainkan(kartu(_, Jenis)) :- discard_top(kartu(_, Jenis)), !.

% ambilKartu
ambilKartu :-
    giliran(Pemain),
    kartu_acak(KartuBaru),
    kartu_pemain(Pemain, ListLama),
    
    % update list kartu pemain
    retract(kartu_pemain(Pemain, ListLama)),
    assertz(kartu_pemain(Pemain, [KartuBaru|ListLama])),
    
    KartuBaru = kartu(W, J),
    format('~w mendapatkan kartu: ~w-~w.~n', [Pemain, W, J]),
    next_turn.