## Scheme

### Q1: Thane of Cadr

Define the procedures `cadr` and `caddr`, which return the second and third elements of a list, respectively:

```scheme
(define (cddr s)
  (cdr (cdr s)))

(define (cadr s)
  (car (cdr s))
)

(define (caddr s)
  (car (cddr s))
)
```

### Q2: Sign

Using a `cond` expression, define a procedure `sign` that takes in one parameter `num` and returns -1 if `num` is negative, 0 if `num` is zero, and 1 if `num` is positive.

```scheme
(define (sign num)
  (cond 
    ((< num 0) -1)
    ((= num 0) 0)
    ((> num 0) 1)
  )
)
```

### Q3: Pow

Implement a procedure `pow` for raising the number `x` to the power of a nonnegative integer `y` for which the number of operations grows logarithmically (as opposed to linearly).

> *Hint:* Consider the following observations:
>
> 1. b2k = (bk)2
> 2. b2k+1 = b(bk)2
>
> You may use the built-in predicates `even?` and `odd?`. Scheme doesn't support iteration in the same manner as Python, so consider another way to solve this problem.

```scheme
(define (pow x y)
  (if (= y 0)
      1
      (if (even? y)
          (square (pow x (quotient y 2)))
          (* (square (pow x (quotient y 2))) x)
      )
  )
)
```

### Q4: Unique

Implement `unique`, which takes in a list `s` and returns a new list containing the same elements as `s` with duplicates removed.

```
scm> (unique '(1 2 1 3 2 3 1))
(1 2 3)
scm> (unique '(a b c a a b b c))
(a b c)
```

> Hint: you may find it useful to use the built-in `filter` procedure. See the [built-in procedure reference](https://inst.eecs.berkeley.edu/~cs61a/su20/articles/scheme-builtins.html) for more information.

```scheme
(define (unique s)
  (if (null? s)
      nil
      (cons (car s)
            (unique
             (filter (lambda (x) (not (eq? x (car s)))) (cdr s))
            )
      )
  )
)
```

## Tail Recursion

### Q5: Replicate

Below is an implementation of the `replicate` function, which was seen in discussion. `replicate` takes in an element `x` and an integer `n`, and returns a list with `x` repeated `n` times.

```
(define (replicate x n)
	(if (= n 0)
		nil
		(cons x (replicate x (- n 1)))))
```

Update this implementation of `replicate` to be tail recursive. It should have identical functionality to the non-tail recursive version.

> If you're running into an recursion depth exceeded error and you're using the staff interpreter, it's very likely your solution is not properly tail recursive.
>
> We test that your solution is tail recursive by calling `replicate` with a very large input. If your solution is not tail recursive and does not use a constant number of frames, it will not be able to successfully run.
>
> You may wish to use the built-in [append](https://inst.eecs.berkeley.edu/~cs61a/su20/scheme-builtins.html#append) procedure in your solution.

```scheme
(define (replicate x n)
  (define (helper s x n)
    (if (zero? n)
        s
        (helper (cons x s) x (- n 1))
    )
  )
  (helper nil x n)
)
```

### Q6: Accumulate

Fill in the definition for the procedure `accumulate`, which combines the first `n` natural numbers according to the following parameters:

1. `combiner`: a function of two arguments
2. `start`: a number with which to start combining
3. `n`: the number of natural numbers to combine
4. `term`: a function of one argument that computes the *n*th term of a sequence

For example, we can find the product of all the numbers from 1 to 5 by using the multiplication operator as the `combiner`, and starting our product at 1:

```
scm> (define (identity x) x)
scm> (accumulate * 1 5 identity)  ; 1 * 1 * 2 * 3 * 4 * 5
120
```

We can also find the sum of the squares of the same numbers by using the addition operator as the `combiner` and `square` as the `term`:

```
scm> (define (square x) (* x x))
scm> (accumulate + 0 5 square)  ; 0 + 1^2 + 2^2 + 3^2 + 4^2 + 5^2
55
scm> (accumulate + 5 5 square)  ; 5 + 1^2 + 2^2 + 3^2 + 4^2 + 5^2
60
```

You may assume that the `combiner` will always be commutative: i.e. the order of arguments do not matter.

```scheme
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
```

### Q7: Tail Recursive Accumulate

Update your implementation of `accumulate` to be tail recursive. It should still pass all the tests for "regular" `accumulate`!

You may assume that the input `combiner` and `term` procedures are properly tail recursive.

If your implementation for accumulate in the previous question is already tail recursive, you may simply copy over that solution (replacing `accumulate` with `accumulate-tail` as appropriate).

> If you're running into an recursion depth exceeded error and you're using the staff interpreter, it's very likely your solution is not properly tail recursive.
>
> We test that your solution is tail recursive by calling `accumulate-tail` with a very large input. If your solution is not tail recursive and does not use a constant number of frames, it will not be able to successfully run.

```scheme
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
```

### Q8: List Comprehensions

Recall that list comprehensions in Python allow us to create lists out of iterables:

```
[<map-expression> for <name> in <iterable> if <conditional-expression>]
```

Use a macro to implement list comprehensions in Scheme that can create lists out of lists. Specifically, we want a `list-of` macro that can be called as follows:

```
(list-of <map-expression> for <name> in <list> if <conditional-expression>)
```

Calling `list-of` will return a new list constructed by doing the following for each element in `<list>`:

- Bind `<name>` to the element.
- If `<conditional-expression>` evaluates to a truth-y value, evaluate `<map-expression>` and add it to the result list.

Here are some examples:

```
scm> (list-of (* x x) for x in '(3 4 5) if (odd? x))
(9 25)
scm> (list-of 'hi for x in '(1 2 3 4 5 6) if (= (modulo x 3) 0))
(hi hi)
scm> (list-of (car e) for e in '((10) 11 (12) 13 (14 15)) if (list? e))
(10 12 14)
```

> *Hint:* You may use the built-in `map` and `filter` procedures. Check out the [Scheme Built-ins](https://inst.eecs.berkeley.edu/~cs61a/su20/articles/scheme-builtins.html) reference for more information.
>
> You may find it helpful to refer to the `for` loop macro introduced in lecture. The filter expression should be transformed using a `lambda` in a similar way to the map expression in the example.

```scheme
(define-macro
 (list-of map-expr for var in lst if filter-expr)
 `(map (lambda (,var) ,map-expr)
       (filter (lambda (,var) ,filter-expr) ,lst)
  )
)
```
