(let ([f (lambda (x [g (lambda (u) (list u x))] [c (g x)])
           (list x (g 'uu) c))])
  (list
   (f 1)
   (f 1 (lambda (x) (list x x)))
   (f 1 (lambda (x) (list x x)) 2)))
