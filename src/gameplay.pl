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
    arahPermainan(kanan),
    !,
    pemain(List),
    giliran(Sekarang),
    nextPlayer(List, Sekarang, Berikutnya),
    retract(giliran(Sekarang)),
    assertz(giliran(Berikutnya)).

nextTurn :-
    arahPermainan(kiri),
    pemain(List),
    giliran(Sekarang),
    prevPlayer(List, Sekarang, Berikutnya),
    retract(giliran(Sekarang)),
    assertz(giliran(Berikutnya)).

nextPlayer([X,Y|_], X, Y).
nextPlayer([_|Tail], X, Y) :-
    nextPlayer(Tail, X, Y).
nextPlayer([Last], Last, First) :-
    pemain([First|_]).

cekAdaKartu([],_) :-
    fail.
cekAdaKartu([H|_],X) :-
    kartuValid(H,X), !.
cekAdaKartu([_|T],X) :-
    cekAdaKartu(T,X).

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
    len(SisaKartu, Jumlah),
    (
        Jumlah =:= 1
        -> true
        ;  hapusUNI(Pemain)
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
    hapusUNI(P),
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
    ubahArah,
    write('KARTU REVERSE DIMAINKAN!'), nl,
    write('Arah permainan dibalik!'), nl.
/*Penjelasan: ListLama berisi daftar pemain sekarang, pakai fungsi bawaan reverse buat nuker urutan dengan ListBaru*/



% efek draw_two 
jalankanEfek(kartu(_,draw_two)) :- !,
    pemain(List),
    giliran(Sekarang),
    nextPlayer(List, Sekarang, Target),
    tambahKartu(Target, 2),
    retract(giliran(Sekarang)),
    assertz(giliran(Target)),
    write(Target),
    write(' mendapatkan 2 kartu dan kehilangan giliran!'),
    nl.
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
jalankanEfek(kartu(hitam,wild_draw_four)) :- !,
    warnaAktif(WarnaSebelumnya),
    retractall(warnaLama(_)),
    assertz(warnaLama(WarnaSebelumnya)),
jalankanEfek(kartu(hitam, wild_draw_four)) :- !,
    write('Pilih warna baru(merah, kuning, hijau, biru): '),
    read(WarnaBaru),
    retract(warnaAktif(_)),
    assertz(warnaAktif(WarnaBaru)),
    pemain(List),
    giliran(Sekarang),
    nextPlayer(List, Sekarang, Target),
    tambahKartu(Target, 4),
    retract(giliran(Sekarang)),
    assertz(giliran(Target)),
    write(Target),
    write(' mendapatkan 4 kartu dan kehilangan giliran!'),
    nl.
/*Penjelasan: kurang lebih gabungan drawTwo sama wild */

jalankanEfek(_) :- !.

/*Daftar Helper*/
% Helper ubah arah
ubahArah :-
    arahPermainan(kanan),
    retract(arahPermainan(kanan)),
    assertz(arahPermainan(kiri)), !.
ubahArah :-
    arahPermainan(kiri),
    retract(arahPermainan(kiri)),
    assertz(arahPermainan(kanan)).

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

% Helper Hapus UNI
hapusUNI(P) :-
    statusUNI(List),
    hapusElemen(P, List, ListBaru),
    retract(statusUNI(List)),
    assertz(statusUNI(ListBaru)).

hapusElemen(_, [], []).
hapusElemen(X, [X|T], T).
hapusElemen(X, [H|T], [H|R]) :-
    X \= H,
    hapusElemen(X, T, R).
/* Semisal ada player yang sudah masuk statusUNI tapi setelah itu ambilKartu, maka akan keluar dari statusUNI */

%Helper ngecek warna
cekAdaWarna([kartu(Warna, _)|_], Warna) :- !. /*Kalo ada warna di head*/
cekAdaWarna([_|SisaKartu], Warna) :- cekAdaWarna(SisaKartu, Warna).

%Helper ngecek pemain sebelumnya
% Helper Last
lastElem([X], X).
lastElem([_|T], X) :-
    lastElem(T, X).

prevPlayer([X, Y|_], Y, X).
prevPlayer([_|T], Y, X) :- prevPlayer(T, Y, X).
prevPlayer([First|Rest], First, Last) :- lastElem([First|Rest], Last).

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
eksekusi(Penantang, _, _ , _) :-
    write('Penantang gagal! '), write(Penantang), write(' mendapat 6 kartu acak!'), nl,
    tambahKartu(Penantang, 6).
/*Penjelasan: Semisal pemain 1 make drawFour, pemain 2 bisa nantang apakah pilihan warna yang dipilih
oleh pemain 1 sudah ada atau tidak di deck pemain 1 itu sendiri. Kalau ada maka tantangan berhasil.
Kalau tidak, penantang terkena penalti.*/


%UNI
uni(Index) :-
    giliran(P),
    kartuPemain(P, List),
    len(List, 2), !,
    mainkanKartu(Index),

    retract(statusUNI(L)),
    assertz(statusUNI([P|L])),
    write(P),
    write(' mengucapkan UNI! Kartu sisa 1'),
    nl.

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
    len(L, 1), statusUNI(StatusList),
    \+ ada(Target, StatusList), !,
    write(Target), write(' tertangkap basah lupa berteriak UNI!'), nl,
    write('Mendapat penalti 2 kartu'),
    tambahKartu(Target, 2),
    giliran(_),
    nextTurn.

tangkap(_) :-
    giliran(Penangkap), %Katanya sih penangkap akan memakan giliran target, mau bener atau engga
    write('Kamu salah tangkap! Mendapatkan penalti 1 kartu'),
    tambahKartu(Penangkap, 1),
    nextTurn.
/*Penjelasan: Jika pemain sebelumnya belum menyebutkan uni padahal kartunya telah bersisa 1, maka bisa ditangkap.
Tergantung apakah pemain yang ditangkap telah masuk ke statusUNI atau tidak. Akan ada penalti bagi penangkap jika
salah.*/

