/* -------------------------------------------------------------------------------------------- */
/* Dynamic predicates */
:- dynamic(playerCount/1).          % Player count
:- dynamic(playerName/1).           % Player name list (sorted by turn order)
:- dynamic(playerDice/2).           % List Key-Value (RolledDiceValue-Player) for turn order sorting
:- dynamic(currentPlayer/1).        % Current player
:- dynamic(totalTroops/2).          % totalTroops(Player, Count), the number of all troops the player has
:- dynamic(undeployedTroops/2).     % undeployedTroops(Player, Count), the number of undeployed troops the player has
:- dynamic(deployedTroops/2).       % deployedTroops(Territory, Count), number of troops per territory
:- dynamic(ruler/2).                % ruler(Territory, Ruler), ruler of a territory
:- dynamic(unclaimedTerritory/1).   % list of unclaimed territory
:- dynamic(globalTroops/1).         % total global number of troops initialization
:- dynamic(listTerritory/2).        % listTerritory(Player, List), ex: listTerritory(player1, [e1,sa2,au2])
:- dynamic(player/2).               % list player name not sorted by turn, ex: player(p1, name)
:- dynamic(activeTroops/2).
:- dynamic(counterMove/1).          % counterMove(Cnt) , to check how many move the current player has used
:- dynamic(counterAttack/1).        % counterAttack(Cnt) , to check how many move the current player has used
:- dynamic(checkRisk/1).
:- dynamic(drawnRisk/2).
/* -------------------------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------------------------- */
/* Static predicates */
possibleTerritory([na1,na2,na3,na4,na5,
                   e1,e2,e3,e4,e5,
                   a1,a2,a3,a4,a5,a6,a7,
                   sa1,sa2,
                   af1,af2,af3,
                   au1,au2]).
neighbour(na1, [na2, na3, a3]).
neighbour(na2, [na1, na4, na5]).
neighbour(na3, [na1, na4, sa1, a3]).
neighbour(na4, [na2, na3, na5]).
neighbour(na5, [na2, na4, e1]).
neighbour(e1, [na5, e2, e3]).
neighbour(e2, [e1, e4, a1]).
neighbour(e3, [e1, e4, af1]).
neighbour(e4, [e2, e3, e5]).
neighbour(e5, [e4, a4, af2]).
neighbour(a1, [e2, a4]).
neighbour(a2, [a4, a5, a6]).
neighbour(a3, [a5, na1, na3]).
neighbour(a4, [e5, a1, a2, a5, a6]).
neighbour(a5, [a2, a3, a4, a6]).
neighbour(a6, [a2, a4, a5, a7, au1]).
neighbour(a7, [a6]).
neighbour(sa1, [na3, sa2]).
neighbour(sa2, [sa1, af1, au2]).
neighbour(af1, [sa2, e3, af2, af3]).
neighbour(af2, [e4, e5, af1, af3]).
neighbour(af3, [af1, af2]).
neighbour(au1, [a6, au2]).
neighbour(au2, [au1, sa2]).

/* Continent */
amerikaU([na1,na2,na3,na4,na5]).
eropa([e1,e2,e3,e4,e5]).
asia([a1,a2,a3,a4,a5,a6,a7]).
amerikaS([sa1,sa2]).
afrika([af1,af2,af3]).
australia([au1,au2]).
/* -------------------------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------------------------- */
/* Start */
startGame :-
    /* Retract all dynamic predicates */
    retractall(playerCount(_)),
    retractall(playerName(_)),
    retractall(playerDice(_)),
    retractall(currentPlayer(_)),
    retractall(totalTroops(_,_)),
    retractall(undeployedTroops(_,_)),
    retractall(deployedTroops(_,_)),
    retractall(ruler(_,_)),
    retractall(unclaimedTerritory(_)),
    retractall(globalTroops(_)),
    retractall(listTerritory(_,_)),
    retractall(player(_,_)),
    retractall(activeTroops(_,_)),
    retractall(drawnRiskk(_,_)),
    retractall(checkRisk(_,_)),

    /* Initiate dynamic predicates */
    assertz(globalTroops(24)),
    assertz(unclaimedTerritory([na1,na2,na3,na4,na5,
                                e1,e2,e3,e4,e5,
                                a1,a2,a3,a4,a5,a6,a7,
                                sa1,sa2,
                                af1,af2,af3,
                                au1,au2])),
    assertz(player(p1, none)),
    assertz(player(p2, none)),
    assertz(player(p3, none)),
    assertz(player(p4, none)),

    /* Input player count */
    inputPlayerCount,
    playerCount(PlayerCount),

    /* Input player name to a list*/
    assertz(playerName([])),
    nl, inputPlayerName(0, PlayerCount),
    playerName(PlayerName),

    /* Randomize dice for player turn order */
    assertz(playerDice([])),
    randomizeDice(PlayerName),

    /* Sort descending player turn order */
    playerDice(PlayerDice),
    keysort(PlayerDice, TempResult),
    reverse(TempResult, Result),

    /* Set player name list by turn order */
    retractall(playerName(_)),
    assertz(playerName([])),
    setPlayerName(Result, 0, PlayerCount),

    /* Print player turn order */
    nl, printOrder,

    /* Set current player */
    playerName([First|_]),
    assertz(currentPlayer(First)),
    format('\n~w dapat memulai terlebih dahulu.', [First]),

    /* Initiate troops for player */
    TroopsPerPlayer is 24//PlayerCount,
    initiateTroops(PlayerName, TroopsPerPlayer).
/* -------------------------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------------------------- */
/* Function input player count */
inputPlayerCount :-
    write('\nMasukkan jumlah pemain: '), 
    read(Input),
    setPlayerCount(Input).

setPlayerCount(Input) :-
    (Input >= 2, Input =< 4 -> assertz(playerCount(Input)) ;
    write('Mohon masukkan angka antara 2 - 4.'), inputPlayerCount).
/* -------------------------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------------------------- */
/* Function input player name */
inputPlayerName(X, X) :- !.
inputPlayerName(X, PlayerCount) :-
    Y is X + 1,
    format('Masukan nama pemain ~d: ', [Y]),
    read(Name),
    
    /* Check for unique name input */
    playerName(List),
    \+member(Name, List),

    retractall(playerName(_)),
    append(List, [Name], NewList),
    assertz(playerName(NewList)),

    player(P, none),
    retractall(player(P, none)),
    assertz(player(P, Name)),
    playerCount(PCount),
    Troops is 48//PCount,
    assertz(activeTroops(Name, Troops)),
    assertz(drawnRisk(Name, 0)),

    /* Initialize empty list for listTerritory */
    assertz(listTerritory(Name, [])),

    /* Recursion */
    inputPlayerName(Y, PlayerCount), !.

    /* Handler non unique name input */
inputPlayerName(X, PlayerCount) :-
    write('Nama sudah terpakai!, silakan input ulang.\n\n'),
    inputPlayerName(X, PlayerCount).
/* -------------------------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------------------------- */
/* Function randomize player turn order */
randomizeDice([]).
randomizeDice([Name|Rest]) :- 
    random(1, 13, Roll),
    format('\n~w melempar dadu dan mendapatkan ~d.', [Name, Roll]),
    playerDice(PD),
    retractall(playerDice(_)),
    append(PD, [Roll-Name], NewPD),
    assertz(playerDice(NewPD)),

    /* Recursion */
    randomizeDice(Rest).
/* -------------------------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------------------------- */
/* Function set player name list by turn order */
setPlayerName(_, PlayerCount, PlayerCount).
setPlayerName([_-Name|Rest], Loop, PlayerCount) :-
    playerName(List),
    append(List, [Name], NewList),
    retractall(playerName(_)),
    assertz(playerName(NewList)),
    Next is Loop+1,

    /* Recursion */
    setPlayerName(Rest, Next, PlayerCount).
/* -------------------------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------------------------- */
/* Function print player order */
printOrder :-
    write('\nUrutan pemain: '),
    playerName(PlayerName),
    printPlayerName(PlayerName).

printPlayerName([Name]) :- 
    write(Name).
printPlayerName([Name|Rest]) :-
    format('~w - ', [Name]),
    printPlayerName(Rest).
/* -------------------------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------------------------- */
/* Function initiate troops */
initiateTroops([], _) :-
    playerCount(Count),
    format('\n\nSetiap pemain mendapatkan ~d tentara.\n', [48//Count]),
    currentPlayer(CP),
    format('\nGiliran ~w untuk memilih wilayahnya.', [CP]).
initiateTroops([Name|Rest], TroopsPerPlayer) :- 
    assertz(totalTroops(Name, TroopsPerPlayer)),
    assertz(undeployedTroops(Name, TroopsPerPlayer)),
    initiateTroops(Rest, TroopsPerPlayer).
/* -------------------------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------------------------- */
/* Function draft */
draftInitiate(Territory, Count) :-                 % Input for this function assumes true, validation is done pre function call
    deployedTroops(Territory, Current),
    New is Current + Count,
    retractall(deployedTroops(Territory, _)),
    assertz(deployedTroops(Territory, New)).
/* -------------------------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------------------------- */
/* Function next player */
nextPlayerInitiate :-
    currentPlayer(CP),
    playerName(List),
    playerCount(PlayerCount),
    getIndex(List, CP, Idx),
    (
     /* if   */ Idx + 1 > PlayerCount -> 
            NextIdx is 1;
     /* else */ 
            NextIdx is Idx + 1
    ),
    getElement(List, NextIdx, NextPlayer),
    retractall(currentPlayer(_)),
    assertz(currentPlayer(NextPlayer)), !.

nextPlayer :-
    currentPlayer(CP),
    playerName(List),
    playerCount(PlayerCount),
    getIndex(List, CP, Idx),
    (
     /* if   */ Idx + 1 > PlayerCount -> 
            NextIdx is 1;
     /* else */ 
            NextIdx is Idx + 1
    ),
    getElement(List, NextIdx, NextPlayer),
    retractall(currentPlayer(_)),
    assertz(currentPlayer(NextPlayer)), 
    
    listTerritory(NextPlayer, ListTerritory),
    count(ListTerritory, Len),
    
    (Len < 1 -> nextPlayer; true), !.

/* -------------------------------------------------------------------------------------------- */  


/* -------------------------------------------------------------------------------------------- */
/* Function take location */

    /* Invalid input condition */
takeLocation(Territory) :-
    possibleTerritory(List),
    \+member(Territory, List),
    write('\nWilayah tidak valid!'),
    currentPlayer(CP),
    format('\n\nGiliran ~w untuk memilih wilayahnya.\n', [CP]), !.

    /* Normal condition */
takeLocation(Territory) :-
    unclaimedTerritory(ListUnclaimedTerritory),
    member(Territory, ListUnclaimedTerritory),
    currentPlayer(CP),
    assertz(ruler(Territory, CP)),
    subtract(ListUnclaimedTerritory, [Territory], NewListUnclaimedTerritory),
    retractall(unclaimedTerritory(_)),
    assertz(unclaimedTerritory(NewListUnclaimedTerritory)),
    format('\n~w mengambil wilayah ~w.', [CP, Territory]),

    /* Initialize 1 troop for each territory */
    assertz(deployedTroops(Territory, 1)),

    /* Add said territory to listTerritory */
    listTerritory(CP, ListTerritory), 
    append(ListTerritory, [Territory], NewListTerritory),
    retractall(listTerritory(CP, _)),
    assertz(listTerritory(CP, NewListTerritory)),
    
    nextPlayerInitiate,
    currentPlayer(NextPlayer),
     
    count(NewListUnclaimedTerritory, LeftUnclaimed),
    (
     /*  if  */  LeftUnclaimed > 0 -> 
            format('\n\nGiliran ~w untuk memilih wilayahnya.\n', [NextPlayer]) ;

     /* else */  
            write('\n\nSeluruh wilayah telah diambil pemain.'), 
            write('\nMemulai pembagian sisa tentara.'), 
            format('\n\nGiliran ~w untuk meletakan tentaranya.\n', [NextPlayer])
    ), !.

/* Territory already ruled */
takeLocation(_) :-
    write('\nWilayah sudah dikuasai. Tidak bisa mengambil.'),
    currentPlayer(CP),
    format('\n\nGiliran ~w untuk memilih wilayahnya.\n', [CP]), !.
/* -------------------------------------------------------------------------------------------- */  


/* -------------------------------------------------------------------------------------------- */
/* Function place troops */

    /* Territory not yours */
placeTroops(Territory, _) :- 
    currentPlayer(CP), 
    \+ruler(Territory, CP),
    write('\nWilayah tersebut milik pemain lain.'),
    write('\nSilahkan pilih wilayah lain.'), 
    format('\n\nGiliran ~w untuk meletakan tentaranya.\n', [CP]),!.

    /* Not enough troops */
placeTroops(_, Count) :-
    currentPlayer(CP), 
    undeployedTroops(CP, AvailableTroops),
    Count > AvailableTroops,
    write('\nTentara yang dimiliki tidak cukup'),
    format('\nTerdapat ~d tentara yang tersisa', [AvailableTroops]),
    format('\n\nGiliran ~w untuk meletakan tentaranya.\n', [CP]), !.

    /* Normal condition */
placeTroops(Territory, Count) :-
    Count > 1,
    currentPlayer(CP), 
    undeployedTroops(CP, AvailableTroops),
    TroopsLeft is AvailableTroops-Count,
    globalTroops(LeftGlobal),
    TroopsLeftGlobal is LeftGlobal-Count,

    draftInitiate(Territory, Count),
    format('\n~w meletakan ~d tentara di wilayah ~w', [CP, Count, Territory]),

    retractall(undeployedTroops(CP,_)), assertz(undeployedTroops(CP, TroopsLeft)),
    retractall(globalTroops(_)), assertz(globalTroops(TroopsLeftGlobal)),

    (
     /*  if  */  TroopsLeft > 0 -> 
            format('\nTerdapat ~d tentara yang tersisa.', [TroopsLeft]),
            format('\n\nGiliran ~w untuk meletakan tentaranya.\n', [CP]);

     /* else */                    
            format('\n\nSeluruh tentara ~w telah diletakkan\n', [CP]), 

            /* Next Player */
            nextPlayerInitiate,
            currentPlayer(NextPlayer),
            (
             /*  if  */ TroopsLeftGlobal > 0 -> 
                    format('\nGiliran ~w untuk meletakan tentaranya.\n', [NextPlayer]);

            /* else */ 
                    write('Seluruh pemain telah meletakkan sisa tentara.\n'),
                    write('\n .d8888b.         d8888 888b     d888 8888888888       .d8888b. 88888888888     d8888 8888888b. 88888888888\nd88P  Y88b       d88888 8888b   d8888 888             d88P  Y88b    888        d88888 888   Y88b    888\n888    888      d88P888 88888b.d88888 888             Y88b.         888       d88P888 888    888    888\n888            d88P 888 888Y88888P888 8888888          "Y888b.      888      d88P 888 888   d88P    888\n888  88888    d88P  888 888 Y888P 888 888                 "Y88b.    888     d88P  888 8888888P"     888\n888    888   d88P   888 888  Y8P  888 888                   "888    888    d88P   888 888 T88b      888\nY88b  d88P  d8888888888 888   "   888 888             Y88b  d88P    888   d8888888888 888  T88b     888\n "Y8888P88 d88P     888 888       888 8888888888       "Y8888P"     888  d88P     888 888   T88b    888\n'),
                    endTurn
            )
    ), !.

    /* Non positive count input */
placeTroops(_, _) :-
    write('Input anda tidak valid! Jumlah tentara harus integer positif.\n'),
    currentPlayer(CP),
    format('\nGiliran ~w untuk meletakan tentaranya.\n', [CP]).
/* -------------------------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------------------------- */
/* Function place automatic */
placeAutomatic :-
    currentPlayer(CP),
    listTerritory(CP, List),
    undeployedTroops(CP, TroopsAvailable),

    random(1, 7, TerritoryIdx),
    MaxTroops is TroopsAvailable+1,
    random(1, MaxTroops, Place),

    getElement(List, TerritoryIdx, Territory),
    draftInitiate(Territory, Place),

    TroopsLeft is TroopsAvailable-Place,
    format('\n~w meletakkan ~d tentara di wilayah ~w.', [CP, Place, Territory]),
    retractall(undeployedTroops(CP, _)),
    assertz(undeployedTroops(CP, TroopsLeft)),

    globalTroops(LeftGlobal),
    TroopsLeftGlobal is LeftGlobal-Place,
    retractall(globalTroops(_)), 
    assertz(globalTroops(TroopsLeftGlobal)),

    (
     /*  if  */  TroopsLeft > 0 ->
            placeAutomatic;
     /* else */  
            format('\nSeluruh tentara ~w sudah diletakkan.\n', [CP]),
            nextPlayerInitiate, currentPlayer(NextPlayer),
            (
             /*  if  */ TroopsLeftGlobal > 0 ->
                    format('\nGiliran ~w untuk meletakkan tentaranya.', [NextPlayer]);
             /* else */
                    write('\nSeluruh pemain telah meletakkan sisa tentara.\n'),
                    write('\n .d8888b.         d8888 888b     d888 8888888888       .d8888b. 88888888888     d8888 8888888b. 88888888888\nd88P  Y88b       d88888 8888b   d8888 888             d88P  Y88b    888        d88888 888   Y88b    888\n888    888      d88P888 88888b.d88888 888             Y88b.         888       d88P888 888    888    888\n888            d88P 888 888Y88888P888 8888888          "Y888b.      888      d88P 888 888   d88P    888\n888  88888    d88P  888 888 Y888P 888 888                 "Y88b.    888     d88P  888 8888888P"     888\n888    888   d88P   888 888  Y8P  888 888                   "888    888    d88P   888 888 T88b      888\nY88b  d88P  d8888888888 888   "   888 888             Y88b  d88P    888   d8888888888 888  T88b     888\n "Y8888P88 d88P     888 888       888 8888888888       "Y8888P"     888  d88P     888 888   T88b    888\n'),
                     /*  part of endTurn  */ 
                    endTurn
                    
            )
    ), !.
/* -------------------------------------------------------------------------------------------- */



/* -------------------------------------------------------------------------------------------- */
/*Function Check kemenangan*/
checkWin(Player):-
    listTerritory(Player,LT), count(LT,Len),
    (Len=24 -> write('~w telah memenangkan permainan.',[Player]),
    write('    ##  || #HH| ##  ||  ##  ||  #|  ##  ||##HH||'),nl,             
    write('    ##  ||##  ||##  ||  ##  || #HH| ##  ||#'),nl,                  
    write('     #HH| ##  ||##  ||  ##HH||##  ||##  ||##HH|'),nl,              
    write('      #|  ##  ||##  ||  ##  ||##HH|| #HH| ##'),nl,                 
    write('      #|   #HH|  #HH|   ##  ||##  ||  #|  ##HH||'),nl,             
    nl,                                                             
    write('     #HH|  #HH| ##  || #HH| ##  ||##HH||##HH| ##HH||##HH|'),nl,    
    write('    ##  ||##  ||##H ||##  ||##  ||#     ##  ||#     ##  ||'),nl,   
    write('    ##  ||##  ||##HH||##  ||##  ||##HH| ##HH| ##HH| ##  ||'),nl,   
    write('    ## H| ##  ||## H||## H| ##  ||##    ## H| ##    ##  ||'),nl,   
    write('     #HHH| #HH| ##  || #HHH| #HH| ##HH||##  ||##HH||##HH|'),nl,    
    nl,                                                             
    write('    ##HH||##  ||##HH||  ##   || #HH| ##HH| ##   ##HH|'),nl,        
    write('      #|  ##  ||#       ## H ||##  ||##  ||##   ##  ||'),nl,       
    write('      #|  ##HH||##HH|   ###HH||##  ||##HH| ##   ##  ||'),nl,       
    write('      #|  ##  ||##      ### H||##  ||## H| ##   ##  ||'),nl,       
    write('      #|  ##  ||##HH||  ##   || #HH| ##  ||##HH|##HH|\n')
    ;true).
/* -------------------------------------------------------------------------------------------- */