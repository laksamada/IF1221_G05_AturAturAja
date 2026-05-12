/*Garis besar Alur:
1. Intro Game
2. Input Jumlah Pemain
3. Input Nama Pemain
4. Sistem otomatis membagikan 7 kartu ke tiap pemain dengan sistem:
  4.1. Urutan turn dirandomize, tapi bakal konsisten sampai akhir
  4.2. Turn pertama langsung main, pemain dapat ngeliat kartu sendiri dengan fungsi lihatKartu
       selama masih turn dia.
5. Saat game main akan ada discardPile yang menjadi kartu pertama dari tumpukan deck, 
   (mungkin bakal ada opsi cegah kalau discardPile nya kartu spesial kayak reverse, drawTwo, drawFour, dan mimic)
6. Algoritma permainan tiap turn:
  6.1. Kartu masing-masing berkurang 1 tiap turn jika ada yang sesuai, tambah 1 jika tidak ada yang sesuai dengan
       pengurangan 1 kartu dari deck.
  6.2. Kartu reverse jika sesuai dapat dipakai untuk membalikkan arah turn misal 1 ke 5 jadi 5 ke 1.
  6.3. Kartu drawTwo yang menambahkan 2 kartu ke pemain selanjutnya jika warna sama, tak boleh ditumpuk
  6.4. Kartu drawFour yang menambahkan 4 kartu ke pemain selanjutnya tanpa peduli warna, tak boleh ditumpuk
  6.5. Kartu skip yang melewati turn pemain selanjutnya
  6.6. Kartu wild yang dapat mengubah warna untuk turn selanjutnya tanpa peduli warna sekarang, tak boleh ditumpuk
  6.7. Kartu mimic(bonus) yang dapat menyalin kartu aksi yang terakhir dimainkan tanpa peduli warna,
       kartu aksi seperti wild, skip, drawTwo, drawFour, dan reverse.
7. Pemain dengan sisa deck kartu dua terakhir harus menginput uni(2) untuk menyerukan UNI. 
   Jika tidak maka akan memungkinkan pemain lain untuk menangkap. Jika benar pemain yang ditangkap tidak
   memiliki satu kartu atau sudah menyerukan UNI maka penangkap akan memakan gilirannya dan yang ditangkap
   akan dapat dua kartu acak. Jika tidak benar yang ditangkap memenuhi syarat tersebut maka penangkap akan 
   mendapatkan satu kartu acak.
8. Algoritma Permainan berakhir:
  7.1. Pemain selesai ketika deck kartunya habis atau nol.
  7.2. Permainan beres jika hanya tersisa satu pemain yang belum selesai.*/

/* Deklarasi Fakta */
/*Bagian ini ngejelasin di bagian mana aja yang bakal berubah fakta-faktanya*/
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
    /*retractall dulu untuk ngapus semua info soal pemain, giliran, dst. Biar bersih*/
        retractall(pemain(_)),
        retractall(giliran(_)),
        retractall(discardTop(_)),
        retractall(warnaAktif(_)),
        retractall(arahPermainan(_)),
        retractall(statusUNI(_)),
        retractall(kartuPemain(_,_)), %biar ga ada bug pas ngejalanin startgame lagi

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
        
        kartu(merah,drawTwo),
        kartu(biru,drawTwo),
        kartu(hijau,drawTwo),
        kartu(kuning,drawTwo),

        kartu(hitam,wild),
        kartu(hitam,drawFour),
        kartu(hitam,mimic)

    ]).
    
    /*Mulai Membagikan Kartu*/
    write('Kartu mulai dibagikan!'),
    %Algoritma membagikan kartu per turn
    %Jadi buat turn pertama semua orang itu untuk dibagiin kartu dan ngeliat isinya



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
    inverse(List, Result) :-
        inverse_helper(List, [], Result).

    inverse_helper([],List, List).

    inverse_helper([Head|Tail], List, Result) :-
        inverse_helper(Tail, [Head|List], Result).
    
    /* Sementara BIAR GA ERROR */
    jalankanEfek(_).



    
