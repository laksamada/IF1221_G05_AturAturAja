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

/* fitur yg belum ada */
% ambilKartu dari deckAktif */
ambilKartu :-
    giliran(P),
    deckAktif([KartuBaru|SisaDeck]),
    retract(deckAktif(_)),
    assertz(deckAktif(SisaDeck)),

    kartuPemain(P, ListLama),
    retract(kartuPemain(P, _)),
    assertz(kartuPemain(P, [KartuBaru|ListLama])),

    write('Kamu ngambil kartu dari deck kartu!'), nl,
    nextTurn.
% efek skip 
jalankanEfek(kartu(_, skip)) :- !,
    pemain(List),
    giliran(Sekarang),
    nextPlayer(List, Sekarang, Berikutnya),
    nextPlayer(List, Berikutnya, SetelahBerikutnya),
    retract(giliran(Sekarang)),
    assertz(giliran(SetelahBerikutnya)),

    write('Pemain'), write(Berikutnya), write(' telah di skip, lanjut ke pemain'),
    write(SetelahBerikutnya), nl.

jalankanEfek(_) :- !.


% efek reverse 
jalankanEfek(kartu(_,reverse)) :- !,
    pemain(ListLama),
    reverse(ListLama, ListBaru),
    retract(pemain(_)),
    assertz(pemain(ListBaru)),
    write('KARTU REVERSE DIMAINKAN! URUTAN DIBALIK!'), nl, 
    write('=> '), write(ListBaru).



% efek draw_two 
jalankanEfek(kartu(_,draw_two)) :- !,
    pemain(List),
    giliran(Sekarang),
    nextPlayer(List, Sekarang, Target),
    tambahKartu(Target, 2),
    write(Target), write(' telah ditambahkan 2 kartu!'), nl.



% efek wild
jalankanEfek(kartu(hitam,wild)) :-!,
    write('Pilih warna baru(merah, kuning, hijau, biru): '),
    read(WarnaBaru),
    retract(warnaAktif(_)),
    assertz(warnaAktif(WarnaBaru)),
    write('Warna sekarang adalah '), write(WarnaBaru), nl.

% efek wild_draw_four
jalankanEfek(kartu(hitam,draw_four)) :- !,
    write('Pilih warna baru(merah, kuning, hijau, biru): '),
    read(WarnaBaru),
    retract(warnaAktif(_)),
    assertz(warnaAktif(WarnaBaru)),
    write('Warna sekarang adalah '), write(WarnaBaru),

    pemain(List),
    giliran(Sekarang),
    nextPlayer(List, Sekarang, Target),
    tambahKartu(Target, 4),
    write(Target), write(' telah ditambahkan 4 kartu!'), nl.

jalankanEfek(_) :- !.

/*Daftar Helper*/
%Helper tambahin kartu
tambahKartu(_, 0) :- !.
tambahKartu(Pemain, N) :-
    N > 0,
    retract(deckAktif([H|T])),
    assertz(deckAktif(T)),
    kartuPemain(P, ListLama),
    retract(kartuPemain(Pemain, _)),
    assertz(kartuPemain(Pemain, [H|ListLama])),
    N1 is N - 1,
    tambahKartu(Pemain, N1).

%Helper ngecek warna
cekAdaWarna([kartu(Warna, _|_), Warna]) :- !.
cekAdaWarna([_|SisaKartu], Warna) :- cekAdaWarna(SisaKartu, Warna).

%Helper ngecek pemain sebelumnya
prevPlayer([X, Y|_], Y, X).
prevPlayer([_|T], Y, X) :- prevPlayer(T, Y, X).
prevPlayer([First|Rest], First, Last) :- last([First|Rest], Last).

% tantang
tantang :-
    giliran(Penantang),
    pemain(List),

    prevPlayer(List, Target, Penantang),
    discardTop(wild_draw_four),
    warnaLama(W),
    kartuPemain(Target, ListKartu),
    eksekusi(Penantang, Target, ListKartu, W).

eksekusi(_, Target, ListKartu, W) :-
    cekAdaWarna(ListKartu, W), !,
    write('Tantangan berhasil,'), write(Target), write(' mendapat 4 kartu acak!'), nl,
    tambahKartu(Target, 4).
eksekusi(Penantang, Target, _ , _) :-
    write('Penantang gagal! '), write(Penantang), write(' mendapat 6 kartu acak!'), nl,
    tambahKartu(Penantang, 6).


%UNI
uni(Index) :-
    giliran(P),
    kartuPemain(P, List),
    length(List, 2), !,
    mainkanKartu(Index),

    retract(statusUNI(L)),
    assertz(statusUNI([P|L])),
    write(P), write('mengucapkan UNI! Kartu sisa 1').

uni(_) :-
    giliran(P),
    write('Tidak invalid, sisa kartu selanjutnya bukanlah 1!'), nl,
    write(P), write(' mendapatkan penalti 1 kartu acak'),
    tambahKartu(P, 1),
    nextTurn.
%tangkap
tangkap(Target) :- 
    kartuPemain(Target, L),
    length(L, 1),
    \+ member(Target, StatusUNI), !,
    write(Target), write(' tertangkap basah lupa berteriak UNI!'), nl,
    write('Mendapat penalti 2 kartu'),
    tambahKartu(Target, 2),
    giliran(Penangkap),
    nextTurn.

tangkap(_) :-
    giliran(Penangkap), %Katanya sih penangkap akan memakan giliran target, mau bener atau engga
    write('Kamu salah tangkap! Mendapatkan penalti 1 kartu'),
    tambahKartu(Penangkap, 1),
    nextTurn.

