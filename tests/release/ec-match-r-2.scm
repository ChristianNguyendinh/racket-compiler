(define (match-test e)
  (match e
    ['(a b) 'ab]
    [0 'zero]
    [10 'ten]
    ["str" 'str]
    [#t 'true]
    [#f 'false]
    [(? number? n) (cons 'num n)]
    [(cons a b) (list b a)]
    ['() 'nil]
    [else (cons 'else e)]))

(map match-test
     (list '0 '1 '10
           #t #f 4
           'elze
           '(a b)
           (list 'a 'b 'c)
           "str" "foo" '()))
