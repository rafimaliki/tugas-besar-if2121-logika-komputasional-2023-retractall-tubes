
writeFormattedList(List) :-
    writeFormattedList(List, 1).

writeFormattedList([], _).
writeFormattedList([H|T], Index) :-
    format('~d. ~w\n', [Index, H]),
    NextIndex is Index + 1,
    writeFormattedList(T, NextIndex).

chooseArea(AttList, DefendArea):-
    count(AttList, Len),
    write('\nPilih: '), read(Index),
    (Index =< Len, Index > 0 -> getElement(AttList, Index, Input), 
    (ruler(Input,Player),drawnRisk(Player,RiskName), RiskName=='Ceasefire Order' 
    -> write('\nTidak bisa menyerang!\nWilayah ini dalam pengaruh CEASEFIRE ORDER.\n'), chooseArea(AttList, DefendArea) 
    ; DefendArea = Input)
        ; write('\nInput tidak valid. Silahkan input kembali.\n'), chooseArea(AttList, DefendArea)).

readNewTroops(UT,NewTroops,DefendArea):-
    format('\nSilahkan tentukan banyaknya tentara yang menetap di wilayah ~w: ', [DefendArea]),read(Input),
    (Input=<UT,Input>0 -> NewTroops is Input; write('\nInput Tidak valid.'), readNewTroops(UT,NewTroops,DefendArea)).

war(UT, DefendTroops, Attacker, Defender,AttackArea,DefendArea):-
    drawnRisk(Defender,DefendRisk),
    drawnRisk(Attacker,AttackRisk),

    (AttackRisk=='Disease Outbreak'-> format('Tentara ~w dalam pengaruh DISEASE OUTBREAK.',[Attacker]) 
        ; (AttackRisk=='Super Soldier Serum' -> format('Tentara ~w dalam pengaruh SUPER SOLDIER SERUM.',[Attacker]); true)),

    (DefendRisk=='Disease Outbreak'-> format('Tentara ~w dalam pengaruh DISEASE OUTBREAK.',[Defender]) 
        ; (DefendRisk=='Super Soldier Serum' -> format('Tentara ~w dalam pengaruh SUPER SOLDIER SERUM.',[Defender]); true)),

    format('\nPlayer ~w',[Attacker]),
    (AttackRisk=='Disease Outbreak'-> rollForRisk(UT,TotalAttack,1,1) 
    ;(AttackRisk=='Super Soldier Serum' -> rollForRisk(UT,TotalAttack,1,6) 
    ;rollDiceinAttack(UT,TotalAttack,1))),
    format('\nTotal: ~d\n',[TotalAttack]),

    format('\nPlayer ~w',[Defender]),   
    (DefendRisk=='Disease Outbreak'-> rollForRisk(DefendTroops,TotalDefend,1,1) 
    ;(DefendRisk=='Super Soldier Serum' -> rollForRisk(DefendTroops,TotalDefend,1,6) 
    ;rollDiceinAttack(DefendTroops,TotalDefend,1))),
    format('\nTotal: ~d\n',[TotalDefend]),
    nl,
    (TotalDefend<TotalAttack -> 
        format('\nPlayer ~w menang! Wilayah ~w sekarang dikuasai oleh Player ~w.\n',[Attacker, DefendArea, Attacker]),
        territoryAcquisition(DefendArea),
        readNewTroops(UT,NewTroops,DefendArea), 
        retractall(deployedTroops(DefendArea,_)),
        assertz(deployedTroops(DefendArea,0)),
        move(AttackArea,DefendArea,NewTroops),
        counterMove(CNTMove),
        retractall(counterMove(_)),
        NewCNTMove is CNTMove + 1,
        assertz(counterMove(NewCNTMove)),
        activeTroops(Defender, OldActive),
        NewActive is OldActive - DefendTroops,
        retractall(activeTroops(Defender, _)),
        assertz(activeTroops(Defender, NewActive))

        ;(TotalDefend>TotalAttack -> 
            format('Player ~w menang! Sayang sekali penyerangan Anda gagal :(.',[Defender]),
            deployedTroops(AttackArea,CNT),
            UpdatedTroops is CNT - UT,
            retractall(deployedTroops(AttackArea,_)),
            assertz(deployedTroops(AttackArea,UpdatedTroops)),
            deployedTroops(AttackArea,X),
            deployedTroops(DefendArea,Y),
            activeTroops(Attacker, OldActive),
            NewActive is OldActive - UT,
            retractall(activeTroops(Attacker, _)),
            assertz(activeTroops(Attacker, NewActive)),
            format('\nTentara di wilayah ~w: ~d', [AttackArea,X]), 
            format('\nTentara di wilayah ~w: ~d', [DefendArea,Y])
            ; write('\nHasil seri, perang akan diulang.....\n') ,war(UT, DefendTroops, Attacker, Defender,AttackArea,DefendArea))).

rollDiceinAttack(0, 0, _).
rollDiceinAttack(TotalTroops, TotalDice, Index):-
    TotalTroops > 0,
    random(1, 7, CD),
    format('\nDadu ~d: ~d', [Index, CD]),
    NextIndex is Index + 1,
    NewTotalTroops is TotalTroops -1,
    rollDiceinAttack(NewTotalTroops, RestDice, NextIndex),
    TotalDice is RestDice + CD.

rollForRisk(0, 0, _,_).
rollForRisk(TotalTroops, TotalDice, Index, DiceNumber):-
    TotalTroops > 0,
    format('\nDadu ~d: ~d', [Index, DiceNumber]),
    NextIndex is Index + 1,
    NewTotalTroops is TotalTroops -1,
    rollForRisk(NewTotalTroops, RestDice, NextIndex,DiceNumber),
    TotalDice is RestDice + DiceNumber.

readArea(Area):-
    currentPlayer(CP),
    write('\nPilihlah daerah yang ingin Anda mulai untuk melakukan penyerangan: '), read(Input),deployedTroops(Input,X),
    (ruler(Input,CP), X>1 -> Area = Input ; write('\nDaerah tidak valid. Silahkan input kembali.\n'),readArea(Area)).

readUsedTroops(Area,UT):-
    deployedTroops(Area,DT),
    write('\nMasukkan banyak tentara yang akan bertempur: '), read(Input),
    (Input<DT -> UT is Input ; write('\nBanyak tentara tidak valid.\n\nSilahkan input kembali.\n'), readUsedTroops(Area,UT)).

attack:-
    counterAttack(CNTAttack),
    CNTAttack = 1,
    currentPlayer(Attacker), format('\nSekarang giliran Player ~w menyerang\n\n',[Attacker]), 
    displayMap,listTerritory(Attacker,LT),format('\nWilayah milik ~w: ',[Attacker]),write(LT),
    readArea(Area), deployedTroops(Area, DT),
    format('\nPlayer ~w ingin memulai penyerangan dari daerah ~w.\nDalam daerah ~w, Anda memiliki sebanyak ~d tentara\n',[Attacker,Area,Area,DT]),/*pilih daerah, tampilkan deployed troop daerah*/
    readUsedTroops(Area,UT), /*masukkan banyak tentara yang digunakan*/
    
    format('\nPlayer ~w mengirim sebanyak ~d tentara untuk berperang.\n',[Attacker,UT]),
    displayMap,
    neighbour(Area,AttList), /*pilih daerah yang buat diserang, harus bertetangga dan deployedtroop kurang dari tentara yang digunaakan*/
    subtract(AttList,LT,NewAttList),count(NewAttList,Len),
    (Len=0 -> write('Tidak ada wilayah yang dapat diserang dari wilayah yang telah dipilih')
        ;write('Pilihlah daerah yang ingin Anda serang.\n'),
        writeFormattedList(NewAttList),
        chooseArea(NewAttList, DefendArea),
        ruler(DefendArea,Defender),
        deployedTroops(DefendArea,DefendTroops),
        
        write('\nPerang telah dimulai.'),
        war(UT, DefendTroops, Attacker, Defender,Area,DefendArea),
        retractall(counterAttack(_)),
        NewCnt is CNTAttack - 1,
        assertz(counterAttack(NewCnt)),
        checkWin(Attacker)).