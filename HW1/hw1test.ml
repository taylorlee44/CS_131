let my_subset_test0 = subset [1; 1; 3; 5] [1; 2; 3; 4; 5; 6; 7] 
let my_subset_test1 = subset [] [99;99]
let my_subset_test2 = not (subset [5; 1] [] )

let my_equal_sets_test0 =  equal_sets [0;1;2;3] [0;1;2;3]
let my_equal_sets_test1 =  equal_sets [0] [0]
let my_equal_sets_test2 =  not (equal_sets [0;1;2;] [0;1;2;3] ) 

let my_set_union_test0 = set_union [1; 2; 3] [4;5;6] 
let my_set_union_test1 = set_union [1; ] [6] 

let my_set_intersection_test0 =  set_intersection [1; 3; 5; 7] [1; 2; 4; 6]  
let my_set_intersection_test1 =  set_intersection [] []  

let my_set_diff_test0 =  set_diff [1; 2; 3; 4; 5] [1; 2; 3; 4] 
let my_set_diff_test1 =  set_diff [5] [1; 2; 3; 4] 

let my_computed_fixed_point_test0 =  computed_fixed_point (=) (fun y -> y * 3 -2) 1 = 1 
let my_computed_fixed_point_test0 =  computed_fixed_point (=) (fun y -> y ) 5 = 5

type my_nonterminals =
  | Conversation | Sentence | Yell | Cry

let my_grammar =
  Conversation,
  [
   Yell, [T"RAAAA!"];
   Cry, [T"WAAA!"];
   Sentence, [N Cry];
   Sentence, [N Yell];
   Conversation, [N Sentence; T","; N Conversation]]

let my_filter_reachable_test0 =
  filter_reachable my_grammar = my_grammar
