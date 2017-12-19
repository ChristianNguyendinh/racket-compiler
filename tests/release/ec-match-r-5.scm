(define (match-test d)
  (match d
    [(? (lambda (x)
          (match 1
            [else (number? x)])) n)
     (list 'nat n)]
    [`(test ,(? (lambda (x)
                  (match x
                    ['a #t]
                    [else #f])) a))
     (list 'test a)]
    [`(test ,(? (lambda (x)
                  (match '1
                    [else (number? x)])) n))
     (list 'l-nat n)]
    [else (list 'else d)]))

(map match-test
     (list
      1
      'else
      '(test a)
      '(test 9)
      '(test b)))
