clearGame :-
    retractall(pemain(_)),
    retractall(giliran(_)),
    retractall(discardTop(_)),
    retractall(warnaAktif(_)),
    retractall(arahPermainan(_)),
    retractall(statusUNI(_)),
    retractall(kartuPemain(_,_)),
    retractall(deckAktif(_)).

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
cekAdaExit:-
    giliran(X),
    kartuPemain(X, ListKartu),
    length(ListKartu, 0), !,nl,
    write('game selesai'), nl,
    write('urutan pemain: '), nl,
    cekHasil,
    clearGame.
cekHasil:-
    sumAllPlayer(X),
    pemain(Y),
    sort_with_id(X,Y,R),
    printList(R).

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
/*Penjelasan: kartu baru yang terdapat di head deckAktif akan diambil dan dimasukkan ke List kartu
pemain di bagian head.*/

    write('Kamu ngambil kartu dari deck kartu!'), nl,
    nextTurn.
% efek skip 
jalankanEfek(kartu(_, skip)) :- !,
    pemain(List),
    giliran(Sekarang),
    nextPlayer(List, Sekarang, Berikutnya),
    retract(giliran(Sekarang)),
    assertz(giliran(Berikutnya)),

    write('Pemain'), write(Berikutnya), write(' telah di skip'), nl.
/*Penjelasan: List berisi daftar pemain dan 'Sekarang' menyatakan giliran pemain sekarang.
Diarah pakai nextPlayer. */

% efek reverse 
jalankanEfek(kartu(_,reverse)) :- !, 
    pemain(ListLama),
    reverse(ListLama, ListBaru),
    retract(pemain(_)),
    assertz(pemain(ListBaru)),
    write('KARTU REVERSE DIMAINKAN! URUTAN DIBALIK!'), nl, 
    write('=> '), write(ListBaru). 
/*Penjelasan: ListLama berisi daftar pemain sekarang, pakai fungsi bawaan reverse buat nuker urutan dengan ListBaru*/



% efek draw_two 
jalankanEfek(kartu(_,draw_two)) :- !,
    pemain(List),
    giliran(Sekarang),
    nextPlayer(List, Sekarang, Target),
    tambahKartu(Target, 2),
    write(Target), write(' telah ditambahkan 2 kartu!'), nl.
/*Penjelasan: List berisi daftar pemain, 'Sekarang' buat player giliran sekarang. Karena drawTwo narget player selanjutnya
maka harus diarah make nextPlayer. Dibantu fungsi tambahKartu. */

% efek wild
jalankanEfek(kartu(hitam,wild)) :-!,
    write('Pilih warna baru(merah, kuning, hijau, biru): '),
    read(WarnaBaru),
    retract(warnaAktif(_)),
    assertz(warnaAktif(WarnaBaru)),
    write('Warna sekarang adalah '), write(WarnaBaru), nl.
/*Penjelasan: pemain milih warna yang diinginkan dan masukin ke warnaBaru lalu ngeganti isi warnaAktif. */

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
/*Penjelasan: kurang lebih gabungan drawTwo sama wild */

jalankanEfek(_) :- !.

/*Daftar Helper*/
%Helper tambahin kartu
tambahKartu(_, 0) :- !. /*Berhenti ketika*/
tambahKartu(Pemain, N) :-
    N > 0,
    retract(deckAktif([H|T])),
    assertz(deckAktif(T)),
    kartuPemain(Pemain, ListLama),
    retract(kartuPemain(Pemain, _)),
    assertz(kartuPemain(Pemain, [H|ListLama])),
    N1 is N - 1,
    tambahKartu(Pemain, N1).
/*Penjelasan: menambahkan kartu sebanyak N ke Pemain.*/
%Helper ngecek warna
cekAdaWarna([kartu(Warna, _)|_], Warna) :- !. /*Kalo ada warna di head*/
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
    discardTop(kartu(hitam, wild_draw_four)),
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
/*Penjelasan: Semisal pemain 1 make drawFour, pemain 2 bisa nantang apakah pilihan warna yang dipilih
oleh pemain 1 sudah ada atau tidak di deck pemain 1 itu sendiri. Kalau ada maka tantangan berhasil.
Kalau tidak, penantang terkena penalti.*/


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
/*Penjelasan: Jika kartu pemain P sisa 2, maka mengucapkan uni. Tergantung valid atau tidak, akan ada penalti.*/

%tangkap
tangkap(Target) :- 
    kartuPemain(Target, L),
    length(L, 1), statusUNI(StatusList),
    \+ member(Target, StatusList), !,
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
/*Penjelasan: Jika pemain sebelumnya belum menyebutkan uni padahal kartunya telah bersisa 1, maka bisa ditangkap.
Tergantung apakah pemain yang ditangkap telah masuk ke statusUNI atau tidak. Akan ada penalti bagi penangkap jika
salah.*/

