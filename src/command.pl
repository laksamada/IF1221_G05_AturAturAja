:- dynamic(efekPending/1).

:- initialization((efekPending(_) -> true ; assertz(efekPending(tidak_ada)))).


aksiPendukung([lihatCommand, lihatKartu, cekInfo]).


aksiUtama([ambilKartu, tantang]) :-
    efekPending(draw_four), !.

aksiUtama([ambilKartu]) :-
    efekPending(draw_two), !.

aksiUtama([mainkanKartu, ambilKartu, uni]).


cetakBernomor([], _).
cetakBernomor([H|T], N) :-
    write(N), write('. '), write(H), nl,
    N1 is N + 1,
    cetakBernomor(T, N1).


lihatCommand :-
    write('Aksi utama yang tersedia:'), nl,
    aksiUtama(ListUtama),
    cetakBernomor(ListUtama, 1),
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    aksiPendukung(ListPendukung),
    cetakBernomor(ListPendukung, 1).


setEfekPending(Efek) :-
    retractall(efekPending(_)),
    assertz(efekPending(Efek)).