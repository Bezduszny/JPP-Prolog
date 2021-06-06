%dziecko(Dziecko, Matka, Ojciec, Plec).
dziecko(jasio, ewa, jan, ch).
dziecko(stasio, ewa, jan, ch).
dziecko(jan, zofia, adam, ch).
dziecko(adam, anna, jakub, ch).

ojciec(Ojciec, Dziecko) :- dziecko(Dziecko, _, Ojciec, _).

matka(Matka, Dziecko) :- dziecko(Dziecko, Matka, _, _).

syn(Dziecko,Matka, Ojciec) :- dziecko(Dziecko, Matka, Ojciec, ch).
corka(Dziecko, Matka, Ojciec) :- dziecko(Dziecko, Matka, Ojciec, dz).
dziecko(Dziecko, Matka, Ojciec) :- dziecko(Dziecko, Matka, Ojciec, _).

rodzic(Rodzic, Dziecko) :- dziecko(Dziecko, Rodzic, _).
rodzic(Rodzic, Dziecko) :- dziecko(Dziecko, _, Rodzic).

babcia(Dziecko, Babcia) :- rodzic(Rodzic, Dziecko), matka(Babcia, Rodzic).

wnuk(Wnuk, Dziadostwo) :- rodzic(Dziadostwo, Rodzic), rodzic(Rodzic, Wnuk).

przodek(Przodek, Potomek) :- rodzic(Przodek, Potomek).
przodek(Przodek, Potomek) :- rodzic(Rodzic, Potomek), przodek(Przodek, Rodzic).

%Operacje na liczbach naturalnych (0, s/1) Zdefiniować predykaty:

%a) nat(x) wtw, gdy x jest liczbą naturalną
nat(0).
nat(s(X)) :- nat(X).

%b) plus(x, y, z) wtw, gdy x+y=z
plus(0, Y, Y) :- nat(Y).
plus(s(X), Y, s(T)) :- plus(X, Y, T).

%c) minus(x, y, z) wtw, gdy x−y=z\
minus(Y,Y,0) :- nat(Y).
minus(s(X), Y, s(T)) :- minus(X,Y,T).

%d) fib(k, n) wtw, gdy n=k-ta liczba Fibonacciego
fib(0, 0).
fib(s(0), s(0)).
fib(s(s(K)), N) :- fib(s(K), M), fib(K, L), plus(L, M, N).

%Proste relacje na listach. Zdefiniować predykaty:

%a) lista(L) wtw, gdy L jest (prologową) listą
lista([]).
lista([_|_]).

%b) pierwszy(E, L) wtw, gdy E jest pierwszym elementem L
pierwszy(E, [E|_]).

%c) ostatni(E, L) wtw, gdy E jest ostatnim elementem L
ostatni(E, [E]).
ostatni(E, [_|T]) :- ostatni(E, T).

%d) element(E, L) wtw, gdy E jest (dowolnym) elementem L (czyli member/2)
element(E, [E|_]).
element(E,[_|T]) :- element(E, T).

%e) scal(L1, L2, L3) wtw, gdy L3 = konkatenacja listy L1 z L2 (czyli append/3),
scal([], L, L).
scal([E|T1], L2, [E|T3]) :- scal(T1, L2, T3).

%f) intersect(Z1,Z2) wtw, gdy zbiory (listy) Z1 i Z2 mają niepuste przecięcie
intersect(Z1, Z2) :- element(E, Z1), element(E, Z2).

%g) podziel(Lista, NieParz, Parz) == podział danej listy na dwie podlisty zawierające odpowiednio kolejne elementy z parzystych (nieparzystych) pozycji
podziel([], [], []).
podziel([E], [E], []).
podziel([Pierwszy|[Drugi|Ogon]], [Pierwszy|NieParz], [Drugi|Parz]) :- podziel(Ogon, NieParz, Parz). 

%h) prefiks(P,L) gdy lista P jest prefiksem listy L
prefiks([], _).
prefiks([E|P], [E|L]) :- prefiks(P, L).

%i) podlista(P, L) wtw, gdy P jest spójną podlistą L
podlista(P, L) :- prefiks(P, L).
podlista(P, [_|L]) :- podlista(P, L).

%j) podciag(P, L) wtw, gdy P jest podciągiem L (czyli niekoniecznie spójną podlistą) (preferowane rozwiązanie: każdy podciąg wygenerowany jeden raz)
%podciag([], _).
%podciag([E | P], [E | L]) :- podciag(P, L).
%podciag(P, [_|L]) :- podciag(P, L). 

%Z jakiegos powodu to jest lepsze.
podciag([], _).
podciag([E | P], [E | L]) :- podciag(P, L).
podciag([E | P], [_ | L]) :- podciag([E | P], L).

%k) wypisz(L) == czytelne wypisanie elementów listy L, z zaznaczeniem jeśli lista pusta (np. elementy oddzielane przecinkami, po ostatnim elemencie kropka)

%l) sortowanie przez wstawianie:
%    insertionSort(Lista, Posortowana),
%    insert(Lista, Elem, NowaLista)
%m) Dodatkowo, być może do domu: srodek(E, L) wtw, gdy E jest środkowym elementem L (lista nieparzystej długości; np. srodek(3,[1,2,3,4,5]))

%Uwagi:

%w tym zadaniu nie używamy jeszcze arytmetyki (nie trzeba)
%poszukiwane rozwiązanie o koszcie liniowym.