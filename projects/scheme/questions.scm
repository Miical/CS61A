(define (caar x) (car (car x)))

(define (cadr x) (car (cdr x)))

(define (cdar x) (cdr (car x)))

(define (cddr x) (cdr (cdr x)))

; Some utility functions that you may find useful to implement.
(define (cons-all first rests)
  (if (null? rests)
      nil
      (cons (cons first (car rests))
            (cons-all first (cdr rests)))))

; (define (zip pairs)
;   (if (null? (car pairs))
;       nil
;       (cons (list (caar pairs) (car (cadr pairs)))
;             (zip (list (cdar pairs) (cdr (cadr pairs)))))))
(define (zip pairs)
  (define (helper a b)
    (if (null? a)
        nil
        (cons (cons (car a) (car b))
              (helper (cdr a) (cdr b)))))
  (if (null? pairs)
      (list nil nil)
      (helper (car pairs) (zip (cdr pairs)))))

; ; Problem 16
; ; Returns a list of two-element lists
(define (enumerate s)
  ; BEGIN PROBLEM 16
  (define (helper pairs)
    (if (null? (car pairs))
        nil
        (cons (list (caar pairs) (car (cadr pairs)))
              (helper (list (cdar pairs) (cdr (cadr pairs)))))))
  (define (range s n)
    (if (< s n)
        (cons s (range (+ s 1) n))
        nil))
  (helper (list (range 0 (length s)) s)))

; END PROBLEM 16
; ; Problem 17
; ; List all ways to make change for TOTAL with DENOMS
(define (list-change total denoms)
  (if (= total 0)
      (list nil)
      (if (null? denoms)
          nil
          (append (if (<= (car denoms) total)
                      (cons-all (car denoms)
                                (list-change (- total (car denoms)) denoms))
                      nil)
                  (list-change total (cdr denoms))))))

; END PROBLEM 17
; ; Problem 18
; ; Returns a function that checks if an expression is the special form FORM
(define (check-special form)
  (lambda (expr) (equal? form (car expr))))

(define lambda? (check-special 'lambda))

(define define? (check-special 'define))

(define quoted? (check-special 'quote))

(define let? (check-special 'let))

; ; Converts all let special forms in EXPR into equivalent forms using lambda
(define (let-to-lambda expr)
  (cond 
    ((atom? expr)
     ; BEGIN PROBLEM 18
     expr
     ; END PROBLEM 18
    )
    ((quoted? expr)
     ; BEGIN PROBLEM 18
     expr
     ; END PROBLEM 18
    )
    ((or (lambda? expr) (define? expr))
     (let ((form (car expr))
           (params (cadr expr))
           (body (cddr expr)))
       ; BEGIN PROBLEM 18
       (append (list form)
               (list params)
               (let-to-lambda body))
       ; END PROBLEM 18
     ))
    ((let? expr)
     (let ((values (cadr expr))
           (body (cddr expr)))
       ; BEGIN PROBLEM 18
       (append (list (append
                      (list 'lambda (let-to-lambda (car (zip values))))
                      (let-to-lambda body)))
               (let-to-lambda (cadr (zip values))))
       ; END PROBLEM 18
     ))
    (else
     ; BEGIN PROBLEM 18
     (define (helper expr)
       (if (null? expr)
           nil
           (cons (let-to-lambda (car expr))
                 (helper (cdr expr)))))
     (helper expr)
     ; END PROBLEM 18
    )))

