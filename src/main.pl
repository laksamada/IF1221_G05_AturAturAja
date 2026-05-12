/* Deklarasi Fakta */
    :- dynamic(pemain/1).
    :- dynamic(giliran/1).
    :- dynamic(kartuPemain/2).
    :- dynamic(discardTop/1).
    :- dynamic(warnaAktif/1).
    :- dynamic(arahPermainan/1).
    :- dynamic(statusUNI/1).
    :- dynamic(deckAktif/1).

/* Deklarasi Rules */
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
        giliran(Z),write('Pemain pertama: '),write(Z),nl.    
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
    /*Deck Kartu*/
    deck([
        kartu(merah,0),
        kartu(merah,1),
        kartu(merah,2),
        kartu(merah,3),
        kartu(merah,4),
        kartu(merah,5),
        kartu(merah,6),
        kartu(merah,7),
        kartu(merah,8),
        kartu(merah,9),

        kartu(biru,0),
        kartu(biru,1),
        kartu(biru,2),
        kartu(biru,3),
        kartu(biru,4),
        kartu(biru,5),
        kartu(biru,6),
        kartu(biru,7),
        kartu(biru,8),
        kartu(biru,9),

        kartu(hijau,0),
        kartu(hijau,1),
        kartu(hijau,2),
        kartu(hijau,3),
        kartu(hijau,4),
        kartu(hijau,5),
        kartu(hijau,6),
        kartu(hijau,7),
        kartu(hijau,8),
        kartu(hijau,9),

        kartu(kuning,0),
        kartu(kuning,1),
        kartu(kuning,2),
        kartu(kuning,3),
        kartu(kuning,4),
        kartu(kuning,5),
        kartu(kuning,6),
        kartu(kuning,7),
        kartu(kuning,8),
        kartu(kuning,9),

        kartu(merah,skip),
        kartu(biru,skip),
        kartu(hijau,skip),
        kartu(kuning,skip),

        kartu(merah,reverse),
        kartu(biru,reverse),
        kartu(hijau,reverse),
        kartu(kuning,reverse),

        kartu(hitam,wild),
        kartu(hitam,mimic)
    ]).
    
    /*Ambil Kartu Random*/
    ambilElemen([H|T], H, T).
    ambilElemen([H|T], X, [H|Sisa]) :-
        ambilElemen(T, X, Sisa).

    clearGame :-
        retractall(pemain(_)),
        retractall(giliran(_)),
        retractall(discardTop(_)),
        retractall(warnaAktif(_)),
        retractall(arahPermainan(_)),
        retractall(statusUNI(_)),
        retractall(kartuPemain(_,_)),retractall(deckAktif(_)).

    /*Bagi 7 Kartu*/
    bagiKartu(_, Deck, Deck, 0).
    bagiKartu(Pemain, DeckAwal, DeckAkhir, N) :-
        N > 0,
        ambilElemen(DeckAwal, Kartu, SisaDeck),
        (
            kartuPemain(Pemain, ListLama)
            ->
            retract(kartuPemain(Pemain, ListLama)),
            ListBaru = [Kartu|ListLama]
            ;
            ListBaru = [Kartu]
        ),
        assertz(kartuPemain(Pemain, ListBaru)),
        N1 is N - 1,
        bagiKartu(Pemain, SisaDeck, DeckAkhir, N1).
    ambilKartu:-
        giliran(P),
        kartuPemain(P,DeckAwal),
        bagiKartu(P, DeckAwal, DeckBaru, 1),
        nextTurn.
    
    /* Bagi Semua Pemain */
    bagiSemua([], Deck, Deck).
    bagiSemua([P|Tail], DeckAwal, DeckAkhir) :-
        bagiKartu(P, DeckAwal, DeckBaru, 7),
        bagiSemua(Tail, DeckBaru, DeckAkhir).
    
    /* Pilih Discard Awal */
    initDiscard(DeckAwal, DeckAkhir) :-
        ambilElemen(DeckAwal, Kartu, DeckAkhir),
        Kartu = kartu(Warna, Angka),
        integer(Angka),
        assertz(discardTop(Kartu)),
        assertz(warnaAktif(Warna)).
    
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

    /* Ambil Kartu ke-N */
    ambilKartuKe(1, [H|T], H, T).
    ambilKartuKe(N, [H|T], Kartu, [H|Sisa]) :-
        N > 1,
        N1 is N - 1,
        ambilKartuKe(N1, T, Kartu, Sisa).
    
    /* Cek Kartu Valid */
    kartuValid(kartu(hitam,_), _).
    kartuValid(kartu(Warna,_), kartu(Warna,_)). 
    kartuValid(kartu(_,Jenis), kartu(_,Jenis)).

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

    /* Tampilkan Satu Kartu */
    tampilkanSatuKartu(kartu(Warna,Jenis)) :-
        write(Warna),
        write('-'),
        write(Jenis),
        nl.
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
    insert_sort([X],X).
    insert_sort(X,Y):-
        insert_helper(X,[],Y).
    appends([],L,L).
    appends([Head|Tail],L,[Head|Result]):-
        appends(Tail,L,Result).
    insert_helper([X],[],[X]).
    insert_helper([],X,X).
    insert_helper([H|T],List,Y):-
        setat(H,List,Y1),
        insert_helper(T,Y1,Y).
    setat(Item,[],[Item]).
    setat(Item,[H|T],Result):-
        Item >= H,
        appends([Item,H],T,Result).
    setat(Item,[H|T],[H|Result]):-
        Item < H,
        setat(Item,T,Result).
        
    cekAdaExit:- 
        giliran(X),
        kartuPemain(X, ListKartu),
        length(ListKartu, 0), !,nl,
        write('game selesai'), nl,
        write('urutan pemain: '), nl,
        cekHasil,
        clearGame.
        
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
        sort(P, SP),
        get_ids(SP, S).
    cekHasil:-
        sumAllPlayer(X),
        pemain(Y),
        sort_with_id(X,Y,R),
        printList(R).
    printList([]).
    printList([H|T]):-
        write(H),write(' '),
        printList(T).
    
    
    /* Update Warna Aktif */
    updateWarnaAktif(kartu(hitam,_)) :-
        write('Pilih warna aktif: '),
        read(WarnaBaru),
        retract(warnaAktif(_)),
        assertz(warnaAktif(WarnaBaru)).
    updateWarnaAktif(kartu(Warna,_)) :-
        Warna \= hitam,
        retract(warnaAktif(_)),
        assertz(warnaAktif(Warna)).
    inverse(List, Result) :-
        inverse_helper(List, [], Result).

    inverse_helper([],List, List).

    inverse_helper([Head|Tail], List, Result) :-
        inverse_helper(Tail, [Head|List], Result).
    
    /* Sementara BIAR GA ERROR */
    jalankanEfek(_).