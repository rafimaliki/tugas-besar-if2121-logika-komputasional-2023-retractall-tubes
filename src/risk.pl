riskCard(['Ceasefire Order','Super Soldier Serum','Auxiliary Troops','Rebellion','Disease Outbreak','Supply Chain Issue']).

risk :-
    checkRisk(0),
    retractall(checkRisk(_)),
    assertz(checkRisk(1)),
    random(1, 7, Risk),
    riskCard(RiskCard),
    getElement(RiskCard, Risk, Card),
    currentPlayer(CP),
    retractall(drawnRisk(CP,_)),
    assertz(drawnRisk(CP, Card)),
    
    write('You have drawn a risk card!\n'), nl,
    format('Player ~w mendapat risk card ~w\n', [CP,Card]), nl,
    
    ( /* Ceasefire Order */ /* Positive */
    Risk == 1 ->
        write('Hingga giliran berikutnya, wilayah pemain tidak dapat diserang oleh lawan.\n');
        
    ( /* Super Soldier Serum */ /* Positive */
    Risk == 2 ->
        write('Hingga giliran berikutnya, semua hasil lemparan dadu saat penyerangan dan pertahanan akan bernilai 6\n');
    
    ( /* Auxiliary Troops */ /* Positive */
    Risk == 3 ->
        write('Tentara tambahan yang didapatkan pemain akan bernilai 2 kali lipat.\n');
    
    ( /* Rebellion */ /* Negative */
    Risk == 4 ->
        write('Terdapat wilayah pemain yang tentaranya memilih untuk bergabung dengan pihak lawan.\n'),
        rebellion;
    
    ( /* Disease Outbreak */ /* Negative */
    Risk == 5 ->
        write('Hingga giliran berikutnya semua hasil lemparan dadu saat penyerangan dan pertahanan akan bernilai 1.\n');
                            
    /* Supply Chain Issue */ /* Negative */
        write('Pemain tidak mendapatkan tentara tambahan pada giliran berikutnya.\n')
    
    ))))), !.

risk :- 
    currentPlayer(CP),
    format('\nPlayer ~w sudah mengambil risk untuk turn ini.', [CP]),
    write('\nTidak bisa mengambil risk lagi sampai turn selanjutnya.'), !.


        
/* Implemen Disease Outbreak */

risk :- 
    currentPlayer(CP),
    format('\nPlayer ~w sudah mengambil risk untuk turn ini.', [CP]).

/* Implemen Rebellion */
rebellion :-
    currentPlayer(CP),
    listTerritory(CP,ListTerritory),
    /* subtract(List,ListTerritory,ResultTerritory), */
    count(ListTerritory, Count),
    NewCount is Count + 1,
    random(1,NewCount,Idx),
    getElement(ListTerritory, Idx, Territory),
    playerName(ListPlayer),
    
    /* random player */
    subtract(ListPlayer,[CP],ResultPlayer),
    count(ResultPlayer, CountPlayer),
    NewCountPlayer is CountPlayer + 1,
    random(1,NewCountPlayer,IdxPlayer),

    /* ambil nama player */
    getElement(ResultPlayer, IdxPlayer, NewRuler),

    format('Wilayah ~w melakukan pemberontakan!\n',[Territory]),
        format('Wilayah ~w sekarang dikuasai oleh player ~w',[Territory,NewRuler]),nl,
        /* Ambil nama penguasa sebelumnya */
    
        /* Update troops old ruler */
        deployedTroops(Territory, Troops),
        totalTroops(CP, OldTotal),
        CPTroops is OldTotal - Troops,
        retractall(totalTroops(CP,_)),
        assertz(totalTroops(CP,CPTroops)),
        
        
        /* Update troops newRuler */
        totalTroops(NewRuler, Total),
        NewTroops is Total + Troops,
        retractall(totalTroops(NewRuler,_)),
        assertz(totalTroops(NewRuler,NewTroops)),

        /* Update ruler */
        retractall(ruler(Territory,_)),
        assertz(ruler(Territory,NewRuler)),

        /* Update list territory */
        listTerritory(NewRuler,ListTerritoryNewRuler),
        retractall(listTerritory(NewRuler,_)),
        append(ListTerritoryNewRuler,[Territory],NewList),
        assertz(listTerritory(NewRuler,NewList)),

        
        /* Update list territory old ruler */
        listTerritory(CP,OldList),
        retractall(listTerritory(CP,_)),
        subtract(OldList,[Territory],NewOldList),
        assertz(listTerritory(CP,NewOldList)),

        /* Update Active Troops NewRuler */
        activeTroops(NewRuler, OldActive),
        NewActive is OldActive + Troops,
        retractall(activeTroops(NewRuler,_)),
        assertz(activeTroops(NewRuler,NewActive)),

        activeTroops(CP, OldActiveCP),
        NewActiveCP is OldActiveCP - Troops,
        retractall(activeTroops(CP,_)),
        assertz(activeTroops(CP,NewActiveCP)),
        checkWin(NewRuler),!.

setRisk(Player, RiskIdx) :-
    riskCard(Cards),
    getElement(Cards, RiskIdx, Risk),
    retractall(drawnRisk(Player, _)),
    assertz(drawnRisk(Player, Risk)), 
    format('\nRisk card player ~w di set menjadi ~w\n', [Player, Risk]), !.