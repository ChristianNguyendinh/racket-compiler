(let* ([x 1]
       [num? (lambda (y)
               (set! x (+ x 147))
               (number? y))])
  (match (cons 10 20)
    [#t (set! x (+ x 11))]
    [(cons (? num? n) 'a)
     (set! x (+ x n))]
    [else (set! x (+ x 23))])
  x)
