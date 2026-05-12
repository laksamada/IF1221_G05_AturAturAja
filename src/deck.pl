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

/* fitur yg blm ada */
% tambah kartu draw sama wild ke deck 
% random ambilElemen
% random deck 
% validasi discard awal kalau bukan angka harus ambil ulang 
% kartuValid brdasrkan warnaAktif 
% nilai kartu hitam sm draw_two