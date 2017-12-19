(begin
  (define x
    (case 0 [(0) 'ww 'w]))
  (define y
    (cond [else 'yy (set! x (cons x 'x)) 'y])))

(begin
  1
  (begin
    0
    (begin
      (define z (cons x y))
      2)
    3))

(list x y z)
