%bezpieczny(Brzeg)
% Brzeg to tablica [m, k, b] gdzie m to liczba misjonarzy, k to liczba kanibali i b liczba lodek
bezpieczny([X,Y,_]) :- X >= Y.

jestLodz([_,_,1]).

% przemiesc([0,0,0],[3,3,1]).
% przemiesc(Lewy,Prawy)
przemiesc(Lewy,Prawy) :- wykonajRuch(Lewy,Prawy,NowyLewy,NowyPrawy),
                         bezpieczny(Lewy),
                         bezpieczny(Prawy),
                         przemiesc(NowyLewy,NowyPrawy).


%wykonajRuch(...)
wykonajRuch(Lewy,Prawy,NowyLewy,NowyPrawy) :- jestLodz(Lewy),
                                              przemiesc(Lewy,Prawy,NowyLewy,NowyPrawy).
wykonajRuch(Lewy,Prawy,NowyLewy,NowyPrawy) :- jestLodz(Prawy),
                                              przemiesc(Prawy,Lewy,NowyPrawy,NowyLewy).



przemiesc(Z,Do,NowyZ,NowyDo) :- generujRuch(Ruch),
                                czyMoznaWykonac(Z,Ruch),
                                wykonaj(Z,Do,Ruch,NowyZ,NowyDo).
                                            
generujRuch([1,1,1]).
generujRuch([2,1,1]).
                        

czyMoznaWykonac([StanM,StanK,StanL],[IluPrzemiescicM,IluPrzemiescicK,PrzemiescicL]) :-
    StanM >= IluPrzemiescicM,
    StanK >= IluPrzemiescicK,
    StanL >= PrzemiescicL.


wykonaj([ZM,ZK,ZL],[DoM,DoK,DoL],[RuchM,RuchK,RuchL],[NowyZM,NowyZK,NowyZL],[NowyDoM,NowyDoK,NowyDoL]) :-
    NowyZM = ZM - RuchM,
    NowyZK = ZK - RuchK,
    NowyZL = ZL - RuchL,
    NowyDoM = ZM + RuchM,
    NowyDoK = ZK + RuchK,
    NowyDoL = ZL + RuchL.
