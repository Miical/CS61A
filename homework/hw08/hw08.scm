(define (rle s)
    (define (helper number cnt ss)
        (if (null? ss)
            (if (= 0 cnt)
                nil   
                (cons-stream (list number cnt) nil)   
            )
            (if (= (car ss) number)
                (helper number (+ 1 cnt) (cdr-stream ss))
                (if (= cnt 0)
                    (helper (car ss) (+ 1 cnt) (cdr-stream ss))
                    (cons-stream
                        (list number cnt)
                        (helper -1 0 ss)
                    )
                )
            )
        )
    )
    (helper -1 0 s)
)


(define (group-by-nondecreasing s)
    (define (helper now last_num ss)
        (if (null? ss)
            (if (null? now)
                nil
                (cons-stream now nil)
            )    
            (if (>= (car ss) last_num)
                (helper (append now (list (car ss))) (car ss) (cdr-stream ss))
                (cons-stream
                    now
                    (helper nil -1 ss)
                )
            )
        )
    )
    (helper nil -1 s)
)


(define finite-test-stream
    (cons-stream 1
        (cons-stream 2
            (cons-stream 3
                (cons-stream 1
                    (cons-stream 2
                        (cons-stream 2
                            (cons-stream 1 nil))))))))

(define infinite-test-stream
    (cons-stream 1
        (cons-stream 2
            (cons-stream 2
                infinite-test-stream))))