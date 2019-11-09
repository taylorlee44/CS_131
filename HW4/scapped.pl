	
	getheads(List, Heads) :- maplist(nth0(0), List, Heads).

getelement(List, Heads, Iter) :- maplist(nth0(Iter), List, Heads).

checkColumns(_, -1, N,  Heads).
checkColumns([], Iter, N, Heads).
checkColumns(List, Iter, N, Heads):-
	getelement(List, Heads, Iter),
	uniquelist(Heads, N),
	checkColumns(List, (Iter-1), N, _). 

first_of_each([], []).
first_of_each([ [Head | SmallTail ] | BigTail ], [Head | Restofcolumn ]) :- first_of_each(BigTail , Restofcolumn).


[[2,3,4,5,1],
     [5,4,1,3,2],
     [4,1,5,2,3],
     [1,2,3,4,5],
     [3,5,2,1,4]]


[[1,2,3],
 [2,3,1],
 [3,1,2]]

 [3,2,1]

 plaintower(5, T,
         counts([2,3,2,1,4],
                [3,1,3,3,2],
                [4,1,2,5,2],
                [2,4,2,1,2])).

 [[1,2,3,4
   2,1,4,3
   4,3,2,1
   3,4,1,2]

   [[3,3,2,1], [2,1,3,3], [4,2,1,2], [1,2,4,2]]