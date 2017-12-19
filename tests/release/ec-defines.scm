(begin
  (define x 'x)
  (define y 'y))

(set! x (begin
          (set! y 'yy)
          (cons x y)))

(begin
  (begin
    (begin
      (define z (cons x y)))))

(begin
  (list x y z))
