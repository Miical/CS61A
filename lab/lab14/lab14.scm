(define (split-at lst n)
	(define (helper now remain n)	
		(if (or (= n 0) (null? remain))
			(append (list now) remain)
			(helper (append now (list (car remain))) (cdr remain) (- n 1))
		)
	)
	(helper nil lst n)
)


(define-macro (switch expr cases)
	(cons 'cond
		(map (lambda (case) (cons `(eq? ,expr (quote ,(car case))) (cdr case)))
    			cases))
)

