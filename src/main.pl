/* Deklarasi Fakta */
    :- dynamic(pemain/1).
    :- dynamic(giliran/1).
    :- dynamic(kartuPemain/2).
    :- dynamic(discardTop/1).
    :- dynamic(warnaAktif/1).
    :- dynamic(arahPermainan/1).
    :- dynamic(statusUNI/1).

/* Deklarasi Rules */
    /* Mulai Permainan */
    startGame :-
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
        write('Game berhasil dimulai.'), nl.
    
    /* Input Pemain */
    inputPemain(0, _, []).
    inputPemain(N, SudahAda, [Nama|Tail]) :-

        N > 0,
        write('Masukkan nama pemain: '),
        read(Nama),

        \+ member(Nama, SudahAda),

        N1 is N - 1,
        inputPemain(
            N1,
            [Nama|SudahAda],
            Tail
        ).
    
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
    kartuValid(kartu(Warna,_), _) :-
        warnaAktif(Warna).
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
        nextTurn.

    /* Tampilkan Satu Kartu */
    tampilkanSatuKartu(kartu(Warna,Jenis)) :-
        write(Warna),
        write('-'),
        write(Jenis),
        nl.
    
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
    
    /* Sementara BIAR GA ERROR */
    jalankanEfek(_).
