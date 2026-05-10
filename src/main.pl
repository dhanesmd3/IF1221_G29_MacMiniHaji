% main.pl  -  dikerjakan ORANG 1
% Isi: load semua file lain + entry point program
%
% Cara jalankan:
%   $ gprolog --consult-file main.pl
%   | ?- startGame.

:- include('kartu.pl').
:- include('state.pl').
:- include('aksi.pl').
:- include('pendukung.pl').
