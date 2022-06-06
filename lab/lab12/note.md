```scheme
---------------------------------------------------------------------
wwsd-macros > Suite 1 > Case 2
(cases remaining: 2)


scm> (define-macro (g x) (+ x 2))
? g
-- OK! --

scm> (g 2)
? 4
-- OK! --

scm> (g (+ 2 3))
? 7
-- Not quite. Try again! --

? SchemeError
-- OK! --

scm> (define-macro (h x) (list '+ x 2))
? h
-- OK! --

scm> (h (+ 2 3))
? 7
-- OK! --

---------------------------------------------------------------------
```

However, **the rules for evaluating calls to macro procedures are:**

- Evaluate operator
- Apply operator to unevaluated operands
- Evaluate the expression returned by the macro in the frame it was called in.

```scheme
scm> '(1 ,x 3)
? SchemeError
-- Not quite. Try again! --

? (1 2 3)
-- Not quite. Try again! --

? (1 ,x 3)
-- OK! --


scm> `(1 (,x) 3)
? (1 (,x) 3)
-- Not quite. Try again! --

? (1 (2) 3)
-- OK! --
```

## Macros

### Q3: Scheme def

Implement `def`, which simulates a python `def` statement, allowing you to write code like `(def f(x y) (+ x y))`.

The above expression should create a function with parameters `x` and `y`, and body `(+ x y)`, then bind it to the name `f` in the current frame.

> Note: the previous is equivalent to `(def f (x y) (+ x y))`.
>
> **Hint:** We *strongly* suggest doing the WWPD questions on macros first as understanding the rules of macro evaluation is key in writing macros.

```scheme
(define-macro (def func args body)
  `(define ,func (lambda ,args ,body))    
)
```



## Streams

### Q4: Multiples of 3

Define implicitly an infinite stream `all-three-multiples` that contains all the multiples of 3, starting at 3. For example, the first 5 elements should be: (3 6 9 12 15)

You may use the `map-stream` function defined below. `map-stream` takes in a one-argument function `f` and a stream `s` and returns a new stream containing the elements of `s` with `f` applied.

```
(define (map-stream f s)
	(if (null? s)
		nil
		(cons-stream (f (car s)) (map-stream f (cdr-stream s)))))
```

**Do not define any other helper functions.**

```scheme
(define all-three-multiples
    (map-stream (lambda (x) (+ 3 x)) (cons-stream 0 all-three-multiples))
)
```

# Optional Questions

## Scheme Basics

### Q5: Compose All

Implement `compose-all`, which takes a list of one-argument functions and returns a one-argument function that applies each function in that list in turn to its argument. For example, if `func` is the result of calling `compose-all` on a list of functions `(f g h)`, then `(func x)` should be equivalent to the result of calling `(h (g (f x)))`.

```
scm> (define (square x) (* x x))
square
scm> (define (add-one x) (+ x 1))
add-one
scm> (define (double x) (* x 2))
double
scm> (define composed (compose-all (list double square add-one)))
composed
scm> (composed 1)
5
scm> (composed 2)
17
```

```scheme
(define (compose-all funcs)
  (if (null? funcs)
      (lambda (x) x)
      (lambda (x)
        ((compose-all (cdr funcs)) ((car funcs) x)))))
```

## Streams

### Q6: Partial sums

Define a function `partial-sums`, which takes in a stream with elements

```
a1, a2, a3, ...
```

and outputs the stream

```
a1, a1 + a2, a1 + a2 + a3, ...
```

If the input is a finite stream of length *n*, the output should be a finite stream of length *n*. If the input is an infinite stream, the output should also be an infinite stream.

## Streams

### Q6: Partial sums

Define a function `partial-sums`, which takes in a stream with elements

```
a1, a2, a3, ...
```

and outputs the stream

```
a1, a1 + a2, a1 + a2 + a3, ...
```

If the input is a finite stream of length *n*, the output should be a finite stream of length *n*. If the input is an infinite stream, the output should also be an infinite stream.

```scheme
(define (partial-sums stream)
  (define (helper sum stream)
    (if (null? stream)
        nil
        (cons-stream (+ sum (car stream))
                     (helper (+ sum (car stream)) (cdr-stream stream)))))
  (helper 0 stream))
```

