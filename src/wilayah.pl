/* Nama Wilayah */
namaWilayah(na1, 'Alaska').
namaWilayah(na2, 'Canada').
namaWilayah(na3, 'America').
namaWilayah(na4, 'Mexico').
namaWilayah(na5, 'Greenland').

namaWilayah(sa1, 'Brazil').
namaWilayah(sa2, 'Peru').

namaWilayah(e1, 'Uni Soviet').
namaWilayah(e2, 'England').
namaWilayah(e3, 'France').
namaWilayah(e4, 'Spain').
namaWilayah(e5, 'Germany').

namaWilayah(af1, 'Israel').
namaWilayah(af2, 'Egypt').
namaWilayah(af3, 'South Africa').

namaWilayah(a1, 'South Korea' ).
namaWilayah(a2, 'North Korea').
namaWilayah(a3, 'Mongolia').
namaWilayah(a4, 'China').
namaWilayah(a5, 'Japan').
namaWilayah(a6, 'Indonesia').
namaWilayah(a7, 'Malaysia').

namaWilayah(au1, 'Australia').
namaWilayah(au2, 'New Zealand').

isNeighbour(T1, T2) :-
    neighbour(T1, ListNeighbour),
    member(T2, ListNeighbour), !.

printWilayah([Head|Tail]) :-
    printNamaWilayah(Head),
    loopPrintWilayah(Tail).

loopPrintWilayah([]).
loopPrintWilayah([H|T]) :-
    write(','),
    printNamaWilayah(H),
    loopPrintWilayah(T).

printNamaWilayah(Head) :-
    namaWilayah(Head, Name),
    format(' ~w',[Name]).

writeBenua([]).
writeBenua([H|T]) :-
    write(H),
    writeBenuaLoop(T).

writeBenuaLoop([]).
writeBenuaLoop([H|T]) :-
    format(', ~w', [H]),
    writeBenuaLoop(T).

printLocation(Territory) :-
    namaWilayah(Territory, Nama),
    deployedTroops(Territory, Count),

    nl,
    write(Territory),
    format('\nNama\t\t: ~w', [Nama]),
    format('\nJumlah Tentara\t: ~d\n', [Count]).

loopPrintLocation([]).
loopPrintLocation([Head|Tail]) :-
    printLocation(Head),
    loopPrintLocation(Tail).

checkLocationDetail(Territory) :-
    member(Territory,_) ->
        format('\nKode              : ~w', [Territory]),
        namaWilayah(Territory, Name),
        format('\nNama              : ~w', [Name]),
        ruler(Territory, Player),
        format('\nNama Pemilik      : ~w', [Player]),
        deployedTroops(Territory, Count),
        format('\nTotal Tentara     : ~d', [Count]),
        neighbour(Territory, ListNeighbour),
        write('\nNama Tetangga     :'),
        printWilayah(ListNeighbour);
    /* else */
    write('\nKode Wilayah Tidak Valid').