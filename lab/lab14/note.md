## Trees

### Q1: Prune Min

Write a function that prunes a `Tree` `t` mutatively. `t` and its branches always have zero or two branches. For the trees with two branches, reduce the number of branches from two to one by keeping the branch that has the smaller label value. Do nothing with trees with zero branches.

Prune the tree in a direction of your choosing (top down or bottom up). The result should be a linear tree.

```python
def prune_min(t):
    """Prune the tree mutatively from the bottom up.

    >>> t1 = Tree(6)
    >>> prune_min(t1)
    >>> t1
    Tree(6)
    >>> t2 = Tree(6, [Tree(3), Tree(4)])
    >>> prune_min(t2)
    >>> t2
    Tree(6, [Tree(3)])
    >>> t3 = Tree(6, [Tree(3, [Tree(1), Tree(2)]), Tree(5, [Tree(3), Tree(4)])])
    >>> prune_min(t3)
    >>> t3
    Tree(6, [Tree(3, [Tree(1)])])
    """
    if not t.is_leaf():
        if (t.branches[0].label < t.branches[1].label):
            prune_min(t.branches[0]) 
            t.branches = [t.branches[0]]
        else:
            prune_min(t.branches[1]) 
            t.branches = [t.branches[1]]
```

## Scheme

### Q2: Split

Implement `split-at`, which takes a list `lst` and a positive number `n` as input and returns a pair `new` such that `(car new)` is the first `n` elements of `lst` and `(cdr new)` is the remaining elements of `lst`. If `n` is greater than the length of `lst`, `(car new)` should be `lst` and `(cdr new)` should be `nil`.

```scheme
(define (split-at lst n)
	(define (helper now remain n)	
		(if (or (= n 0) (null? remain))
			(append (list now) remain)
			(helper (append now (list (car remain))) (cdr remain) (- n 1))
		)
	)
	(helper nil lst n)
)
```

## Recursion

### Q3: Align Skeleton

Have you wondered how your CS61A exams are graded online? To see how your submission differs from the solution skeleton code, `okpy` uses an algorithm very similar to the one below which shows us the minimum number of edit operations needed to transform the the skeleton code into your submission.

Similar to `meowstake_matches` in Cats, we consider two different edit operations:

1. Insert a letter to the skeleton code
2. Delete a letter from the skeleton code

Given two strings, `skeleton` and `code`, implement `align_skeleton`, a function that minimizes the edit distance between the two strings and returns a string of all the edits. Each addition is represented with `+[]`, and each deletion is represented with `-[]`. For example:

```
>>> align_skeleton(skeleton = "x=5", code = "x=6")
'x=+[6]-[5]'
>>> align_skeleton(skeleton = "while x<y", code = "for x<y")
'+[f]+[o]+[r]-[w]-[h]-[i]-[l]-[e]x<y'
```

In the first example, the `+[6]` represents adding a "6" to the skeleton code, while the `-[5]` represents removing a "5" to the skeleton code. In the second example, we add in the letters "f", "o", and "r" and remove the letters "w", "h", "i", "l", and "e" from the skeleton code to transform it to the submitted code.

> Note: For simplicity, all whitespaces are stripped from both the skeleton and submitted code, so you don't have to consider whitespaces in your logic.

`align_skeleton` uses a recursive helper function, `helper_align`, which takes in `skeleton_idx` and `code_idx`, the indices of the letters from `skeleton` and `code` which we are comparing. It returns two things: match, the sequence of edit corrections, and cost, the numer of edit operations made. First, you should define your three base cases:

- If both `skeleton_idx` and `code_idx` are at the end of their respective strings, then there are no more operations to be made.
- If we have not finished considering all letters in `skeleton` but we have considered all letters in `code`, then we simply need to delete all the remaining letters in `skeleton` to match it to `code`.
- If we have not finished considering all letters in `code` but we have considered all letters in `skeleton` , then we simply need to add all the remaining letters in `code` to `skeleton`.

Next, you should implement the rest of the edit operations for `align_skeleton` and `helper_align`. You may not need all the lines provided.

```python
def align_skeleton(skeleton, code):
    """
    Aligns the given skeleton with the given code, minimizing the edit distance between
    the two. Both skeleton and code are assumed to be valid one-line strings of code. 

    >>> align_skeleton(skeleton="", code="")
    ''
    >>> align_skeleton(skeleton="", code="i")
    '+[i]'
    >>> align_skeleton(skeleton="i", code="")
    '-[i]'
    >>> align_skeleton(skeleton="i", code="i")
    'i'
    >>> align_skeleton(skeleton="i", code="j")
    '+[j]-[i]'
    >>> align_skeleton(skeleton="x=5", code="x=6")
    'x=+[6]-[5]'
    >>> align_skeleton(skeleton="return x", code="return x+1")
    'returnx+[+]+[1]'
    >>> align_skeleton(skeleton="while x<y", code="for x<y")
    '+[f]+[o]+[r]-[w]-[h]-[i]-[l]-[e]x<y'
    >>> align_skeleton(skeleton="def f(x):", code="def g(x):")
    'def+[g]-[f](x):'
    """
    skeleton, code = skeleton.replace(" ", ""), code.replace(" ", "")

    def helper_align(skeleton_idx, code_idx):
        """
        Aligns the given skeletal segment with the code.
        Returns (match, cost)
            match: the sequence of corrections as a string
            cost: the cost of the corrections, in edits
        """
        if skeleton_idx == len(skeleton) and code_idx == len(code):
            return "", 0 
        if skeleton_idx < len(skeleton) and code_idx == len(code):
            edits = "".join(["-[" + c + "]" for c in skeleton[skeleton_idx:]])
            return edits, len(skeleton) - skeleton_idx 
        if skeleton_idx == len(skeleton) and code_idx < len(code):
            edits = "".join(["+[" + c + "]" for c in code[code_idx:]])
            return edits, len(code) - code_idx 
        
        possibilities = []
        skel_char, code_char = skeleton[skeleton_idx], code[code_idx]
        # Match
        if skel_char == code_char:
            edits, cost = helper_align(skeleton_idx + 1, code_idx + 1)
            possibilities.append((skel_char + edits, cost))
        # Insert
        edits, cost = helper_align(skeleton_idx, code_idx + 1)
        edits = "+[" + code_char + "]" + edits
        possibilities.append((edits, cost + 1))
        # Delete
        edits, cost = helper_align(skeleton_idx + 1, code_idx)
        edits = "-[" + skel_char + "]" + edits
        possibilities.append((edits, cost + 1))
        return min(possibilities, key=lambda x: x[1])
    result, cost = helper_align(0, 0)
    return result
```

## Tree Recursion

### Q4: Num Splits

Given a list of numbers `s` and a target difference `d`, how many different ways are there to split `s` into two subsets such that the sum of the first is within `d` of the sum of the second? The number of elements in each subset can differ.

You may assume that the elements in `s` are distinct and that `d` is always non-negative.

Note that the order of the elements within each subset does not matter, nor does the order of the subsets themselves. For example, given the list `[1, 2, 3]`, you should not count `[1, 2], [3]` and `[3], [1, 2]` as distinct splits.

> Hint: If the number you return is too large, you may be double-counting somewhere. If the result you return is off by some constant factor, it will likely be easiest to simply divide/subtract away that factor.

```python
def num_splits(s, d):
    """Return the number of ways in which s can be partitioned into two
    sublists that have sums within d of each other.

    >>> num_splits([1, 5, 4], 0)  # splits to [1, 4] and [5]
    1
    >>> num_splits([6, 1, 3], 1)  # no split possible
    0
    >>> num_splits([-2, 1, 3], 2) # [-2, 3], [1] and [-2, 1, 3], []
    2
    >>> num_splits([1, 4, 6, 8, 2, 9, 5], 3)
    12
    """
    def helper(a, b, ss):
        if not ss:
            return abs(sum(a) - sum(b)) <= d
        else:
            return helper(a + [ss[0]], b, ss[1:]) + helper(a, b + [ss[0]], ss[1:])
    return helper([], [], s) // 2
```

## Linked Lists

### Q5: Insert

Implement a function `insert` that takes a `Link`, a `value`, and an `index`, and inserts the `value` into the `Link` at the given `index`. You can assume the linked list already has at least one element. Do not return anything -- `insert` should mutate the linked list.

> **Note**: If the index is out of bounds, you can raise an `IndexError` with:
>
> ```
> raise IndexError
> ```

```python
def insert(link, value, index):
    """Insert a value into a Link at the given index.

    >>> link = Link(1, Link(2, Link(3)))
    >>> print(link)
    <1 2 3>
    >>> insert(link, 9001, 0)
    >>> print(link)
    <9001 1 2 3>
    >>> insert(link, 100, 2)
    >>> print(link)
    <9001 1 100 2 3>
    >>> insert(link, 4, 5)
    IndexError
    """
    if link == Link.empty:
        raise IndexError
    elif index == 0:
        link.rest = Link(link.first,  link.rest)
        link.first = value
    else:
        insert(link.rest, value, index - 1) 
```

## Macros

### Q6: Switch

Define the macro `switch`, which takes in an expression `expr` and a list of pairs, `cases`, where the first element of the pair is some *value* and the second element is a single expression. `switch` will evaluate the expression contained in the list of `cases` that corresponds to the value that `expr` evaluates to.

```
scm> (switch (+ 1 1) ((1 (print 'a))
                      (2 (print 'b))
                      (3 (print 'c))))
b
```

You may assume that the value `expr` evaluates to is always the first element of one of the pairs in `cases`. You can also assume that the first value of each pair in `cases` is a value.

```scheme
(define-macro (switch expr cases)
	(cons 'cond
		(map (lambda (case) (cons `(eq? ,expr (quote ,(car case))) (cdr case)))
    			cases))
)
```

