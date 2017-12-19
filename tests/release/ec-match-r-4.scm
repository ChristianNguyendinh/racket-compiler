(define (match-test d)
  (match d
    [`() 'nil]
    [`(a b) 'abc]
    [`(,a ,(? number? b) ,c)
     (list 'triple-n a b c)]
    [`(,a ,b ,c) (list 'triple a b c)]
    [`(,x . ,xs) (list 'cons x xs)]
    [else (list 'else d)]))

(map match-test
     (list
      '()
      '(a b)
      '(a b c)
      '(a b c d e)
      'foo
      '(a 2 c)
      ))
