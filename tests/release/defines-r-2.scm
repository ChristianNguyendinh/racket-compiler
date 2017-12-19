(define a
  (guard [zz (else zz)]
         (define two 2) 
         (raise two)
         (raise (+ 1 two))))

(define (f x)
  (define a 1)
  (let ()
    (define b (begin
                (let* ([eee 8])
                  (+ eee eee)
                  (+ eee a))))
    b))

(f a)
a
