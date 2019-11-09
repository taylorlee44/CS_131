let rec at k list = match list with 
	| [] -> None
	| (h::t) -> if (k = 1) then ( h) else at (k-1) t

;; 