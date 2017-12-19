
(define str "bad")

(string-append (string (string-ref str 2)) (substring str 0 0) (string (car (string->list str)) (string-ref str 0)))
