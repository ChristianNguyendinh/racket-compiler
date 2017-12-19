
(define a '4)
(define b '8)

(define (f y x)
  `(,x . ,y))

`(,(+ 1 2) ,(f a b) ,7)

