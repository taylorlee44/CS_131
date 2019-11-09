%rotate function based off of code found on Stack overflow at this link: 
%https://stackoverflow.com/questions/4280986/how-to-transpose-a-matrix-in-prolog

tower(N, T, counts(Top, Bottom, Left, Right)):-
	length(T,N), 
	t_checkrows(T,N), 
	t_rotate(T, NewT), 
	t_checkrows(NewT, N),
	t_verifyhints(T, Left, Right),
	t_verifyhints(NewT, Top, Bottom)
.

t_checkrows([], N).
t_checkrows([H|T], N):-
	t_checklist(H, N), t_checkrows(T, N).

t_checklist(List, N):-
	length(List, N), 
	fd_domain(List, 1, N), 
	fd_all_different(List), 
	fd_labeling(List).

t_rotate( [] ,  []  ).
t_rotate( [ [] | _ ], [] ).
t_rotate( Square, [Newrow | Restofrows] ):-
	t_rotatehelper(Square, Newrow, Leftover),
	t_rotate(Leftover, Restofrows).

t_rotatehelper([], [], []).
t_rotatehelper([[SmallHead | Tail] | Rows], [SmallHead | SmallHeadTail], [Tail | Tailleft]):-
	t_rotatehelper(Rows, SmallHeadTail, Tailleft).

t_verifyhints([], [], []).
t_verifyhints( [H|T] , [Hleft | Tleft], [Hright | Tright]):-
	t_counter(H, 0, Hleft), 
	reverse(H, H2), 
	t_counter(H2, 0, Hright),
	t_verifyhints( T, Tleft, Tright). 

t_counter([], _, 0).
t_counter([H|T], Max, Amount):-
	H#>Max,
	Newamount #= Amount-1,
	t_counter(T, H, Newamount).
t_counter([H|T], Max, Amount):-
	H#<Max,
	t_counter(T, Max, Amount).

%-----------------------PLAIN TOWER------------------------------------

plain_tower(N, T, counts(Top, Bottom, Left, Right)):-
	length(T,N), %The size of T is 
	checkRows(T, N), % Each row in T is individually unique and within N range
	rotate(T, RotatedT), 
	checkRows(RotatedT, N),
	verifyhints(T, Left, Right),
	verifyhints(RotatedT, Top, Bottom)
	.

checkRows([], N).
checkRows([H|T], N):- 
	uniquelist(H, N), checkRows(T, N).

uniquelist(List, N):-
	length(List, N),
	elements_between(List, 1, N),
	all_unique(List).

all_unique([]).
all_unique([F|R]):- \+member(F,R), all_unique(R).

elements_between([], _, _).
elements_between([H|T], Min, Max):-
	between(Min, Max, H), 
	elements_between(T, Min, Max). 

rotate([], [] ).
rotate( [ [] | _ ], [] ).
rotate( Square, [Newrow | Restofrows] ):-
	rotatehelper(Square, Newrow, Leftover),
	rotate(Leftover, Restofrows).

rotatehelper([], [], []).
rotatehelper([[SmallHead | Tail] | Rows], [SmallHead | SmallHeadTail], [Tail | Tailleft]):-
	rotatehelper(Rows, SmallHeadTail, Tailleft).

verifyhints([], [], []).
verifyhints( [H|T] , [Hleft | Tleft], [Hright | Tright]):-
	counter(H, 0, Hleft), 
	reverse(H, H2), 
	counter(H2, 0, Hright),
	verifyhints( T, Tleft, Tright). 

counter([], _, 0).
counter([H|T], Max, Amount):-
	H#>Max,
	Newamount #= Amount-1,
	counter(T, H, Newamount).
counter([H|T], Max, Amount):-
	H#<Max,
	counter(T, Max, Amount).



%---------------------AMBIGUOUS PUZZLE--------------------------------


ambiguous(N, C, T1, T2):-
tower(N, T1, C), 
tower(N, T2, C), 
T1\=T2.

%-------------------TEST CASES--------------------


speedup(X):-
	statistics(cpu_time, _),
	tower(4, T, counts([3,3,2,1], [2,1,3,3], [4,2,1,2], [1,2,4,2])),
	statistics(cpu_time, [First, Second | _]), 
	plain_tower(4, T2, counts([3,3,2,1], [2,1,3,3], [4,2,1,2], [1,2,4,2])),
	statistics(cpu_time, [First2, Second2 | _]), 
	X is (Second2 / Second).

	