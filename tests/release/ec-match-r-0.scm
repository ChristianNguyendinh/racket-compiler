



(match (cons 50 '("1" 2 3 (4 5) 6))
       [(cons 50 (? list? (cons (? number? n) m))) 'a]
       [#f 'b]
       [(cons 50 (cons one (cons 2 (cons 3 (cons (? list? (cons four rest)) tail)))))
        (+ four (foldl + 0 tail))])

