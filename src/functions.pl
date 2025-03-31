/* -------------------------------------------------------------------------------------------- */
/* Other functions */
getElement([A|_], 1, A).
getElement([_|L], Idx, Element) :- 
    Idx > 0, NextIdx is Idx-1, 
    getElement(L, NextIdx, Element), !.

getIndex([X], X, 1).
getIndex([A|_], X, Idx) :- 
    A == X, 
    Idx is 1, !.
getIndex([A|L], X, Idx) :- 
    A \== X, 
    getIndex(L, X, Idx2), 
    Idx is 1+Idx2, !.

count([], 0).
count([_|L], Count) :- count(L, Count2), Count is 1 + Count2.
subset([], _).
subset([H|T], List) :-
    member(H, List),
    subset(T, List).

intersect([], _, []) :- !.
intersect([H1|T1], L2, [H1|Res]) :-
    member(H1, L2),
    intersect(T1, L2, Res), !.
intersect([_|T1], L2, Res) :-
    intersect(T1, L2, Res), !.

/* -------------------------------------------------------------------------------------------- */