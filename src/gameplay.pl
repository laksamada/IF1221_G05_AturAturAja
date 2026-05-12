/* Ambil Kartu */
ambilKartu:-
    giliran(P),
    kartuPemain(P,DeckAwal),
    bagiKartu(P, DeckAwal, DeckBaru, 1),
    nextTurn.

/* Next Turn */
nextTurn :-
    pemain(List),
    giliran(Sekarang),
    nextPlayer(List, Sekarang, Berikutnya),
    retract(giliran(Sekarang)),
    assertz(giliran(Berikutnya)).

nextPlayer([X,Y|_], X, Y).
nextPlayer([_|Tail], X, Y) :-
    nextPlayer(Tail, X, Y).
nextPlayer([Last], Last, First) :-
    pemain([First|_]).

cekAdaKartu([_|T],X):-
    cekAdaKartu(T,X).
cekAdaKartu([H|_],X):-
    kartuValid(H,X).

/* Mainkan Kartu */
mainkanKartu(Index) :-
    giliran(Pemain),
    kartuPemain(Pemain, ListKartu),
    ambilKartuKe(
        Index,
        ListKartu,
        KartuDipilih,
        SisaKartu
    ),
    discardTop(KartuAtas),
    kartuValid(KartuDipilih, KartuAtas),
    retract(kartuPemain(Pemain, ListKartu)),
    assertz(
        kartuPemain(Pemain, SisaKartu)
    ),
    retract(discardTop(_)),
    assertz(discardTop(KartuDipilih)),
    updateWarnaAktif(KartuDipilih),
    write(Pemain),
    write(' memainkan kartu: '),
    tampilkanSatuKartu(KartuDipilih),
    jalankanEfek(KartuDipilih),
    lanjut.

lanjut:-
    cekAdaExit,!.
lanjut:-
    nextTurn.

/* Sementara BIAR GA ERROR */
jalankanEfek(_).

/* fitur yg belum ada */
% ambilKartu dari deckAktif */
% efek skip 
% efek reverse 
% efek draw_two 
% efek wild 
% efek wild_draw_four
% tantang