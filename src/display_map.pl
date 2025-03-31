/* --------------------------------------Display Map------------------------------------------- */
% print Troops in selected regions
printTroop(X) :-
    deployedTroops(X, A), (A<10 -> write('0'), write(A) ; write(A)).
    
% display map
displayMap :-
    write('#####################################################################################################'),nl,
    write('#         North America          #         Europe           #                 Asia                  #'),nl,
    write('#                                #                          #                                       #'),nl,
    write('#       [NA1('), printTroop(na1), write(')]-[NA2('), printTroop(na2), write(')]      #                          #                                       #'),nl,
    write('-----------|       |----[NA5('), printTroop(na5), write(')]----[E1('), printTroop(e1), write(')]-[E2('), printTroop(e2), write(')]----------[A1('), printTroop(a1), write(')] [A2('), printTroop(a2), write(')] [A3('), printTroop(a3), write(')]-----------'),nl,
    write('#       [NA3('), printTroop(na3), write(')]-[NA4('), printTroop(na4), write(')]      #        |       |         #        |       |       |              #'),nl,
    write('#          |                     #     [E3('), printTroop(e3), write(')]-[E4('), printTroop(e4), write(')]    #        |       |       |              #'),nl,
    write('###########|######################       |       |-[E5('), printTroop(e5), write(')]------[A4('), printTroop(a4), write(')]----+----[A5('), printTroop(a5), write(')]          #'),nl,
    write('#          |                     ########|#######|###########                |                      #'),nl,
    write('#       [SA1('), printTroop(sa1), write(')]                #       |       |          #                |                      #'),nl,
    write('#          |                     #       |    [AF2('), printTroop(af2), write(')]     #            [A6('), printTroop(a6), write(')]---[A7('), printTroop(a7), write(')]        #'),nl,
    write('#   |---[SA2('), printTroop(sa2), write(')]--------------------[AF1('), printTroop(af1), write(')]---|          #                |                      #'),nl,
    write('#   |                            #               |          #################|#######################'),nl,
    write('#   |                            #            [AF3('), printTroop(af3), write(')]     #                |                      #'),nl,
    write('----|                            #                          #            [AU1('), printTroop(au1), write(')]---[AU2('), printTroop(au2), write(')]-------'),nl,
    write('#                                #                          #                                       #'),nl,
    write('#       South America            #         Africa           #              Australia                #'),nl,
    write('#####################################################################################################'),nl.
/* --------------------------------------Display Map------------------------------------------- */