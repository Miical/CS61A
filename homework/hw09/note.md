## Trees

### Q1: In-order traversal

Write a function that returns a generator that generates an "in-order" traversal, in which we yield the value of every node in order from left to right, assuming that each node has either 0 or 2 branches.

```python
def in_order_traversal(t):
    """
    Generator function that generates an "in-order" traversal, in which we
    yield the value of every node in order from left to right, assuming that each node has either 0 or 2 branches.

    For example, take the following tree t:
            1
        2       3
    4     5
         6  7

    We have the in-order-traversal 4, 2, 6, 5, 7, 1, 3

    >>> t = Tree(1, [Tree(2, [Tree(4), Tree(5, [Tree(6), Tree(7)])]), Tree(3)])
    >>> list(in_order_traversal(t))
    [4, 2, 6, 5, 7, 1, 3]
    """
    if len(t.branches) == 2:
      yield from in_order_traversal(t.branches[0])
    yield t.label
    if len(t.branches) == 2:
      yield from in_order_traversal(t.branches[1])
```

## Scheme

### Q2: Reverse

Write the procedure `reverse`, which takes in a list `lst` and outputs a reversed list. Hint: you may find the built-in function `append` useful ([documentation](https://inst.eecs.berkeley.edu/~cs61a/su20/articles/scheme-builtins.html#append)).

```scheme
(define (reverse lst)
    (if (null? lst)
        nil
        (append (reverse (cdr lst)) (list (car lst)))
    )
)
```

## Recursion

### Q3: Interleaved Sum

Recall that the `summation` function computes the sum of a sequence of terms from 1 to `n`:

```
def summation(n, term):
    """Return the sum of the first n terms of a sequence.

    >>> summation(5, lambda x: pow(x, 3))
    225
    """
    total, k = 0, 1
    while k <= n:
        total, k = total + term(k), k + 1
    return total
```

Write a function `interleaved_sum` that similarly computes the sum of a sequence of terms from 1 to `n`, but uses different functions to compute the terms for odd and even numbers. Do so without using any loops or testing in any way if a number is odd or even.

> *Note*: no-loops rule is just to make sure you get practice writing recursive solutions, but in future you may have to combine both recursion and loops to solve problems.
>
> *Hint*: You can test if a number is equal to 0, 1, or `n`. If you start summing from the term 1, you'll be able to tell whether the current term is odd or even. How can you keep track of an extra variable for the current term in a recursive function?

```python
def interleaved_sum(n, odd_term, even_term):
    """Compute the sum odd_term(1) + even_term(2) + odd_term(3) + ..., up
    to n.

    >>> # 1 + 2^2 + 3 + 4^2 + 5
    ... interleaved_sum(5, lambda x: x, lambda x: x*x)
    29
    >>> from construct_check import check
    >>> check(SOURCE_FILE, 'interleaved_sum', ['While', 'For', 'Mod']) # ban loops and %
    True
    """
    def helper(x, tag):
        if x > n:
            return 0
        elif tag:
            return odd_term(x) + helper(x + 1, 1 - tag)
        else:
            return even_term(x) + helper(x + 1, 1 - tag)
    return helper(1, 1)
```

## Linked Lists

### Q4: Mutate Reverse

Implement `mutate_reverse`, which takes a linked list instance and mutates it so that its values appear in reverse order. For an extra challenge, find an implementation that requires only linear time in the length of the list (big-Theta n).

```python
def mutate_reverse(link):
    """Mutates the Link so that its elements are reversed.

    >>> link = Link(1)
    >>> mutate_reverse(link)
    >>> link
    Link(1)

    >>> link = Link(1, Link(2, Link(3)))
    >>> mutate_reverse(link)
    >>> link
    Link(3, Link(2, Link(1)))
    """
    elements = []
    def helper(L):
        nonlocal elements
        if L == Link.empty:
            return 0
        else:
            elements.append(L.first)
            idx = helper(L.rest) 
            L.first = elements[idx]
            return idx + 1 
    helper(link)
```

