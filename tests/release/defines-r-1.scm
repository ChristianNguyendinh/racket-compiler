(define (f x y . z)
  (list x y z))

(define (ls . lst) lst)

(apply
 (lambda (a . b) b)
 (ls
   'haaa 'heee 'heeh
   (f 1 2)
   (f 1 2 'a 'b 'c 'd)))
