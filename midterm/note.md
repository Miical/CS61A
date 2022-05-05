## Practice

## q1

```python
def same_digits(a, b):
    """
    Implement same_digits, which takes two positive integers. It returns whether they both become
    the same number after replacing each sequence of a digit repeated consecutively with only one of that
    digit. For example, in 12222321, the sequence 2222 would be replaced by only 2, leaving 12321.
    Restriction: You may only write combinations of the following in the blanks:
    a, b, end, 10, %, if, while, and, or, ==, !=, True, False, and return. (No division allowed!)

    >>> same_digits(2002200, 2202000) # Ignoring repeats, both are 2020
    True
    >>> same_digits(21, 12) # Digits must appear in the same order
    False
    >>> same_digits(12, 2212) # 12 and 212 are not the same
    False
    >>> same_digits(2020, 20) # 2020 and 20 are not the same
    False
    """
    assert a > 0 and b > 0
    while a and b:
        if a % 10 == b % 10:
            end = a % 10
            while a % 10 == end:
                a = a // 10
            while b % 10 == end:
                b = b // 10
        else:
            return False 
    return a == 0 and b == 0
```

## q2

```python
def make_guess(n):
    """
    Let's play a guessing game! In order to do this, we'll use higher order functions.
    Write a function, make_guess, which takes in a number that we want someone to try to guess, and returns a guessing
    function.
    A guessing function is a one-argument function which takes in a number. If the number passed in is the number we
    wanted to guess, it will return the number of incorrect guesses made prior to the correct guess. Otherwise, it returns
    another guessing function, which keeps track of the fact that we've made an incorrect guess.
    Solutions which use lists, object mutation, nonlocal, or global will receive no credit.

    >>> guesser = make_guess(10)
    >>> guess1 = guesser(6)
    >>> guess2 = guess1(7)
    >>> guess3 = guess2(8)
    >>> guess3(10)
    3
    >>> guess2(10)
    2
    >>> a = make_guess(5)(1)(2)(3)(4)(5)
    >>> a
    4
    """
    def update_guess(num_incorrect):
        def new_guess(x):
            if x == n:
                return num_incorrect
            else:
                return update_guess(num_incorrect + 1) 
        return new_guess
    return update_guess(0)
```

## q3

```python
def close(n, smallest=10, d=10):
    """ A sequence is near increasing if each element but the last two is smaller than all elements
    following its subsequent element. That is, element i must be smaller than elements i + 2, i + 3, i + 4, etc.
    Implement close, which takes a non-negative integer n and returns the largest near increasing sequence
    of digits within n as an integer. The arguments smallest and d are part of the implementation; you must
    determine their purpose. The only values you may use are integers and booleans (True and False) (no lists, strings, etc.).
    Return the longest sequence of near-increasing digits in n.
    >>> close(123)
    123
    >>> close(153)
    153
    >>> close(1523)
    153
    >>> close(15123)
    1123
    >>> close(11111111)
    11
    >>> close(985357)
    557
    >>> close(14735476)
    143576
    >>> close(812348567)
    1234567
    """
    if n == 0:
      return n
    no = close(n//10, smallest, d)
    if smallest > n % 10:
        yes = close(n//10, min(smallest, d), n%10) * 10 + n%10
        return max(yes, no)
    return no
```

## q4

```python
def sums(n, k):
    """
    Implement sums, which takes two positive integers n and k. It returns a list of lists containing all
    the ways that a list of k positive integers can sum to n. Results can appear in any order.

    Return the ways in which K positive integers can sum to N.
    >>> sums(2, 2)
    [[1, 1]]
    >>> sums(2, 3)
    []
    >>> sums(4, 2)
    [[3, 1], [2, 2], [1, 3]]
    >>> sums(5, 3)
    [[3, 1, 1], [2, 2, 1], [1, 3, 1], [2, 1, 2], [1, 2, 2], [1, 1, 3]]
    """
    if k == 0:
        return [[]] if n==0 else []
    y = []
    for x in range(1, n-k+2):
        y.extend([s+[x] for s in sums(n-x, k-1)])
    return y
```

## q5

```python
# Implement sequence, which takes a positive integer n and a function term. It returns an integer whose digits
# show the n elements of the sequence term(1), term(2), . . . , term(n) in order. Assume the term function takes
# a positive integer argument and returns a positive integer.
# Important: You may not use pow, **, log, str, or len in your solution.
def sequence(n, term):
    """Return the first n terms of a sequence as an integer.
    >>> sequence(6, abs) # Terms are 1, 2, 3, 4, 5, 6
    123456
    >>> sequence(5, lambda k: k+8) # Terms are 9, 10, 11, 12, 13
    910111213
    >>> sequence(4, lambda k: pow(10, k)) # Terms are 10, 100, 1000, 10000
    10100100010000
    """
    t, k = 0, 1
    while k <= n:
        m = 1
        x = term(k)
        while m <= x:
            m *= 10
        t = t*m + x
        k = k + 1
    return t
```

## q6

```python
def make_zipper(f1, f2, sequence):
    """
    We would like to create a function make_zipper that takes two functions f1(x) and f2(x) and a "zipper
    sequence", which is a number that contains a series of 1s and 2s. It returns a function that is the equivalent of
    f1(f2(f2(...f1(x)...))) in which the exact sequence of f1s and f2s is given by the digits of the sequence.
    As an example, if the sequence were 1211, that would mean return a function of x that is the equivalent to
    f1(f2(f1(f1(x)))). Neither recursion nor containers (lists, dictionaries, sets, etc) are allowed in your solution.

    Return a function of f1 and f2 composed based on sequence.
    >>> increment = lambda x: x + 1
    >>> square = lambda x: x * x
    >>> do_nothing = make_zipper(increment, square, 0)
    >>> do_nothing(2) # Don't call either f1 or f2, just return your input untouched
    2
    >>> incincsq = make_zipper(increment, square, 112)
    >>> incincsq(2) # increment(increment(square(2))), so 2 -> 4 -> 5 -> 6
    6
    >>> sqincsqinc = make_zipper(increment, square, 2121)
    >>> sqincsqinc(2) # square(increment(square(increment(2)))), so 2 -> 3 -> 9 -> 10 -> 100
    100
    """
    zipper = lambda x: x
    helper = lambda f1, f2: lambda x: f1(f2(x))
    while sequence:
        if sequence % 2 == 1:
            zipper = helper(f1, zipper)
        else:
            zipper = helper(f2, zipper)
        sequence = sequence // 10
    return zipper
```

## q7

```python

def longest_seq( tr ):
    """ Given a tree, t, find the length of the longest downward sequence of node
    labels in the tree that are increasing consecutive integers. The length of the
    longest downward sequence of nodes in T whose labels are consecutive integers.
    >>> t = Tree (1 , [ Tree (2) , Tree (1 , [ Tree (2 , [ Tree (3 , [ Tree (0)])])])])
    >>> longest_seq( t) # 1 -> 2 -> 3
    3
    >>> t = Tree (1)
    >>> longest_seq( t)
    1
    """
    max_len = 1
    def longest( t ):
        """ Returns longest downward sequence of nodes starting at T whose
        labels are consecutive integers. Updates max_len to that length ,
        if greater. """
        nonlocal max_len
        n = 1
        if not t.is_leaf():
            for b in t.branches:
                n = max(n, longest(b))
                if b.label == t.label + 1:
                    n = max(n, 1 + longest(b))
            max_len = max(max_len, n)
        return n
    longest(tr)
    return max_len

### Tree Class definition ###
class Tree:
    def __init__(self, label, branches=[]):
        self.label = label
        for branch in branches:
            assert isinstance(branch, Tree)
        self.branches = list(branches)

    def is_leaf(self):
        return not self.branches
```



# mt

## q1

```python
def cat(password, limit):
    """ Write a higher-order function `cat` that returns a one-argument
    function `attempt`. Every time `attempt` is called, it checks to see if its argument
    matches the password at the corresponding index.

    If the password entirely matches, return a success string. If more than `limit`
    number of incorrect hacks are attempted, you should return an error string.
    For details, see the doctest.


    Note: to comment out a blank that covers an entire line, just put down 'unnecessary' (with quotes)

    >>> hacker = cat([1,2], 2)
    >>> hacker(1)
    >>> hacker(2)
    'Successfully unlocked!'
    >>> hacker = cat([1,2], 1)
    >>> hacker(1)
    >>> hacker(3) # used up attempts to gain access
    >>> hacker(2) # correct attempt to gain access, but already locked
    'The safe is now inaccessible!'
    >>> hacker = cat([1,2], 2)
    >>> hacker(1)
    >>> hacker(3) # 1 attempt left to gain access
    >>> hacker(2) # correct attempt to gain access
    'Successfully unlocked!'
    """
    'unnecessary'
    index = 0
    def attempt(digit):
        'unnecessary'
        nonlocal index, limit
        if limit <= 0:
            return 'The safe is now inaccessible!'
        if digit == password[index]:
            index += 1
            if index == len(password):
                return 'Successfully unlocked!'
        else:
            limit -= 1
    return attempt
```

## q2

```python
def schedule(galaxy, sum_to, max_digit):
    """
    A 'galaxy' is a string which contains either digits or '?'s.

    A 'completion' of a galaxy is a string that is the same as galaxy, except
    with digits replacing each of the '?'s.

    Your task in this question is to find all completions of the given `galaxy`
    that use digits up to `max_digit`, and whose digits sum to `sum_to`.

    Note 1: the function int can be used to convert a string to an integer and str
        can be used to convert an integer to a string as such:

        >>> int("5")
        5
        >>> str(5)
        '5'

    Note 2: Indexing and slicing can be used on strings as well as on lists.

        >>> 'evocative'[3]
        'c'
        >>> 'evocative'[3:]
        'cative'
        >>> 'evocative'[:6]
        'evocat'
        >>> 'evocative'[3:6]
        'cat'


    >>> schedule('?????', 25, 5)
    ['55555']
    >>> schedule('???', 5, 2)
    ['122', '212', '221']
    >>> schedule('?2??11?', 5, 3)
    ['0200111', '0201110', '0210110', '1200110']
    """
    def schedule_helper(galaxy, sum_sofar, index):
        if sum_sofar == sum_to and index == len(galaxy):
            return [galaxy]
        elif index == len(galaxy):
            return []
        elif galaxy[index] != '?':
            return schedule_helper(galaxy, sum_sofar + int(galaxy[index]), index + 1)
        ans = []
        for x in range(min(max_digit, sum_to - sum_sofar) + 1):
            modified_galaxy = galaxy[:index] + str(x) + galaxy[index+1:]
            ans.extend(schedule_helper(modified_galaxy, sum_sofar + x, index + 1))
        return ans

    return schedule_helper(galaxy, 0, 0)
```

## q3

```python
"""
Let a `painting` be a self-referential function that
    - takes in one integer
    - returns two values, another painting and well as an integer

For an example see the function `identity_painting` below.

You have two tasks in this assignment, to implement the functions `microscope`
and `plush`. Both have their behavior defined by their doctests.

It is not necessary to implement `microscope` correctly to get the points for
`plush`. However, the ok test cases for `plush` will fail if you have not correctly
implemented `microscope`.
"""

def identity_painting(x):
    return identity_painting, x

def microscope(a=0, s=1):
    """
    This function returns a painting function that processes a sequence
    of integers, and returns the alternating sum of all integers seen thus
    far (see doctest for an example).

    >>> painting_a = microscope()
    >>> painting_b, x = painting_a(2)
    >>> x                                   # 2
    2
    >>> painting_c, x = painting_b(8)
    >>> x                                   # 2 - 8
    -6
    >>> painting_d, x = painting_c(12)
    >>> x                                   # 2 - 8 + 12
    6
    >>> painting_e, x = painting_d(30)
    >>> x                                   # 2 - 8 + 12 - 30
    -24
    >>> painting_b_again, x = painting_a(100)
    >>> x                                   # 100 [note that we are using painting_a not painting_d here]
    100
    """
    def painting(x):
        return microscope(a+x*(-1)**(s+1), not s), a + x* (-1)**(s+1)
    return painting

def plush(painting, items):
    """
    The function `plush` takes in a `painting` and a nonempty list of `items` and
    runs the given `painting` on each of the `items` in turn, returning the final
    numeric result.

    For example, on the items [1, 2, 3, 4, 5] with the painting microscope
    we return 1 - 2 + 3 - 4 + 5 = 3

    >>> plush(microscope(), [1, 2, 3, 4, 5])
    3
    >>> plush(microscope(), [4000])
    4000
    >>> plush(microscope(), [2, 90])
    -88
    >>> plush(identity_painting, [2, 90])
    90
    """
    painting, x = painting(items[0])
    if len(items) > 1:
        return plush(painting, items[1:])
    return x
```

## q4

太妙了！！！

```python
def lemon(xv):
    """
    A lemon-copy is a perfect replica of a nested list's box-and-pointer structure.
        If an environment diagram were drawn out, the two should be entirely
        separate but identical.

    A `xv` is a list that only contains ints and other lists.

    The function `lemon` generates a lemon-copy of the given list `xv`.

    Note: The `isinstance` function takes in a value and a type and determines
        whether the value is of the given type. So

        >>> isinstance("abc", str)
        True
        >>> isinstance("abc", list)
        False

    Here's an example, where lemon_y = lemon(y)


                             +-----+-----+            +-----+-----+-----+
                             |     |     |            |     |     |     |
                             |  +  |  +-------------> | 200 | 300 |  +  |
        y +----------------> |  |  |     |            |     |     |  |  |
                             +-----+-----+       +--> +-----+-----+-----+
        lemon_y +-+             |                |       ^           |
                  |             +----------------+       |           |
                  |                                      +-----------+
                  |
                  |          +-----+-----+            +-----+-----+-----+
                  |          |     |     |            |     |     |     |
                  +------->  |  +  |  +-------------> | 200 | 300 |  +  |
                             |  |  |     |            |     |     |  |  |
                             +-----+-----+       +--> +-----+-----+-----+
                                |                |       ^           |
                                +----------------+       |           |
                                                         +-----------+

    >>> x = [200, 300]
    >>> x.append(x)
    >>> y = [x, x]              # this is the `y` from the doctests
    >>> lemon_y = lemon(y)      # this is the `lemon_y` from the doctests
    >>> # check that lemon_y has the same structure as y
    >>> len(lemon_y)
    2
    >>> lemon_y[0] is lemon_y[1]
    True
    >>> len(lemon_y[0])
    3
    >>> lemon_y[0][0]
    200
    >>> lemon_y[0][1]
    300
    >>> lemon_y[0][2] is lemon_y[0]
    True
    >>> # check that lemon_y and y have no list objects in common
    >>> lemon_y is y
    False
    >>> lemon_y[0] is y[0]
    False
    """
    lemon_lookup = []
    def helper(xv):
        if isinstance(xv, int):  
            return xv
        for old_new in lemon_lookup:
            if xv is old_new[0]:
                return old_new[1]
        new_xv = []
        lemon_lookup.append((xv, new_xv))
        for element in xv:
            new_xv.append(helper(element))
        return new_xv
    return helper(xv)
```



## q5

```python
def subsaltshaker(disk):
    """
    A 'saltshaker' is a sequence of digits of length `d` composed entirely of the digit `d`. Examples include
        1
        4444
        7777777

    Note that `1 <= d <= 9`; there are no 0-length saltshakers.

    Your task is to implement the `subsaltshaker` function, which takes in an integer `disk` and returns
        whether `disk` contains a saltshaker as a consecutive subinteger of its digits.

    >>> subsaltshaker(2233) # 22 counts
    True
    >>> subsaltshaker(2444423) # 4444 counts
    True
    >>> subsaltshaker(82223) # 22 counts even if it appears as part of 222
    True
    >>> subsaltshaker(234562) # 2...2 does not count if the 2s are not consecutive
    False
    >>> subsaltshaker(1) # 1 counts
    True
    >>> subsaltshaker(498729879871) # 1 counts
    True
    >>> subsaltshaker(149872987987) # 1 counts
    True
    >>> subsaltshaker(4445555) # no saltshakers in this number
    False
    >>> subsaltshaker(20) # no saltshakers in this number
    False
    """
    current_digit = -1
    count = 0
    while disk:
        last = disk % 10
        if last == current_digit:
            count += 1
        else:
            count = 1
            current_digit = last
        if count == current_digit:
            return True
        disk = disk // 10
    return False
```



## q6

```python
def copycat(lst1, lst2):
    """
    Write a function `copycat` that takes in two lists.
        `lst1` is a list of strings
        `lst2` is a list of integers

    It returns a new list where every element from `lst1` is copied the
    number of times as the corresponding element in `lst2`. If the number
    of times to be copied is negative (-k), then it removes the previous
    k elements added.

    Note 1: `lst1` and `lst2` do not have to be the same length, simply ignore
    any extra elements in the longer list.

    Note 2: you can assume that you will never be asked to delete more
    elements than exist


    >>> copycat(['a', 'b', 'c'], [1, 2, 3])
    ['a', 'b', 'b', 'c', 'c', 'c']
    >>> copycat(['a', 'b', 'c'], [3])
    ['a', 'a', 'a']
    >>> copycat(['a', 'b', 'c'], [0, 2, 0])
    ['b', 'b']
    >>> copycat([], [1,2,3])
    []
    >>> copycat(['a', 'b', 'c'], [1, -1, 3])
    ['c', 'c', 'c']
    """
    def copycat_helper(current_list, ls1, ls2):
        if not ls1 or not ls2:
            return current_list
        if ls2[0] >= 0:
            current_list = current_list + [ls1[0]] * ls2[0]
        else:
            current_list = current_list[:len(current_list) + ls2[0]]
        return copycat_helper(current_list, ls1[1:], ls2[1:])
    return copycat_helper([], lst1, lst2)
```



## q7

设计的也太妙了呜呜呜

```python
def village(apple, t):
    """
    The `village` operation takes
        a function `apple` that maps an integer to a tree where
            every label is an integer.
        a tree `t` whose labels are all integers

    And applies `apple` to every label in `t`.

    To recombine this tree of trees into a a single tree,
        simply copy all its branches to each of the leaves
        of the new tree.

    For example, if we have
        apple(x) = tree(x, [tree(x + 1), tree(x + 2)])
    and
        t =         10
                  /    \
                20      30

    We should get the output

        village(apple, t)
          =                    10
                           /       \
                        /             \
                      11               12
                    /    \           /    \
                  20      30       20      30
                 / \     /  \     /  \    /  \
                21 22  31   32   21  22  31  32
    >>> t = tree(10, [tree(20), tree(30)])
    >>> apple = lambda x: tree(x, [tree(x + 1), tree(x + 2)])
    >>> print_tree(village(apple, t))
    10
      11
        20
          21
          22
        30
          31
          32
      12
        20
          21
          22
        30
          31
          32
    """
    def graft(t, bs):
        """
        Grafts the given branches `bs` onto each leaf
        of the given tree `t`, returning a new tree.
        """
        if is_leaf(t):
            return tree(label(t), bs)
        new_branches = [graft(b, bs) for b in branches(t)]
        return tree(label(t), new_branches)
    base_t = apple(label(t))
    bs = [village(apple, b) for b in branches(t)]
    return graft(base_t, bs)

def tree(label, branches=[]):
    """Construct a tree with the given label value and a list of branches."""
    for branch in branches:
        assert is_tree(branch), 'branches must be trees'
    return [label] + list(branches)

def label(tree):
    """Return the label value of a tree."""
    return tree[0]

def branches(tree):
    """Return the list of branches of the given tree."""
    return tree[1:]

def is_tree(tree):
    """Returns True if the given tree is a tree, and False otherwise."""
    if type(tree) != list or len(tree) < 1:
        return False
    for branch in branches(tree):
        if not is_tree(branch):
            return False
    return True

def is_leaf(tree):
    """Returns True if the given tree's list of branches is empty, and False
    otherwise.
    """
    return not branches(tree)

def print_tree(t, indent=0):
    """Print a representation of this tree in which each node is
    indented by two spaces times its depth from the entry.
    """
    print('  ' * indent + str(label(t)))
    for b in branches(t):
        print_tree(b, indent + 1)
```

