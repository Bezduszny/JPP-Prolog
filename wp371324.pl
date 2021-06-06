% Wiktor Petrykowski 371324
% Rozwiazanie nie zawiera wypisywania niepoprawnych przeplotow
% Poza tym dziala ok na przykladowych programach
% Stan = [Zmienne, Tablice, Liczniki], gdzie:
%   Zmienne - slownik zmiennych programu 
%   Tablice - slownik tablic programu 
%   Liczniki - lista licznikow (wskazuja aktualny numer instrukcji) procesow

ensure_loaded(library(lists)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Wymagane procedury %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initState(Zmienne, Tablice, N, StanPoczatkowy) :- 
    createArray(N, 1, Liczniki),
    initVariables(Zmienne, Variables),
    initArrays(N, Tablice, Arrays),
    StanPoczatkowy = [Variables, Arrays, Liczniki].

% Program to lista instrukcji, ktore mozna dostac uzywajac procedury analyze
step(Program, StanWe, PrId, StanWy) :- 
    StanWe = [_, _, Liczniki],
    PrId >= 0,
    nth0(PrId, Liczniki, NumerAktualnejInstrukcji),
    nth1(NumerAktualnejInstrukcji, Program, Instrukcja),
    run(Instrukcja, StanWe, PrId, StanWy).

verify(N, Program) :- 
    analyze(Program, Analyzed),
    Analyzed = [Zmienne, Tablice, Instrukcje],
    initState(Zmienne, Tablice, 2, StanPoczatkowy),
    StanPoczatkowy = [_, _, Liczniki],
    \+ walk(N, Instrukcje, StanPoczatkowy, [Liczniki]),
    write("Program jest poprawny").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Procedury pomocnicze %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Program - nazwa pliku
analyze(Program, Analyzed) :- 
    see(Program),
    read(variables(Zmienne)),
    read(arrays(Tablice)),
    read(program(Instrukcje)),
    seen,
    Analyzed = [Zmienne, Tablice, Instrukcje].

% Tworzy n-elementowa liste o wartosciach E
createArray(0, _, []).
createArray(N, E, [E|L]) :-
  N > 0,
  N1 is N - 1,
  createArray(N1, E, L). 

% Tworzy slownik {ident:liczba} i ustawia wartosci na 0
initVariables([], _{}).
initVariables([Zmienna|Zmienne], Variables) :- 
    initVariables(Zmienne, Vars),
    Variables = Vars.put(Zmienna, 0).

% Tworzy slownik {ident:tablica}
% ustawia wartosci na N-elementowe listy o wartosciach 0
initArrays(_, [], _{}).
initArrays(N, [NazwaTablicy|Pozostale], Arrays) :-
    createArray(N, 0, NowaTablica),
    initArrays(N, Pozostale, Arrs),
    Arrays = Arrs.put(NazwaTablicy, NowaTablica).

run(assign(Zmienna, Wyrazenie), Stan, Pid, NowyStan) :-
    Stan = [Zmienne, Tablice, Liczniki],
    evalWyrArytm(Stan, Wyrazenie, Pid, Wynik),    
    (   (   % Arnosc 0 wiec zwykla zmienna
            functor(Zmienna, Nazwa, 0), 
            NoweZmienne = Zmienne.put(Nazwa, Wynik),
            NoweTablice = Tablice
        )
        ;   % lub
        (   % element tablicy
            functor(Zmienna, array, 2),
            arg(1, Zmienna, NazwaTablicy),
            arg(2, Zmienna, Wyr),
            Tablica = Tablice.get(NazwaTablicy),
            evalWyrArytm(Stan, Wyr, Pid, Indeks),
            replace(Indeks, Tablica, Wynik, NowaTablica),
            NoweZmienne = Zmienne,
            NoweTablice = Tablice.put(NazwaTablicy, NowaTablica)
        )
    ),
    PosredniStan = [NoweZmienne, NoweTablice, Liczniki],
    gotoNext(PosredniStan, Pid, NowyStan).

run(goto(NumerInstrukcji), Stan, Pid, NowyStan) :-
    Stan = [Zmienne, Tablice, Liczniki],
    replace(Pid, Liczniki, NumerInstrukcji, NoweLiczniki),
    NowyStan = [Zmienne, Tablice, NoweLiczniki].

run(condGoto(WyrLogiczne, NumerInstrukcji), Stan, Pid, NowyStan) :-
    Stan = [Zmienne, Tablice, _],
    functor(WyrLogiczne, OperRel, 2),
    arg(1, WyrLogiczne, WyrProste1),  
    arg(2, WyrLogiczne, WyrProste2),
    evalWyrProste(Zmienne, Tablice, WyrProste1, Pid, Wynik1), 
    evalWyrProste(Zmienne, Tablice, WyrProste2, Pid, Wynik2),
    ( porownanie(OperRel, Wynik1, Wynik2) ->
        run(goto(NumerInstrukcji), Stan, Pid, NowyStan)
    ; %else
        gotoNext(Stan, Pid, NowyStan)
    ).

run(sekcja, Stan, Pid, NowyStan) :- gotoNext(Stan, Pid, NowyStan).

gotoNext(Stan, Pid, NowyStan) :-
    Stan = [_, _, Liczniki],
    nth0(Pid, Liczniki, AktualnyNumerInstrukcji),
    NastepnyNumerInstrukcji is AktualnyNumerInstrukcji + 1,
    run(goto(NastepnyNumerInstrukcji), Stan, Pid, NowyStan).

% Podmienia N-ty element listy L na element E, K to nowo powstala lista
replace(N, L, E, K) :-
    nth0(N, L, _, R),
    nth0(N, K, E, R).

evalWyrArytm([Zmienne, Tablice, _], Wyrazenie, Pid, Wynik) :-
    % Wyrazenie to
    %   wyrazenie proste
    evalWyrProste(Zmienne, Tablice, Wyrazenie, Pid, Wynik)
    ; % lub
    %   +|-|*|/ wyrazen prostych
    (   functor(Wyrazenie, Oper, 2),
        arg(1, Wyrazenie, WyrProste1),
        arg(2, Wyrazenie, WyrProste2),
        evalWyrProste(Zmienne, Tablice, WyrProste1, Pid, Wynik1),
        evalWyrProste(Zmienne, Tablice, WyrProste2, Pid, Wynik2),
        dzialanie(Oper, Wynik1, Wynik2, Wynik)
    ).

dzialanie(+, Skladnik1, Skladnik2, Wynik) :- Wynik is Skladnik1 + Skladnik2.
dzialanie(*, Czynnik1, Czynnik2, Wynik) :- Wynik is Czynnik1 * Czynnik2.
dzialanie(-, Odjemna, Odjemnik, Wynik) :- Wynik is Odjemna - Odjemnik.
dzialanie(/, Dzielna, Dzielnik, Wynik) :- Wynik is Dzielna / Dzielnik.

porownanie(<, L1, L2) :- L1 < L2.
porownanie(=, L1,  L2) :- L1 =:= L2.
porownanie(<>, L1, L2) :- L1 =\= L2.

evalWyrProste(Zmienne, Tablice, Wyrazenie, Pid, Wynik) :-
    (number(Wyrazenie), % liczba
        Wynik = Wyrazenie);
    (atom(Wyrazenie), % pid
        Wyrazenie = pid, 
        Wynik is Pid);
    (atom(Wyrazenie), % zmienna
        Wyrazenie \= pid, 
        Wynik = Zmienne.get(Wyrazenie));
    (functor(Wyrazenie, array, 2), % tablica
        arg(1, Wyrazenie, Ident),
        arg(2, Wyrazenie, WyrArytm),
        evalWyrArytm([Zmienne, Tablice, _], WyrArytm, Pid, Indeks),
        Tablica = Tablice.get(Ident), %wyciagamy odpowiednia tablice ze slownika
        nth0(Indeks, Tablica, Wynik) %zwracamy co jest pod danym indeksem
    ).

range(Low, Low, _).
range(Out,Low,High) :- NewLow is Low+1, NewLow < High, range(Out, NewLow, High).

czyByl(Stan, PoprzednieStany) :- member(Stan, PoprzednieStany).

% true jesli istnieje niebezpieczny przeplot, false jesli nie istnieje
walk(N, Instrukcje, StanWe, OdwiedzoneStany) :-
    range(Pid, 0, N),
    step(Instrukcje, StanWe, Pid, StanWy),
    StanWy = [_, _, Liczniki],
    % Jesli procesy byly juz w danej konfiguracji, to nie trzeba juz tego sprawdzac
    (\+ czyByl(Liczniki, OdwiedzoneStany)),
    NoweOdwiedzoneStany = [Liczniki|OdwiedzoneStany],
    ( czyNiebezpieczny(Instrukcje, StanWy),!
    ;
      walk(N, Instrukcje, StanWy, NoweOdwiedzoneStany)).

% Program jest niebezpieczny, jesli istnieja przynajmniej 2 stany,
% ktorych licznik wskazuje na instrukcje 'sekcja'
% zakladam tutaj, ze sekcja moze sie pojawic wielokrotnie
czyNiebezpieczny(Instrukcje, Stan) :-
    indeksySekcji(1, Instrukcje, Indeksy),
    Stan = [_, _, Liczniki],
    ileWSekcji(Indeksy, Liczniki, N),
    N > 1,
    write("Program jest niepoprawny").

ileWSekcji(_, [], 0).
ileWSekcji(IndeksySekcji, Liczniki, N) :-
    Liczniki = [NumerAktualnejInstrukcji|Pozostale],
    ( member(NumerAktualnejInstrukcji, IndeksySekcji) ->
        ileWSekcji(IndeksySekcji, Pozostale, M),
        N is M + 1
    ;
        ileWSekcji(IndeksySekcji, Pozostale, N)
    ).

indeksySekcji(_, [], []).
indeksySekcji(N, Instrukcje, Indeksy) :-
    Instrukcje = [Instrukcja|Pozostale],
    ( Instrukcja = sekcja -> 
        Indeksy = [N | PozostaleIndeksy]
        ;
        Indeksy = PozostaleIndeksy
    ),
    M is N + 1,
    indeksySekcji(M, Pozostale, PozostaleIndeksy).
