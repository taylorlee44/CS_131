#lang racket
(define lambda (string->symbol "\u03BB"))

(define (isquote x)
  (equal? 'quote x ))

(define (isif x)
  (equal? 'if x)) 

(define (expr-compare x y)
  (cond
    [(equal? x y) x ] ;; if equal, return x
    
    [ (and (equal? '#t x) (equal? '#t y)) #t]
    [ (and (equal? '#f x) (equal? '#f y)) #f]
    [ (and (equal? '#t x) (equal? '#f y)) '%]
    [ (and (equal? '#f x) (equal? '#t y)) '(not %)] ;; special cases
    
    [ (or
       (not (and (pair? x) (pair? y) ) ) ;; if not a pair
       (not( equal? (length x) (length y) ) ) ;; if list length is not equal
       )
           (list 'if '% x y) ] ;; don't recurse
    
    [(and (pair? x) (pair? y) (testpairs x y))] ;;recurse. 
  )
)

(define (testpairs x y)
    (cond
      [ ( or (empty? x) (empty? y) ) '() ] ;if the head is empty
      ; if x or y is special cases
      [ (and (equal? '#t (car x)) (equal? '#t (car y))) (cons #t (testpairs (cdr x) (cdr y)) )]
      [ (and (equal? '#f (car x)) (equal? '#f (car y))) (cons #f (testpairs (cdr x) (cdr y)) )]
      [ (and (equal? '#t (car x)) (equal? '#f (car y))) (cons '% (testpairs (cdr x) (cdr y)) )]
      [ (and (equal? '#f (car x)) (equal? '#t (car y))) (cons '(not %) (testpairs (cdr x) (cdr y)) )] ;; special cases
      ;; catch all the test cases from piazza. 
      [ (and  
           (or (equal?(car x) 'lambda) (equal?( car x) lambda) (equal?( car y) 'lambda) (equal?( car y)'lambda) )
           (< (length x) 4) )
           ( checkcases x y)
       ]
      ;;catch the pair that has lambda as the second car.
      [  (and
         (or (pair? (car x)) (pair? (car y)))    
         (or (equal?( car (car x)) 'lambda) (equal?( car (car x)) lambda) (equal?( car (car y)) 'lambda) (equal?( car (car y))'lambda) )
         )
                (cons (banglambda (car x) (car y)) (testpairs (cdr x) (cdr y)) ) ]
      [ ( or (pair? (car x)) (pair? (car y)) )
            ( cons (testpairs (car x)(car y)) (expr-compare (cdr x) (cdr y)) )];if the head is pair
      [ ( or (isquote (car x) ) ) (list 'if '% x y ) ] ;if either head is a quote
      [ ( equal? (car x) (car y) )
            (cons (car x) (expr-compare (cdr x) (cdr y)) ) ]
      [ ( isif (car y) ) ;if only y head is if
            (list 'if '% x y) ]
      [ ( isif (car x) ) ;if only x head is if
            (list 'if '% x y) ]
      ;; catch the pair that has lambda as the second car
      ;; grab that whole lambda, and change the lambda tail so that it is banged.
      [ ( not (equal? (car x) (car y)) )
            (cons (list 'if '% (car x) (car y) ) (expr-compare (cdr x) (cdr y)) )  ]
      )
)

(define (checkcases x y)
  (cond
    ;if x is single, and y is not
    [ (and (not (list? (car (cdr x)))) (list? (car (cdr y))) ) 
      (list 'if '% x y)
     ]
    ; if y is single and x is not
    [ (and (not (list? (car (cdr y)))) (list? (car (cdr x))) ) 
      (list 'if '% x y)
    ]
    ; if their arg length are different
    [ (and (list? (car (cdr y))) (list? (car(cdr x))) (not (equal? (length(car(cdr y))) (length (car(cdr x))))))
      (list 'if '% x y)
    ]
    ;; x and y are not matching. 
    [
     (or
     (and (list? (car (cdr y))) (not(list?(car(cdr x)))));x is pair, y is list
     (and (list? (car (cdr x))) (not(list?(car(cdr y)))));x is list, y is pair
     )
     (list 'if '% x y)
    ]
    ;;single body in () vs single element
    [ (or
     (and (list? (car (cdr(cdr y)))) (not(list?(car (cdr(cdr x))))) )
     (and (list? (car (cdr(cdr x)))) (not(list?(car (cdr(cdr y))))) )
     )
     (cons (car x) (cons (car (cdr x) )(list 'if '% (car (cdr(cdr x))) (car (cdr(cdr y))))))
    ]
    [ else (banglambda x y)
     ]
    )
 
)


(define (banglambda x y);;assuming same length "(lambda (a) a) " "(lambda (b) b) "
  (cond
     [ ( or (empty? x) (empty? y) ) '() ]
     [ ( or (list? (car x)) (list? (car y)) );;address the list of parameters 
          (let ([random1 (lambdalist1 (car x) (car y) ) ])
                
            (cons random1 ( cons (lambdalist2 (car (cdr x)) (car (cdr y)) random1) '()) )

            )
     ]
     [ ( and (equal? (car x) 'lambda) (equal? (car y) lambda) ) ;if x head is 'lambda & y head is lambda
            (cons lambda (banglambda (cdr x) (cdr y) ) )]
     [ ( and (equal? (car x) lambda) (equal? (car y) 'lambda) ) ;if y head is 'lambda & x head is lambda
            (cons lambda (banglambda (cdr x) (cdr y) ) )]
     [ ( and (equal? (car x) lambda) (equal? (car y) lambda) ) ;if both heads are lambda
            (cons lambda (banglambda (cdr x) (cdr y) ) )]
     [ ( and (equal? (car x) 'lambda) (equal? (car y) 'lambda) ) ;if both heads are 'lambda
            (cons 'lambda (banglambda (cdr x) (cdr y) ) )]
     [else x]
  )
)

(define (lambdalist1 x y) ;(a b) (a c) -> (a b!c)
  (cond
     [ ( or (empty? x) (empty? y) ) '() ]
     [ else (cons (helper (car x) (car y)) (lambdalist1 (cdr x) (cdr y)) )]
  )
 )

(define (lambdalist2 x y z);z is the list of banged parameters from the first list (f a b) (f a c) (a b!c) -> (f a b!c)

  (cond
    ; if x and y are just elements
    [ (and (symbol? x) (symbol? y) (member (helper x y ) z) )
          (cons (helper x y) '() )]
    [ (and (symbol? x) (symbol? y) (equal? x y ) )
          (cons x '() )]
    [ (and (symbol? x) (symbol? y) )
          (list 'if '% x y) ]
    ; if x and y are lists
    [ ( or (empty? x) (empty? y) ) '() ]; if either list is empty
    [ (member (helper (car x) (car y) ) z)
          (cons (helper (car x) (car y)) (lambdalist2 (cdr x) (cdr y) z) )] ;
    [ (equal? (car x) (car y) )
            (cons (car x) (lambdalist2 (cdr x) (cdr y) z) ) ]
    [ else (cons (list 'if '% (car x) (car y) ) (lambdalist2 (cdr x) (cdr y) z) )]
    )
)

(define (helper x y)
  (cond
    [ (equal? x y) x]
    [ else (bind x y)] 
  )
)

(define (bind x y)
      (string->symbol(string-append (symbol->string x) "!" (symbol->string y)))
)
 
(define (test-expr-compare x y)
 
    (and (equal? (eval (list 'let '((% #t)) (expr-compare x y))) (eval x))
         (equal? (eval y) (eval (list 'let '((% #f)) (expr-compare x y))))
    )                     
)

(define test-expr-x '( - 4 ((lambda (a c) (list a c)) 2 4)))
(define test-expr-x '( - 4 ((lambda (a c) (list a c)) 2 4)))
