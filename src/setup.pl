/* Deklarasi Fakta */
:- dynamic(pemain/1).
:- dynamic(giliran/1).
:- dynamic(kartuPemain/2).
:- dynamic(discardTop/1).
:- dynamic(warnaAktif/1).
:- dynamic(arahPermainan/1).
:- dynamic(statusUNI/1).
:- dynamic(deckAktif/1).

/* Mulai Permainan */
startGame :-
    clearGame,

    write('Masukkan jumlah pemain: '),
    read(Jumlah),
    inputPemain(Jumlah, [], ListPemain),
    assertz(pemain(ListPemain)),
    ListPemain = [First|_],
    assertz(giliran(First)),
    assertz(arahPermainan(kanan)),
    assertz(statusUNI([])),
    deck(DeckAwal),
    bagiSemua(ListPemain, DeckAwal, DeckSisa),
    initDiscard(DeckSisa, _),
    write('Game berhasil dimulai.'), nl,
    pemain(X),write('Urutan paermainanya adalah:'),write(X),nl,
    discardTop(Y),write('Kartu Top pertama: '),write(Y),nl,
    giliran(Z),write('Giliran '),write(Z),nl.

/* Input Pemain */
inputPemain(0, _, []).
inputPemain(N, SudahAda, [Nama1|Tail]) :-
    N > 0,
    write('Masukkan nama pemain: '),
    read(Nama),
    cekNama(Nama,SudahAda,Nama1),

    N1 is N - 1,
    inputPemain(
        N1,
        [Nama1|SudahAda],
        Tail
    ).

/* cek apakah nama sudah ada di list,minta masukan ulang jika sudah ada*/
cekNama(Nama,List,Result):-
    member(Nama,List),
    write('Nama Sudah Digunakan. Masukkan nama lain: '),
    read(Nama1),
    cekNama(Nama1,List,Result).

cekNama(Nama,List,Nama):-
    \+ member(Nama,List).

clearGame :-
    retractall(pemain(_)),
    retractall(giliran(_)),
    retractall(discardTop(_)),
    retractall(warnaAktif(_)),
    retractall(arahPermainan(_)),
    retractall(statusUNI(_)),
    retractall(kartuPemain(_,_)),
    retractall(deckAktif(_)).

/* fitur yg belum ada */
% validasi jumlah pemain (gaboleh dibawah 0)
% random urutan pemain
% simpan deck sisa ke deckAktif
% validasi nama player nya harus bisa kapital
% uni dan tangkap (ini sebenernya masuk gameplay tapi biar balance aja tugasnya)