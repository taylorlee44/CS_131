type ('nonterminal, 'terminal) symbol =
       | N of 'nonterminal
       | T of 'terminal

open List 
open Printf

type awksub_nonterminals =
  | Expr | Term | Lvalue | Incrop | Binop | Num

type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal

let awkish_grammar =
  (Expr,
   function
     | Expr ->
         [[N Term; N Binop; N Expr];
          [N Term]]
     | Term ->
     [[N Num];
      [N Lvalue];
      [N Incrop; N Lvalue];
      [N Lvalue; N Incrop];
      [T"("; N Expr; T")"]]
     | Lvalue ->
     [[T"$"; N Expr]]
     | Incrop ->
     [[T"++"];
      [T"--"]]
     | Binop ->
     [[T"+"];
      [T"-"]]
     | Num ->
     [[T"0"]; [T"1"]; [T"2"]; [T"3"]; [T"4"];
      [T"5"]; [T"6"]; [T"7"]; [T"8"]; [T"9"]])


let small_awk_frag = ["$"; "1"; "++"; "-"; "2"]
   
let convert_grammar gram1  = match gram1 with 
	| (first, rules) -> 
        let allNonT = fst (split rules) in 
        let uniqueNonT = sort_uniq compare allNonT in 
        let helper (expr) = 
        let matchRules = filter ( fun x -> (fst x) == expr ) rules in  
        let rhs = snd (split matchRules) in 
        rhs                    in
        (first, helper)
	;;

let rec ptlHelp (returnList, tree) = match tree with 
    | Leaf x -> ((x:: []), tree) (* if it is a leaf, return  the value *)
    | Node (x, head::tail) -> 
        let listA = fst (ptlHelp (returnList, head) ) in (* listA = the left terminal Nodes *)
        let listB = fst (ptlHelp (returnList, (hd tail) )) in (* listB = the right terminal Nodes *)
        let listC = append listA listB in (* add them together *)
        (listC, tree) 
;;

let parse_tree_leaves tree = 
    let returnList  = fst (ptlHelp ([], tree) ) in 
        returnList
;;

let make_matcher gram acceptor fragment= 
    None
;;

let accept_all string = Some string;;

let make_parser gram fragment = 
 None 
;;






