type ('nonterminal, 'terminal) symbol =
       | N of 'nonterminal
       | T of 'terminal

open List
open Printf

let subset a b = 
	for_all (fun x -> mem x b) a;;

let equal_sets a b = 
	subset a b && subset b a
	;;

let set_union a b =
	sort_uniq compare (append a b) ;;

let set_intersection a b = 
	filter (fun x -> mem x b) a;;

let set_diff a b = 
	filter (fun x -> not(mem x b))a;;

let clearNonTerminals aList = filter ( fun x->  (* clear a list of all T's*)
	match x with 
	| N  (nonterminal) -> true
	| T  (terminal) -> false 
	| _ -> false
								) aList ;;

let clearHeads aList = map ( fun x -> (*clear heads of rhs*)
	match x with 
	| N (nonterminal) -> nonterminal
	| T (terminal) ->  failwith "No asdlkf") aList ;;

let retrieveSnd givTuple =  function
	| (a,b) -> b

let rec computed_fixed_point eq f x = 
	if eq x (f x ) 
	then 
	x
	else 
		computed_fixed_point eq f (f x)	
    ;;

 let rec findRules (growingList, rules) =  

 	let firstEl = find_opt    (fun x -> 
 		(* checks if the lhs of the rule is in growingList*)
		let lhsBool = (subset ((fst x)::[]) growingList) in 
		(* clears all the terminals in the rhs of the rule *)
		let rhs = (snd x) in
		let nonterminals = clearNonTerminals rhs in 
		(* clears all the heads in the rhs of the rule *)
   		let clearHeads1 = clearHeads nonterminals in 
   		let rhsBool =  not (subset clearHeads1 growingList) in 
   		rhsBool && lhsBool	  ) rules in 

 	match firstEl with 
 	| None -> 
 		(growingList, rules)
 	| Some (a,b) -> 
 		let rhs2 = b in
		let non2 = (clearNonTerminals rhs2) in 
		let cH2 = clearHeads non2 in 
		let updatedList = set_union growingList cH2 in  
		findRules (updatedList, rules)
;;

let filter_reachable g = 
	match g with 
	| (firstN, rules ) -> 
		let blank = firstN :: [] in 
		let listAndRules = findRules (blank, rules ) in 
 		let secondReturn = filter (fun x -> 
 			(mem ( fst x ) (fst listAndRules))
 							) rules in 
 	
 	(hd blank, secondReturn) 

	| _ -> g

;; 

