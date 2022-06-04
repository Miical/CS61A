(define (cddr s) (cdr (cdr s)))

(define (cadr s) (car (cdr s)))

(define (caddr s) (car (cddr s)))

(define (sign num)
  (cond 
    ((< num 0) -1)
    ((= num 0) 0)
    ((> num 0) 1)
  )
)

(define (square x) (* x x))

(define (pow x y)
  (if (= y 0)
      1
      (if (even? y)
          (square (pow x (quotient y 2)))
          (* (square (pow x (quotient y 2))) x)
      )
  )
)

(define (unique s)
  (if (null? s)
      nil
      (cons (car s)
            (unique (filter (lambda (x) (not (eq? x (car s))))
                            (cdr s)
                    )
            )
      )
  )
)

(define (replicate x n)
  (define (helper s x n)
    (if (zero? n)
        s
        (helper (cons x s) x (- n 1))
    )
  )
  (helper nil x n)
)

(define (accumulate combiner start n term)
  (define (helper combiner start now n term)
    (if (> now n)
        start
        (helper combiner
                (combiner start (term now))
                (+ now 1)
                n
                term
        )
    )
  )
  (helper combiner start 1 n term)
)

(define (accumulate-tail combiner start n term)
  (define (helper combiner start now n term)
    (if (> now n)
        start
        (helper combiner
                (combiner start (term now))
                (+ now 1)
                n
                term
        )
    )
  )
  (helper combiner start 1 n term)
)

(define-macro
 (list-of map-expr for var in lst if filter-expr)
 `(map (lambda (,var) ,map-expr)
       (filter (lambda (,var) ,filter-expr) ,lst)
  )
)
