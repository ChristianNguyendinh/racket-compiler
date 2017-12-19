(define (f x [a 'da] [b 'db] [c 'dc])
  (list x a b c))

(list
 (f 1)
 (f 1 2)
 (f 1 2 3)
 (f 1 2 3 4))
