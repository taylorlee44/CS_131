type my_nonterminals = 
	| Expr | Oper | Letter

let my_gram = 
	( Expr, 
		function 
		| Expr -> [[N Letter; N Oper; N Letter]]
		| Oper -> [[T "+"]]
		| Letter -> [[T "P"]]
	)


let t0 =  ((make_matcher my_gram accept_all ["blahhh"]) = None)

let t1 = (( make_parser my_gram ["Q"; "402"; "500"]) = None)