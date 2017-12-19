(list
 (guard
  (x [else 'match-err1])
  (define one (+ 0 1))
  (match one))
 (guard
  (x [else 'match-err2])
  (match 'e
    [(? number? x) 'num]))
 (let ([ptr (lambda () 'x)])
   (eq?
    (guard
     (x [else x])
     (match 'e
       [(? number? x) 'num]
       [else (raise ptr)]))
    ptr)))
