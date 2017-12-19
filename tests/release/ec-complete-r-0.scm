(define x (match '1 [else 'a]))
(define (f1 a b)
  (match '1 [else (list a b)]))
(define (f2 a . b)
  (match '1 [else (list a b)]))
(define (f3 . a)
  (match '1 [else (list a)]))

(list
 ;; defines
 (list x (f1 1 2) (f2 1 2 3)(f3 1 2 3 4))
 ;; lets & if & application
 (list
  (letrec* ([a (match '1 [else 'a])]
            [b (match '1 [else 'b])])
    (match '1 [else (cons a b)]))
  (letrec ([a (match '1 [else 'a])]
           [b (match '1 [else 'b])])
    (match '1 [else (cons a b)]))
  (let* ([a (match '1 [else 'a])]
         [b (match '1 [else 'b])])
    (match '1 [else (cons a b)]))
  (let ([a (match '1 [else 'a])]
         [b (match '1 [else 'b])])
    (match '1 [else (cons a b)]))
  (let loop ([a (match '1 [else 'a])]
             [b (match '1 [else 'b])])
    (match '1
      [else (if (eq? a 'b)
                'done
                ((match '1
                   [else loop])
                 (match '1
                   [else 'b])
                 b))])))
 ;; lambda
 (list
  ((lambda (a b)
     (match '1 [else (list a b)]))
   'a 'b)
  ((lambda (a . b)
     (match '1 [else (list a b)]))
   'a 'b 'c)
  ((lambda a
     (match '1 [else (list a)]))
   'a 'b 'c 'd))
 ;; dynamic-wind
 (let ([x '()])
   (let ([f (dynamic-wind
             (lambda ()
               (set! x (cons (match '1 [else 'pre]) x)))
             (lambda ()
               (set! x (cons (match '1 [else 'val]) x))
               (lambda ()
                 x))
             (lambda ()
               (set! x (cons (match '1 [else 'post]) x))))])
     (list 'dyn-wind (f))))
 ;; delay & force
 (force
  (match '1
    [else (delay (match '1 [else 'force-delay]))]))
 ;; call/cc
 (call/cc
  (match '1
    [else (lambda (f)
            'a)]))

 ;; TODO: and & or
 ;; TODO: guard & raise
 ;; TODO: cond
 ;; TODO: case
 ;; TODO: when & unless
 ;; TODO: apply
 )
