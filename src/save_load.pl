saveGame :-
    write('Masukkan nama file penyimpanan: '),
    read(NamaFile),
    atom_concat(NamaFile, '.txt', NamaLengkap),
    open(NamaLengkap, write, Stream),
    tulisState(Stream),
    close(Stream),
    write('Status permainan berhasil disimpan ke '),
    write(NamaLengkap),
    write('.'), nl.

tulisState(Stream) :-
    pemain(ListPemain),
    tulisBaris(Stream, 'urutan_pemain', ListPemain),
    giliran(P),
    tulisBaris(Stream, 'giliran', P),
    discardTop(kartu(W,J)),
    tulisBaris(Stream, 'discard_top', W-J),
    tulisSemuaKartu(Stream, ListPemain),
    arahPermainan(Arah),
    tulisBaris(Stream, 'arah_permainan', Arah),
    warnaAktif(WA),
    tulisBaris(Stream, 'warna_aktif', WA),
    statusUNI(SU),
    tulisBaris(Stream, 'status_UNI', SU).

tulisBaris(Stream, Key, Value) :-
    write(Stream, Key),
    write(Stream, ':'),
    write(Stream, Value),
    nl(Stream).

konvKartu(kartu(W,J), W-J).

konvListKartu([], []).
konvListKartu([K|TK], [P|TP]) :-
    konvKartu(K, P),
    konvListKartu(TK, TP).

tulisKartuPemain(Stream, P) :-
    kartuPemain(P, ListKartu),
    konvListKartu(ListKartu, ListPair),
    atom_concat('kartu_', P, Key),
    tulisBaris(Stream, Key, ListPair).

tulisSemuaKartu(_, []).
tulisSemuaKartu(Stream, [P|Sisa]) :-
    tulisKartuPemain(Stream, P),
    tulisSemuaKartu(Stream, Sisa).


loadGame :-
    write('Masukkan nama file yang akan dimuat: '),
    read(NamaFile),
    atom_concat(NamaFile, '.txt', NamaLengkap),
    (   catch(open(NamaLengkap, read, Stream), _, fail)
    ->  bersihkanState,
        bacaSemuaBaris(Stream),
        close(Stream),
        write('Status permainan berhasil dimuat dari '),
        write(NamaLengkap),
        write('.'), nl,
        giliran(P),
        write('Melanjutkan giliran '),
        write(P),
        write('.'), nl
    ;   write('Error: file '),
        write(NamaLengkap),
        write(' tidak ditemukan.'), nl
    ).

bersihkanState :-
    retractall(pemain(_)),
    retractall(giliran(_)),
    retractall(kartuPemain(_,_)),
    retractall(discardTop(_)),
    retractall(arahPermainan(_)),
    retractall(warnaAktif(_)),
    retractall(statusUNI(_)).

bacaSemuaBaris(Stream) :-
    bacaLine(Stream, Line),
    (   Line = end_of_file
    ->  true
    ;   Line = []
    ->  bacaSemuaBaris(Stream)
    ;   prosesLine(Line),
        bacaSemuaBaris(Stream)
    ).

bacaLine(Stream, Result) :-
    get_char(Stream, C),
    bacaLineLanjut(Stream, C, Result).

bacaLineLanjut(_, end_of_file, end_of_file) :- !.
bacaLineLanjut(Stream, '\r', []) :- !,
    get_char(Stream, _).
bacaLineLanjut(_, '\n', []) :- !.
bacaLineLanjut(Stream, C, [C|Rest]) :-
    bacaLine(Stream, Hasil),
    (   Hasil = end_of_file
    ->  Rest = []
    ;   Rest = Hasil
    ).

prosesLine(Chars) :-
    splitDiTitikDua(Chars, KeyChars, ValueChars),
    atom_chars(Key, KeyChars),
    append(ValueChars, ['.', ' '], ValueLengkap),
    open_input_chars_stream(ValueLengkap, S),
    read(S, Value),
    close_input_chars_stream(S),
    handleKV(Key, Value).

splitDiTitikDua([':'|Rest], [], Rest) :- !.
splitDiTitikDua([C|Rest], [C|KeyRest], Value) :-
    splitDiTitikDua(Rest, KeyRest, Value).

handleKV(urutan_pemain, ListPemain) :- !,
    assertz(pemain(ListPemain)).
handleKV(giliran, Pemain) :- !,
    assertz(giliran(Pemain)).
handleKV(discard_top, W-J) :- !,
    assertz(discardTop(kartu(W,J))).
handleKV(arah_permainan, Arah) :- !,
    assertz(arahPermainan(Arah)).
handleKV(warna_aktif, Warna) :- !,
    assertz(warnaAktif(Warna)).
handleKV(status_UNI, List) :- !,
    assertz(statusUNI(List)).
handleKV(Key, ListPair) :-
    atom_concat('kartu_', Pemain, Key), !,
    konvListPairToKartu(ListPair, ListKartu),
    assertz(kartuPemain(Pemain, ListKartu)).

konvPairToKartu(W-J, kartu(W,J)).

konvListPairToKartu([], []).
konvListPairToKartu([P|TP], [K|TK]) :-
    konvPairToKartu(P, K),
    konvListPairToKartu(TP, TK).