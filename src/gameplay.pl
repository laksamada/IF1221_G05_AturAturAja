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
    assertz(kartuPemain(Pemain, SisaKartu)),
    len(SisaKartu, Jumlah),
    (
        Jumlah =:= 1
        -> true
        ;  hapusUNI(Pemain)
    ),
    retract(discardTop(_)),
    assertz(discardTop(KartuDipilih)),
    updateWarnaAktif(KartuDipilih),
    catatAksi(Pemain, KartuDipilih),
    write(Pemain),
    write(' memainkan kartu: '),
    tampilkanSatuKartu(KartuDipilih),
    jalankanEfek(KartuDipilih),
    lanjut.

lanjut :-
    cekAdaExit, !.
lanjut :-
    nextTurn.

/* Ambil Kartu dari deckAktif */
ambilKartu :-
    giliran(P),
    deckAktif([KartuBaru|SisaDeck]),
    retract(deckAktif(_)),
    assertz(deckAktif(SisaDeck)),
    kartuPemain(P, ListLama),
    retract(kartuPemain(P, _)),
    assertz(kartuPemain(P, [KartuBaru|ListLama])),
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
    write('Pemain '), write(Berikutnya), write(' telah di-skip'), nl.

% efek reverse
jalankanEfek(kartu(_,reverse)) :- !,
    ubahArah,
    write('KARTU REVERSE DIMAINKAN!'), nl,
    write('Arah permainan dibalik!'), nl.

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

% efek wild
jalankanEfek(kartu(hitam,wild)) :- !,
    write('Pilih warna baru(merah, kuning, hijau, biru): '),
    read(WarnaBaru),
    retract(warnaAktif(_)),
    assertz(warnaAktif(WarnaBaru)),
    write('Warna sekarang adalah '), write(WarnaBaru), nl.

% efek wild_draw_four
jalankanEfek(kartu(hitam,wild_draw_four)) :- !,
    warnaAktif(WarnaSebelumnya),
    retractall(warnaLama(_)),
    assertz(warnaLama(WarnaSebelumnya)),
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

% efek mimic
jalankanEfek(kartu(hitam, mimic)) :- !,
    write('Menelusuri riwayat permainan...'), nl,
    cariAksiTerakhir(HasilCari),
    jalankanMimic(HasilCari).

% catch-all: kartu angka, tidak ada efek
jalankanEfek(_) :- !.


cariAksiTerakhir(tidak_ada) :-
    riwayatAksi([]), !.
cariAksiTerakhir(Pemain-Kartu) :-
    riwayatAksi([Pemain-Kartu|_]).

% Tidak ada riwayat aksi -> berlaku seperti wild
% (warna sudah dipilih oleh updateWarnaAktif sebelum jalankanEfek)
jalankanMimic(tidak_ada) :- !,
    write('Belum ada kartu aksi sebelumnya.'), nl,
    write('Mimic berlaku seperti wild.'), nl,
    warnaAktif(W),
    write('Warna aktif sekarang: '), write(W), nl.

% Ada riwayat aksi -> salin efeknya
jalankanMimic(Pemain-kartu(Warna, Jenis)) :-
    write('Kartu aksi terakhir yang dimainkan: '),
    write(Warna), write('-'), write(Jenis),
    write(' (oleh '), write(Pemain), write(')'), nl,
    write('Kartu mimic menyalin efek '), write(Jenis), write('!'), nl,
    jalankanEfekMimic(kartu(Warna, Jenis)).

% wild & wild_draw_four: warna sudah dipilih, tidak perlu prompt lagi
jalankanEfekMimic(kartu(_, wild)) :- !,
    warnaAktif(W),
    write('Warna aktif sekarang: '), write(W), nl.

jalankanEfekMimic(kartu(_, wild_draw_four)) :- !,
    warnaAktif(WarnaSebelumnya),
    retractall(warnaLama(_)),
    assertz(warnaLama(WarnaSebelumnya)),
    warnaAktif(W),
    write('Warna aktif sekarang: '), write(W), nl,
    pemain(List),
    giliran(Sekarang),
    nextPlayer(List, Sekarang, Target),
    tambahKartu(Target, 4),
    retract(giliran(Sekarang)),
    assertz(giliran(Target)),
    write(Target), write(' mendapatkan 4 kartu dan kehilangan giliran!'), nl.

% skip, reverse, draw_two: identik dengan jalankanEfek biasa
jalankanEfekMimic(Kartu) :-
    jalankanEfek(Kartu).


kartuAksi(kartu(_, skip)).
kartuAksi(kartu(_, reverse)).
kartuAksi(kartu(_, draw_two)).
kartuAksi(kartu(_, wild)).
kartuAksi(kartu(_, wild_draw_four)).
% mimic tidak masuk agar tidak meniru mimic

catatAksi(Pemain, Kartu) :-
    kartuAksi(Kartu), !,
    riwayatAksi(Lama),
    retract(riwayatAksi(Lama)),
    assertz(riwayatAksi([Pemain-Kartu|Lama])).
catatAksi(_, _).


ubahArah :-
    arahPermainan(kanan),
    retract(arahPermainan(kanan)),
    assertz(arahPermainan(kiri)), !.
ubahArah :-
    arahPermainan(kiri),
    retract(arahPermainan(kiri)),
    assertz(arahPermainan(kanan)).

tambahKartu(_, 0) :- !.
tambahKartu(Pemain, N) :-
    N > 0,
    retract(deckAktif([H|T])),
    assertz(deckAktif(T)),
    kartuPemain(Pemain, ListLama),
    retract(kartuPemain(Pemain, _)),
    assertz(kartuPemain(Pemain, [H|ListLama])),
    N1 is N - 1,
    tambahKartu(Pemain, N1).

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

cekAdaWarna([kartu(Warna, _)|_], Warna) :- !.
cekAdaWarna([_|SisaKartu], Warna) :- cekAdaWarna(SisaKartu, Warna).

lastElem([X], X).
lastElem([_|T], X) :-
    lastElem(T, X).

prevPlayer([X, Y|_], Y, X).
prevPlayer([_|T], Y, X) :- prevPlayer(T, Y, X).
prevPlayer([First|Rest], First, Last) :- lastElem([First|Rest], Last).


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
    write('Tantangan berhasil! '), write(Target), write(' mendapat 4 kartu acak!'), nl,
    tambahKartu(Target, 4).
eksekusi(Penantang, _, _, _) :-
    write('Penantang gagal! '), write(Penantang), write(' mendapat 6 kartu acak!'), nl,
    tambahKartu(Penantang, 6).


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
    write('Tidak valid, sisa kartu selanjutnya bukanlah 1!'), nl,
    write(P), write(' mendapatkan penalti 1 kartu acak'), nl,
    tambahKartu(P, 1),
    nextTurn.


tangkap(Target) :-
    kartuPemain(Target, L),
    len(L, 1),
    statusUNI(StatusList),
    \+ ada(Target, StatusList), !,
    write(Target), write(' tertangkap basah lupa berteriak UNI!'), nl,
    write('Mendapat penalti 2 kartu'), nl,
    tambahKartu(Target, 2),
    giliran(_),
    nextTurn.

tangkap(_) :-
    giliran(Penangkap),
    write('Kamu salah tangkap! Mendapatkan penalti 1 kartu'), nl,
    tambahKartu(Penangkap, 1),
    nextTurn.