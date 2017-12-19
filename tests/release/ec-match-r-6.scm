(define (match-test x)
  (match x
    [`(1 ,`,x) x]
    [`,`,`,`,x (list 'q x)]
    [else (list 'else x)]))

(map match-test (list 1 '(1 a)))
