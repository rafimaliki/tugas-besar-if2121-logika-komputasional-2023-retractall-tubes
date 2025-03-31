/* Function endTurn */
endTurn :- 
        /* Deklarasi counters*/
        retractall(counterMove(_)),
        assertz(counterMove(0)),
        retractall(counterAttack(_)),
        assertz(counterAttack(1)),
        currentPlayer(CP),
        format('\nPlayer ~w mengakhiri giliran\n', [CP]),
        nextPlayer, 
        currentPlayer(NextPlayer),
        listTerritory(NextPlayer,ListW),
        count(ListW,X),
        undeployedTroops(NextPlayer, OldUndeployed),
        Undeployed is 0,

        /* Pengecekan bonus benua*/
        (
            amerikaU(AMu),
            subset(AMu, ListW ) -> NewUndeployed1 is Undeployed + 3; NewUndeployed1 is Undeployed
        ),
        (
            eropa(E),
            subset(E, ListW ) -> NewUndeployed2 is NewUndeployed1 + 3; NewUndeployed2 is NewUndeployed1
        ),
        (
            asia(A),
            subset(A, ListW ) -> NewUndeployed3 is NewUndeployed2 + 5; NewUndeployed3 is NewUndeployed2
        ),
        (
            amerikaS(AMs),
            subset(AMs, ListW ) -> NewUndeployed4 is NewUndeployed3 + 2; NewUndeployed4 is NewUndeployed3
        ),
        (
            afrika(Af),
            subset(Af, ListW ) -> NewUndeployed5 is NewUndeployed4 + 2; NewUndeployed5 is NewUndeployed4
        ),
        (
            australia(Au),
            subset(Au, ListW ) -> NewUndeployed6 is NewUndeployed5 + 1; NewUndeployed6 is NewUndeployed5
        ),
        NewUndeployed is NewUndeployed6 + X // 2,
        format('Sekarang giliran Player ~w!\n', [NextPlayer]),
    
        drawnRisk(NextPlayer, Card),

        (Card == 'Auxiliary Troops' ->
            FinalUndeployed is 2*NewUndeployed,
            format('Player ~w mendapatan ~d tentara tambahan karena memiliki kartu Auxiliary Troops.\n', [NextPlayer, FinalUndeployed]);
        (Card == 'Supply Chain Issue' ->
            FinalUndeployed is 0,
            format('Player ~w mendapatan ~d tentara tambahan karena memiliki kartu Supply Chain Issue.\n', [NextPlayer, FinalUndeployed]);
        FinalUndeployed is NewUndeployed,
        format('Player ~w mendapatan  ~d tentara tambahan.\n', [NextPlayer, FinalUndeployed]) )
        ),

        retractall(undeployedTroops(NextPlayer, _)),
        InsertUndeployed is FinalUndeployed+OldUndeployed,
        assertz(undeployedTroops(NextPlayer, InsertUndeployed)),
        retractall(checkRisk(_)),
        retractall(drawnRisk(NextPlayer, _)),
        assertz(checkRisk(0)),
        assertz(drawnRisk(NextPlayer, 0)).
/* -------------------------------------------------------------------------------------------- */



/* -------------------------------------------------------------------------------------------- */

/* Function move */
move(Pre, Post, Count) :-

    currentPlayer(CP),
    listTerritory(CP, List),
    counterMove(CntMove),
    /* Cek udah berapa kali move*/
    (
        /* IF*/
        CntMove < 3 ->
           (   /* IF */
                member(Pre,List)->
                (
                    /* IF */
                    member(Post,List) ->
                    (
                        deployedTroops(Pre,TroopsPre),
                        deployedTroops(Post,TroopsPost),
                        
                        /* IF */
                        Count < TroopsPre ->
                        /*Berhasil di move */
                            format('~w memindahkan ~d tentara dari ~w ke ~w\n\n',[CP,Count,Pre,Post]),
                            SumTroopsPost is TroopsPost + Count,
                            SumTroopsPre is TroopsPre - Count,
                            retractall(deployedTroops(Pre,_)),
                            assertz(deployedTroops(Pre,SumTroopsPre)),
                            retractall(deployedTroops(Post,_)),
                            assertz(deployedTroops(Post,SumTroopsPost)),
                            format('Jumlah tentara di ~w: ~d\n',[Pre,SumTroopsPre]),
                            format('Jumlah tentara di ~w: ~d',[Post,SumTroopsPost]),

                            /* Ubah counter move */
                            retractall(counterMove(_)),
                            CntMoveNew is CntMove + 1,
                            assertz(counterMove(CntMoveNew));
                        /* ELSE */
                            write('Jumlah tentara tidak mencukupi\n'),
                            write('Move dibatalkan\n')
                    );

                    
                    /* ELSE */
                    format("~w tidak punya daerah ~w\n",[CP,Post]),
                    write('Move dibatalkan\n')
                )
                /* ELSE */
                ;
                format("~w tidak punya daerah ~w\n",[CP,Pre]),
                write('Move dibatalkan\n')
            )
            ;
            write('Anda sudah move lebih dari 3 kali\n'),
            write('Move dibatalkan\n')
    ),!. 

/* CHEAT Taking others territory that current player doesnt own */
removeTerritory(X,List,Result):-
    delete(List,X,Result).


territoryAcquisition(Territory) :-
    currentPlayer(CP),
    listTerritory(CP,ListTer),
    (
            \+member(Territory,ListTer) ->
                ruler(Territory,PrevOwner),
                listTerritory(PrevOwner,ListPrevOwner),
                removeTerritory(Territory,ListPrevOwner,FinalListPrevOwner),
                retractall(listTerritory(PrevOwner,_)),
                assertz(listTerritory(PrevOwner,FinalListPrevOwner)),
                append([Territory],ListTer,FinalListTer),
                retractall(listTerritory(CP,_)),
                assertz(listTerritory(CP,FinalListTer)),
                format('~w dimiliki ~w sekarang diakuisisi oleh ~w\n',[Territory,PrevOwner,CP])
            ;
            format('~w sudah memiliki ~w\n ',[CP, Territory])
    ),!.
/* -------------------------------------------------------------------------------------------- */



/* -------------------------------------------------------------------------------------------- */
/* Function Draft */
draft(Territory, Count) :-
    currentPlayer(CP),
    listTerritory(CP, List),
    (
        member(Territory, List) ->
            (
                format('\nPlayer ~w meletakkan ~d tentara tambahan di ~w', [CP, Count, Territory]),
                undeployedTroops(CP, Undeployed),
                (
                    Count < Undeployed ->
                        
                            deployedTroops(Territory, Before),
                            New is Before + Count,
                            retractall(deployedTroops(Territory, _)),
                            assertz(deployedTroops(Territory, New)),
                            retractall(undeployedTroops(CP, _)),
                            NewUndeployed is Undeployed - Count,
                            assertz(undeployedTroops(CP, NewUndeployed)),
                            format('\nTentara total di ~w: ~d', [Territory, New]),
                            format('\nJumlah Pasukan Tambahan ~w: ~d',[CP,NewUndeployed])
                        ;
                    /* Else */ write('\nDraft dibatalkan.')
                )
            );
        /* Else */
        format('\nPlayer ~w tidak memiliki wilayah ~w', [CP, Territory])
    ), !.


       

/* CHEAT NAMBAH UNDEPLOYED TROOPS */
addUndeployed(CP,Count) :-
    undeployedTroops(CP, TroopsLeft),
    retractall(undeployedTroops(CP, _)),
    New is TroopsLeft + Count,
    assertz(undeployedTroops(CP, New)).
/* -------------------------------------------------------------------------------------------- */

listBenuaPlayer(Player, NewList) :-
    listTerritory(Player, ListW),
    listBenuaPlayerHelper(ListW, [], NewList).

listBenuaPlayerHelper([], Acc, Acc).

listBenuaPlayerHelper(ListW, Acc, NewList) :-
    (   amerikaU(AMu),
        subset(AMu, ListW) -> append(Acc, ['Amerika Utara'], UpdatedAcc)
    ;   UpdatedAcc = Acc
    ),
    (   eropa(E),
        subset(E, ListW) -> append(UpdatedAcc, ['Eropa'], UpdatedAcc1)
    ;   UpdatedAcc1 = UpdatedAcc
    ),
    (   asia(A),
        subset(A, ListW) -> append(UpdatedAcc1, ['Asia'], UpdatedAcc2)
    ;   UpdatedAcc2 = UpdatedAcc1
    ),
    (   amerikaS(AMs),
        subset(AMs, ListW) -> append(UpdatedAcc2, ['Amerika Selatan'], UpdatedAcc3)
    ;   UpdatedAcc3 = UpdatedAcc2
    ),
    (   afrika(Af),
        subset(Af, ListW) -> append(UpdatedAcc3, ['Afrika'], UpdatedAcc4)
    ;   UpdatedAcc4 = UpdatedAcc3
    ),
    (   australia(Au),
        subset(Au, ListW) -> append(UpdatedAcc4, ['Australia'], NewList)
    ;   NewList = UpdatedAcc4
    ).

