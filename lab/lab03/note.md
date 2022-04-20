### Q3: Pascal's Triangle

Here's a part of the Pascal's trangle:

```
1
1 1
1 2 1
1 3 3 1
1 4 6 4 1
```

Every number in Pascal's triangle is defined as the sum of the item above it and the item that is directly to the upper left of it. Use `0` if the entry is empty. Define the procedure `pascal(row, column)` which takes a row and a column, and finds the value at that position in the triangle. Rows and columns are zero-indexed; that is, the first row is row 0 instead of 1.

```python
def pascal(row, column):
    """Returns a number corresponding to the value at that location
    in Pascal's Triangle.
    >>> pascal(0, 0)
    1
    >>> pascal(0, 5)	# Empty entry; outside of Pascal's Triangle
    0
    >>> pascal(3, 2)	# Row 4 (1 3 3 1), 3rd entry
    3
    """
    "*** YOUR CODE HERE ***"
    if (column > row):
        return 0
    elif row == column or column == 0:
        return 1
    else:
        return pascal(row - 1, column) + pascal(row - 1, column - 1)
```

### Q4: Repeated, repeated

In Homework 2 you encountered the `repeated` function, which takes arguments `f` and `n` and returns a function equivalent to the nth repeated application of `f`. This time, we want to write `repeated` recursively. You'll want to use `compose1`, given below for your convenience:

```python
def compose1(f, g):
    """"Return a function h, such that h(x) = f(g(x))."""
    def h(x):
        return f(g(x))
    return h
```

```python
def repeated(f, n):
    """Return the function that computes the nth application of func (recursively!).

    >>> add_three = repeated(lambda x: x + 1, 3)
    >>> add_three(5)
    8
    >>> square = lambda x: x ** 2
    >>> repeated(square, 2)(5) # square(square(5))
    625
    >>> repeated(square, 4)(5) # square(square(square(square(5))))
    152587890625
    >>> repeated(square, 0)(5)
    5
    >>> from construct_check import check
    >>> # ban iteration
    >>> check(HW_SOURCE_FILE, 'repeated',
    ...       ['For', 'While'])
    True
    """
    "*** YOUR CODE HERE ***"
    if n == 0:
        return lambda x: x
    elif n == 1: 
        return f
    else:
        return compose1(f, repeated(f, n - 1))
```

### Q5: Num eights

Write a recursive function `num_eights` that takes a positive integer `x` and returns the number of times the digit 8 appears in `x`. *Use recursion - the tests will fail if you use any assignment statements.*

```python
def num_eights(x):
    """Returns the number of times 8 appears as a digit of x.

    >>> num_eights(3)
    0
    >>> num_eights(8)
    1
    >>> num_eights(88888888)
    8
    >>> num_eights(2638)
    1
    >>> num_eights(86380)
    2
    >>> num_eights(12345)
    0
    >>> from construct_check import check
    >>> # ban all assignment statements
    >>> check(HW_SOURCE_FILE, 'num_eights',
    ...       ['Assign', 'AugAssign'])
    True
    """
    "*** YOUR CODE HERE ***"
    if x:
        return (x % 10 == 8) + num_eights(x // 10)
    else: 
        return 0 
```

### Q6: Ping-pong

The ping-pong sequence counts up starting from 1 and is always either counting up or counting down. At element `k`, the direction switches if `k` is a multiple of 8 or contains the digit 8. The first 30 elements of the ping-pong sequence are listed below, with direction swaps marked using brackets at the 8th, 16th, 18th, 24th, and 28th elements:

| Index          | 1    | 2    | 3    | 4    | 5    | 6    | 7    | [8]  | 9    | 10   | 11   | 12   | 13   | 14   | 15   | [16] | 17   | [18] | 19   | 20   | 21   | 22   | 23   |
| :------------- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| PingPong Value | 1    | 2    | 3    | 4    | 5    | 6    | 7    | [8]  | 7    | 6    | 5    | 4    | 3    | 2    | 1    | [0]  | 1    | [2]  | 1    | 0    | -1   | -2   | -3   |

| Index (cont.)  | [24] | 25   | 26   | 27   | [28] | 29   | 30   |
| :------------- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| PingPong Value | [-4] | -3   | -2   | -1   | [0]  | -1   | -2   |

Implement a function `pingpong` that returns the nth element of the ping-pong sequence *without using any assignment statements*.

You may use the function `num_eights`, which you defined in the previous question.

*Use recursion - the tests will fail if you use any assignment statements.*

```python
def helper(i, n, d):
    if i <= n:
        return d + helper(i+1, n, -d if i%8==0 or num_eights(i) else d)
    else:
        return 0

def pingpong(n):
    """Return the nth element of the ping-pong sequence.

    >>> pingpong(8)
    8
    >>> pingpong(10)
    6
    >>> pingpong(15)
    1
    >>> pingpong(21)
    -1
    >>> pingpong(22)
    -2
    >>> pingpong(30)
    -2
    >>> pingpong(68)
    0
    >>> pingpong(69)
    -1
    >>> pingpong(80)
    0
    >>> pingpong(81)
    1
    >>> pingpong(82)
    0
    >>> pingpong(100)
    -6
    >>> from construct_check import check
    >>> # ban assignment statements
    >>> check(HW_SOURCE_FILE, 'pingpong', ['Assign', 'AugAssign'])
    True
    """
    "*** YOUR CODE HERE ***"
    return helper(1, n, 1)
```

