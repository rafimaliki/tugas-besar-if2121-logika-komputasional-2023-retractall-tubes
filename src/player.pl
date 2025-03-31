checkPlayerDetail(P) :- 
    player(P, Name),
    listTerritory(Name, ListTerritory),
    count(ListTerritory, CountTerritory),
    activeTroops(Name, CountActive),
    undeployedTroops(Name, CountUndeployed),
    listBenuaPlayer(Name, Benua),
    format('\nPLAYER ~w', [P]), 
    nl,
    format('\nNama                   : ~w', [Name]),
     write('\nBenua                  : '), writeBenua(Benua),
    format('\nTotal Wilayah          : ~d', [CountTerritory]),
    format('\nTotal Tentara Aktif    : ~d', [CountActive]),
    format('\nTotal Tentara Tambahan : ~d', [CountUndeployed]).


checkPlayerTerritories(P) :-
    player(P, Name),
    listTerritory(Name, ListTerritory),

    intersect(ListTerritory, [na1,na2,na3,na4,na5], ListNA),
    intersect(ListTerritory, [e1,e2,e3,e4,e5], ListEU),
    intersect(ListTerritory, [a1,a2,a3,a4,a5,a6,a7], ListAS),
    intersect(ListTerritory, [sa1,sa2], ListSA),
    intersect(ListTerritory, [af1,af2,af3], ListAF),
    intersect(ListTerritory, [au1,au2], ListAU),

    count(ListNA, CountNA),
    count(ListEU, CountEU),
    count(ListAS, CountAS),
    count(ListSA, CountSA),
    count(ListAF, CountAF),
    count(ListAU, CountAU),

    format('\nNama\t\t: ~w', [Name]), nl,

    (
    CountNA > 0 ->
        format('\nBenua Amerika Utara (~d/5)', [CountNA]),
        loopPrintLocation(ListNA) ; write('')
    ),
    (
    CountEU > 0 ->
        format('\nBenua Eropa (~d/5)', [CountEU]),
        loopPrintLocation(ListEU) ; write('')
    ),
    (
    CountAS > 0 ->
        format('\nBenua Asia (~d/7)', [CountAS]),
        loopPrintLocation(ListAS) ; write('')
    ),
    (
    CountSA > 0 ->
        format('\nBenua Amerika Selatan (~d/2)', [CountSA]),
        loopPrintLocation(ListSA) ; write('')
    ),
    (
    CountAF > 0 ->
        format('\nBenua Afrika (~d/3)', [CountAF]),
        loopPrintLocation(ListAF) ; write('')
    ),
    (
    CountAU > 0 ->
        format('\nBenua Australia (~d/2)', [CountAU]),
        loopPrintLocation(ListAU) ; write('')
    ).


checkIncomingTroops(P) :-
    player(P, Name),
    listTerritory(Name, ListTerritory),

    count(ListTerritory, LenTerritory),
    Extra1 is LenTerritory//2,

    format('\nNama\t\t\t\t\t: ~w', [Name]), 
    format('\nTotal wilayah\t\t\t\t: ~w', [LenTerritory]), 
    format('\nJumlah tentara tambahan dari wilayah\t: ~w', [Extra1]),

    listBenuaPlayer(Name, ListBenua),

    (
    member('Amerika Utara', ListBenua) ->
        Extra2 is Extra1 + 3,
        write('\nBonus benua Amerika Utara\t\t: 3');
        Extra2 is Extra1
    ),
    (
    member('Eropa', ListBenua) ->
        Extra3 is Extra2 + 3,
        write('\nBonus benua Eropa\t\t\t: 3');
        Extra3 is Extra2
    ),
    (
    member('Asia', ListBenua) ->
        Extra4 is Extra3 + 5,
        write('\nBonus benua Asia\t\t\t: 5');
        Extra4 is Extra3
    ),
    (
    member('Amerika Selatan', ListBenua) ->
        Extra5 is Extra4 + 2,
        write('\nBonus benua Amerika Selatan\t\t: 2');
        Extra5 is Extra4
    ),
    (
    member('Afrika', ListBenua) ->
        Extra6 is Extra5 + 2,
        write('\nBonus benua Afrika\t\t\t: 2');
        Extra6 is Extra5
    ),
    (
    member('Australia', ListBenua) ->
        Extra7 is Extra6 + 1,
        write('\nBonus benua Australia\t\t\t: 1');
        Extra7 is Extra6
    ),
    drawnRisk(Name, Card),
    
    (Card == 'Auxiliary Troops' ->
        Extra8 is Extra7*2,
        format('\nTotal tentara tambahan\t\t\t: ~d (Auxiliary Troops)', [Extra8]);
    (Card == 'Supply Chain Issue' ->
        Extra8 is 0,
        format('\nTotal tentara tambahan\t\t\t: ~d (Supply Chain Issue)', [Extra8]);
    format('\nTotal tentara tambahan\t\t\t: ~d', [Extra7]))
    ).