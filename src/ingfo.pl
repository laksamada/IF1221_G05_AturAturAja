/* Lihat Kartu */
lihatKartu :-
    giliran(Pemain),
    kartuPemain(Pemain, ListKartu),
    write('Berikut kartu yang anda miliki.'), nl,
    tampilkanKartu(ListKartu, 1).

tampilkanKartu([], _).
tampilkanKartu([kartu(Warna,Jenis)|Tail], Nomor) :-
    write(Nomor),
    write('. '),
    write(Warna),
    write('-'),
    write(Jenis),
    nl,
    Next is Nomor + 1,
    tampilkanKartu(Tail, Next).

/* Cek Info */
cekInfo :-
    discardTop(kartu(Warna,Jenis)),
    write('Kartu discard top: '),
    write(Warna),
    write('-'),
    write(Jenis),
    nl,
    pemain(ListPemain),
    write('Urutan pemain: '),
    write(ListPemain),
    nl, nl,
    tampilkanInfoPemain(ListPemain, 1).

tampilkanInfoPemain([], _).
tampilkanInfoPemain([P|Tail], Nomor) :-
    kartuPemain(P, ListKartu),
    length(ListKartu, Jumlah),
    write('Nama pemain '),
    write(Nomor),
    write(': '),
    write(P),
    nl,
    write('Jumlah kartu: '),
    write(Jumlah),
    nl, nl,
    Next is Nomor + 1,
    tampilkanInfoPemain(Tail, Next).

/* cek ada exit*/
len([],0).
len([_|X],Y):-
    len(X,Y1),
    Y is Y1 + 1.

sumPlayer(Pemain,X):-
    kartuPemain(Pemain,ListKartu),
    sumListKartu(ListKartu,X).

sumListKartu([],0).
sumListKartu([kartu(_,skip)|Tail],X):-
    sumListKartu(Tail,X1),
    X is X1 + 10.
sumListKartu([kartu(_,reverse)|Tail],X):-
    sumListKartu(Tail,X1),
    X is X1 + 10.
sumListKartu([kartu(_,Jenis)|Tail],X):-
    sumListKartu(Tail,X1),
    X is X1 + Jenis.

insert_sort([], []).
insert_sort([X], [X]).
insert_sort(X,Y):-
    insert_helper(X,[],Y).

appends([],L,L).
appends([Head|Tail],L,[Head|Result]):-
    appends(Tail,L,Result).

insert_helper([],X,X).
insert_helper([H|T],List,Y):-
    setat(H,List,Y1),
    insert_helper(T,Y1,Y).

setat(Item,[],[Item]).

setat(Item,[H|T],Result):-
    Item = N-_,
    H = M-_,
    N =< M,
    appends([Item,H],T,Result).

setat(Item,[H|T],[H|Result]):-
    Item = N-_,
    H = M-_,
    N > M,
    setat(Item,T,Result).



sumAll([H|ListPemain],Awal,X):-
    sumPlayer(H,SumKartu),
    sumAll(ListPemain,[SumKartu|Awal],X1),X = X1.

sumAll([],Awal,X):-
    X = Awal.

sumAllPlayer(X):-
    pemain(List),
    sumAll(List,[],Y),
    inverse(Y,X).

pair_lists([], [], []).
pair_lists([N|Ns], [Id|Ids], [N-Id|P]) :-
    pair_lists(Ns, Ids, P).

get_ids([], []).
get_ids([_-Id|P], [Id|Ids]) :-
    get_ids(P, Ids).

sort_with_id(N, Ids, S) :-
    pair_lists(N, Ids, P),
    insert_sort(P, SP),
    get_ids(SP, S).


printList([]).
printList([H|T]):-
    write(H),write(' '),
    printList(T).

inverse(List, Result) :-
    inverse_helper(List, [], Result).

inverse_helper([],List, List).

inverse_helper([Head|Tail], List, Result) :-
    inverse_helper(Tail, [Head|List], Result).

/* fitur yg bllm ada */
% lihatCommand
% endGame output lengkap
% print detail perhitungan poin
% ranking dengan tie-break poin, jumlah kartu, urutan pemain
% saveGame 
% loadGame 