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

    bacaJumlahPemain(Jumlah),
    inputPemain(Jumlah, [], ListInput),
    acakList(ListInput, ListPemain),
    assertz(pemain(ListPemain)),
    ListPemain = [First|_],
    assertz(giliran(First)),
    assertz(arahPermainan(kanan)),
    assertz(statusUNI([])),
    deck(DeckAwal),
    bagiSemua(ListPemain, DeckAwal, DeckSisa),
    initDiscard(DeckSisa, DeckAkhir),
    assertz(deckAktif(DeckAkhir)),
    write('Game berhasil dimulai.'), nl,
    pemain(X),write('Urutan paermainanya adalah:'),write(X),nl,
    discardTop(Y),write('Kartu Top pertama: '),write(Y),nl,
    giliran(Z),write('Giliran '),write(Z),nl, !.

/* Validasi Jumlah Pemain */
bacaJumlahPemain(Jumlah) :-
    write('Masukkan jumlah pemain: '),
    read(Input),
    validJumlahPemain(Input), !,
    Jumlah = Input.

bacaJumlahPemain(Jumlah) :-
    write('Mohon masukkan angka antara 2 - 4.'), nl,
    bacaJumlahPemain(Jumlah).

validJumlahPemain(Jumlah) :-
    Jumlah >= 2.

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
    anggotaList(Nama,List),
    write('Nama Sudah Digunakan. Masukkan nama lain: '),
    read(Nama1),
    cekNama(Nama1,List,Result).

cekNama(Nama,List,Nama):-
    \+ anggotaList(Nama,List).

/* Acak urutan pemain */
acakList([], []).
acakList(List, [Pilihan|TailAcak]) :-
    panjangList(List, Panjang),
    BatasAtas is Panjang + 1,
    random(1, BatasAtas, Index),
    ambilElemenKe(Index, List, Pilihan, Sisa),
    acakList(Sisa, TailAcak).

ambilElemenKe(1, [H|T], H, T) :- !.
ambilElemenKe(N, [H|T], Pilihan, [H|Sisa]) :-
    N > 1,
    N1 is N - 1,
    ambilElemenKe(N1, T, Pilihan, Sisa).

clearGame :-
    retractall(pemain(_)),
    retractall(giliran(_)),
    retractall(discardTop(_)),
    retractall(warnaAktif(_)),
    retractall(arahPermainan(_)),
    retractall(statusUNI(_)),
    retractall(kartuPemain(_,_)),
    retractall(deckAktif(_)).


hapusSemua(_, [], []).
hapusSemua(X, [X|Tail], Hasil) :- !,
    hapusSemua(X, Tail, Hasil).
hapusSemua(X, [H|Tail], [H|Hasil]) :-
    hapusSemua(X, Tail, Hasil).


/* Helper list buatan sendiri */
anggotaList(X, [X|_]).
anggotaList(X, [_|Tail]) :-
    anggotaList(X, Tail).

bukanAnggotaList(_, []).
bukanAnggotaList(X, [H|Tail]) :-
    X \= H,
    bukanAnggotaList(X, Tail).

panjangList([], 0).
panjangList([_|Tail], Panjang) :-
    panjangList(Tail, PanjangTail),
    Panjang is PanjangTail + 1.

/* fitur yg belum ada */
% selesai: validasi jumlah pemain (2-4)
% selesai: random urutan pemain
% selesai: simpan deck sisa ke deckAktif
% selesai: validasi nama player mendukung kapital
% selesai: uni dan tangkap
