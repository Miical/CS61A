## Nonlocal

### Q1: Make Bank

In lecture, we saw how to use functions to create mutable objects. Here, for example, is the function `make_withdraw` which produces a function that can withdraw money from an account:

```
def make_withdraw(balance):
    """Return a withdraw function with BALANCE as its starting balance.
    >>> withdraw = make_withdraw(1000)
    >>> withdraw(100)
    900
    >>> withdraw(100)
    800
    >>> withdraw(900)
    'Insufficient funds'
    """
    def withdraw(amount):
        nonlocal balance
        if amount > balance:
            return 'Insufficient funds'
        balance = balance - amount
        return balance
    return withdraw
```

Write a new function `make_bank`, which should create a bank account with value `balance` and should also return another function. This new function should be able to withdraw and deposit money. The second function will take in two arguments: `message` and `amount`. When the message passed in is `'deposit'`, the bank will deposit `amount` into the account. When the message passed in is `'withdraw'`, the bank will attempt to withdraw `amount` from the account. If the account does not have enough money for a withdrawal, the string `'Insufficient funds'` will be returned. If the `message` passed in is neither of the two commands, the function should return `'Invalid message'` Examples are shown in the doctests.

```python
def make_withdraw(balance, password):
    """Return a password-protected withdraw function.

    >>> w = make_withdraw(100, 'hax0r')
    >>> w(25, 'hax0r')
    75
    >>> error = w(90, 'hax0r')
    >>> error
    'Insufficient funds'
    >>> error = w(25, 'hwat')
    >>> error
    'Incorrect password'
    >>> new_bal = w(25, 'hax0r')
    >>> new_bal
    50
    >>> w(75, 'a')
    'Incorrect password'
    >>> w(10, 'hax0r')
    40
    >>> w(20, 'n00b')
    'Incorrect password'
    >>> w(10, 'hax0r')
    "Too many incorrect attempts. Attempts: ['hwat', 'a', 'n00b']"
    >>> w(10, 'l33t')
    "Too many incorrect attempts. Attempts: ['hwat', 'a', 'n00b']"
    >>> type(w(10, 'l33t')) == str
    True
    """
    "*** YOUR CODE HERE ***"
    typed = []
    def bank(amount, pw):
        nonlocal balance, password
        if len(typed) == 3:
            return 'Too many incorrect attempts. Attempts: ' + str(typed)
        elif pw != password:
            typed.append(pw)
            return 'Incorrect password'
        elif balance >= amount:
            balance -= amount
            return balance
        else:
            return 'Insufficient funds'
    return bank
```

## Iterators and Generators

### Q3: Repeated

Implement a function (not a generator function) that returns the first value in the iterator `t` that appears `k` times in a row. As described in lecture, iterators can provide values using either the `next(t)` function or with a for-loop. Do not worry about cases where the function reaches the end of the iterator without finding a suitable value, all lists passed in for the tests will have a value that should be returned. If you are receiving an error where the iterator has completed then the program is not identifying the correct value. Iterate through the items such that if the same iterator is passed into `repeated` twice, it continues in the second call at the point it left off in the first. An example of this behavior is shown in the doctests.

```python
def repeated(t, k):
    """Return the first value in iterator T that appears K times in a row. Iterate through the items such that
    if the same iterator is passed into repeated twice, it continues in the second call at the point it left off
    in the first.

    >>> lst = iter([10, 9, 10, 9, 9, 10, 8, 8, 8, 7])
    >>> repeated(lst, 2)
    9
    >>> lst2 = iter([10, 9, 10, 9, 9, 10, 8, 8, 8, 7])
    >>> repeated(lst2, 3)
    8
    >>> s = iter([3, 2, 2, 2, 1, 2, 1, 4, 4, 5, 5, 5])
    >>> repeated(s, 3)
    2
    >>> repeated(s, 3)
    5
    >>> s2 = iter([4, 1, 6, 6, 7, 7, 8, 8, 2, 2, 2, 5])
    >>> repeated(s2, 3)
    2
    """
    assert k > 1
    "*** YOUR CODE HERE ***"
    last, times = None, 0 
    for val in t:
        if val == last:
            times += 1
            if times >= k:
                return val
        else:
            last = val
            times = 1
```

### Q4: Merge

Implement `merge(incr_a, incr_b)`, which takes two iterables `incr_a` and `incr_b` whose elements are ordered. `merge` yields elements from `incr_a` and `incr_b` in sorted order, eliminating repetition. You may assume `incr_a` and `incr_b` themselves do not contain repeats, and that none of the elements of either are `None`. You may **not** assume that the iterables are finite; either may produce an infinite stream of results.

You will probably find it helpful to use the two-argument version of the built-in `next` function: `next(incr, v)` is the same as `next(incr)`, except that instead of raising `StopIteration` when `incr` runs out of elements, it returns `v`.

See the doctest for examples of behavior.

```python
def merge(incr_a, incr_b):
    """Yield the elements of strictly increasing iterables incr_a and incr_b, removing
    repeats. Assume that incr_a and incr_b have no repeats. incr_a or incr_b may be infinite
    sequences.

    >>> m = merge([0, 2, 4, 6, 8, 10, 12, 14], [0, 3, 6, 9, 12, 15])
    >>> type(m)
    <class 'generator'>
    >>> list(m)
    [0, 2, 3, 4, 6, 8, 9, 10, 12, 14, 15]
    >>> def big(n):
    ...    k = 0
    ...    while True: yield k; k += n
    >>> m = merge(big(2), big(3))
    >>> [next(m) for _ in range(11)]
    [0, 2, 3, 4, 6, 8, 9, 10, 12, 14, 15]
    """
    iter_a, iter_b = iter(incr_a), iter(incr_b)
    next_a, next_b = next(iter_a, None), next(iter_b, None)
    "*** YOUR CODE HERE ***"
    last = None
    while True:
        if next_a != None and next_b != None:
            if next_a > next_b:
                if last == None or next_b > last:
                    last = next_b
                    yield next_b
                next_b = next(iter_b, None)
            else:
                if last == None or next_a > last:
                    last = next_a
                    yield next_a
                next_a = next(iter_a, None)
        elif next_b != None:
            if last == None or next_b > last:
                last = next_b
                yield next_b
            next_b = next(iter_b, None)
        elif next_a != None:
            if last == None or next_a > last:
                last = next_a
                yield next_a
            next_a = next(iter_a, None)
        else:
            break
```

### Q5: Joint Account

Suppose that our banking system requires the ability to make joint accounts. Define a function `make_joint` that takes three arguments.

1. A password-protected `withdraw` function,
2. The password with which that `withdraw` function was defined, and
3. A new password that can also access the original account.

If the password is incorrect or cannot be verified because the underlying account is locked, the `make_joint` should propagate the error. Otherwise, it returns a `withdraw` function that provides additional access to the original account using *either* the new or old password. Both functions draw from the same balance. Incorrect passwords provided to either function will be stored and cause the functions to be locked after three wrong attempts.

*Hint*: The solution is short (less than 10 lines) and contains no string literals! The key is to call `withdraw` with the right password and amount, then interpret the result. You may assume that all failed attempts to withdraw will return some string (for incorrect passwords, locked accounts, or insufficient funds), while successful withdrawals will return a number.

Use `type(value) == str` to test if some `value` is a string:

```python
def make_joint(withdraw, old_pass, new_pass):
    """Return a password-protected withdraw function that has joint access to
    the balance of withdraw.

    >>> w = make_withdraw(100, 'hax0r')
    >>> w(25, 'hax0r')
    75
    >>> make_joint(w, 'my', 'secret')
    'Incorrect password'
    >>> j = make_joint(w, 'hax0r', 'secret')
    >>> w(25, 'secret')
    'Incorrect password'
    >>> j(25, 'secret')
    50
    >>> j(25, 'hax0r')
    25
    >>> j(100, 'secret')
    'Insufficient funds'

    >>> j2 = make_joint(j, 'secret', 'code')
    >>> j2(5, 'code')
    20
    >>> j2(5, 'secret')
    15
    >>> j2(5, 'hax0r')
    10

    >>> j2(25, 'password')
    'Incorrect password'
    >>> j2(5, 'secret')
    "Too many incorrect attempts. Attempts: ['my', 'secret', 'password']"
    >>> j(5, 'secret')
    "Too many incorrect attempts. Attempts: ['my', 'secret', 'password']"
    >>> w(5, 'hax0r')
    "Too many incorrect attempts. Attempts: ['my', 'secret', 'password']"
    >>> make_joint(w, 'hax0r', 'hello')
    "Too many incorrect attempts. Attempts: ['my', 'secret', 'password']"
    """
    "*** YOUR CODE HERE ***"
    message = withdraw(0, old_pass)
    if type(message) == str:
        return message
    def joint(amount, password):
        if password == new_pass or password == old_pass:
            return withdraw(amount, old_pass)
        else:
            return withdraw(amount, password)
    return joint
```

### Q6: Remainder Generator

Like functions, generators can also be *higher-order*. For this problem, we will be writing `remainders_generator`, which yields a series of generator objects.

`remainders_generator` takes in an integer `m`, and yields `m` different generators. The first generator is a generator of multiples of `m`, i.e. numbers where the remainder is 0. The second is a generator of natural numbers with remainder 1 when divided by `m`. The last generator yields natural numbers with remainder `m - 1` when divided by `m`.

> *Hint*: You can call the `naturals` function to create a generator of infinite natural numbers.

> *Hint*: Consider defining an inner generator function. Each yielded generator varies only in that the elements of each generator have a particular remainder when divided by `m`. What does that tell you about the argument(s) that the inner function should take in?

```python
def remainders_generator(m):
    """
    Yields m generators. The ith yielded generator yields natural numbers whose
    remainder is i when divided by m.

    >>> import types
    >>> [isinstance(gen, types.GeneratorType) for gen in remainders_generator(5)]
    [True, True, True, True, True]
    >>> remainders_four = remainders_generator(4)
    >>> for i in range(4):
    ...     print("First 3 natural numbers with remainder {0} when divided by 4:".format(i))
    ...     gen = next(remainders_four)
    ...     for _ in range(3):
    ...         print(next(gen))
    First 3 natural numbers with remainder 0 when divided by 4:
    4
    8
    12
    First 3 natural numbers with remainder 1 when divided by 4:
    1
    5
    9
    First 3 natural numbers with remainder 2 when divided by 4:
    2
    6
    10
    First 3 natural numbers with remainder 3 when divided by 4:
    3
    7
    11
    """
    "*** YOUR CODE HERE ***"
    def remainder_x(x):
        for num in naturals():
            if num % m == x:
                yield num
    for x in range(m):
        yield remainder_x(x)


def naturals():
    """A generator function that yields the infinite sequence of natural
    numbers, starting at 1.

    >>> m = naturals()
    >>> type(m)
    <class 'generator'>
    >>> [next(m) for _ in range(10)]
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    """
    i = 1
    while True:
        yield i
        i += 1
```

