## Part 0: Testing Your Interpreter

The `tests.scm` file contains a long list of sample Scheme expressions and their expected values. Many of these examples are from Chapters 1 and 2 of [Structure and Interpretation of Computer Programs](https://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book-Z-H-4.html#%_toc_start), the textbook from which Composing Programs is adapted.

## Part I: The Reader

> **Important submission note:** For full credit:
>
> - submit with Parts I and II done by **Monday, 8/3** (worth 1 pt), and
> - submit with Parts III and IV complete by **Thursday, 8/6** (worth 1 pt), and
> - submit the entire project by **Monday, 8/10**. You will get an extra credit point for submitting the entire project by Sunday, 8/9.

> All changes in this part should be made in `scheme_reader.py`.

In Parts I and II, you will develop the interpreter in several stages:

- Reading Scheme expressions
- Symbol evaluation
- Calling built-in procedures
- Definitions
- Lambda expressions and procedure definition
- Calling user-defined procedures
- Evaluation of special forms

The first part of this project deals with reading and parsing user input. Our reader will parse Scheme code into Python values with the following representations:

| Input Example  | Scheme Expression Type | Our Internal Representation                                  |
| :------------- | :--------------------- | :----------------------------------------------------------- |
| `scm> 1`       | Numbers                | Python's built-in `int` and `float` values                   |
| `scm> x`       | Symbols                | Python's built-in `string` values                            |
| `scm> #t`      | Booleans (`#t`, `#f`)  | Python's built-in `True`, `False` values                     |
| `scm> (+ 2 3)` | Combinations           | Instances of the `Pair` class, defined in `scheme_reader.py` |
| `scm> nil`     | `nil`                  | The `nil` object, defined in `scheme_reader.py`              |

When we refer to combinations in this project, we are referring to both call expressions and special forms.

If you haven't already, make sure to read the [Implementation overview](https://inst.eecs.berkeley.edu/~cs61a/su20/proj/scheme/#implementation-overview) section above to understand how the reader is broken up into parts.

In our implementation, we store tokens ready to be parsed in `Buffer` instances. For example, a buffer containing the input `(+ (2 3))` would have the tokens `'('`, `'+'`, `'('`, `2`, `3`, `')'`, and `')'`. See the doctests in `buffer.py` for more examples. You do not have to understand the code in this file.

You will write the parsing functionality, which consists of two mutually recursive functions `scheme_read` and `read_tail`. These functions each take in a single parameter, `src`, which is an instance of `Buffer`.

There are two methods defined in `buffer.py` that you'll use to interact with `src`:

- `src.pop_first()`: mutates `src` by removing the **first** token in `src` and returns it. For the sake of simplicity, if we imagine `src` as a Python list such as `[4, 3, ')']`, `src.pop_first()` will return `4`, and `src` will be left with `[3, ')']`.
- `src.current()`: returns the **first** token in `src` without removing it. For example, if `src` currently contains the tokens `[4, 3, ')']`, then `src.current()` will return `4` but `src` will remain the same.

Note that you cannot index into the Buffer object (i.e. `buffer[1]` is not valid).

### Problem 1 (2 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 01 -u
```

First, implement `scheme_read` and `read_tail` so that they can parse combinations and atomic expressions. The expected behavior is as follows:

- `scheme_read` removes enough tokens from `src` to form a single expression and returns that expression in the correct internal representation (see above table).
- `read_tail` expects to read the rest of a list or pair, assuming the open parenthesis of that list or pair has already been removed by `scheme_read`. It will read expressions (and thus remove tokens) until the matching closing parenthesis `)` is seen. This list of expressions is returned as a linked list of `Pair` instances.

In short, `scheme_read` returns the next single complete expression in the buffer and `read_tail` returns the rest of a list or pair in the buffer. Both functions mutate the buffer, removing the tokens that have already been processed.

The behavior of both functions depends on the first token currently in `src`. They should be implemented as follows:

`scheme_read`:

- If the current token is the string `"nil"`, return the `nil` object.
- If the current token is `(`, the expression is a pair or list. Call `read_tail` on the rest of `src` and return its result.
- If the current token is `'`, ```, or `,` the rest of the buffer should be processed as a `quote`, `quasiquote`, or `unquote` expression, respectively. You don't have to worry about this until Problem 6.
- If the next token is not a delimiter, then it must be a primitive expression (i.e. a number, boolean). Return it. **(provided)**
- If none of the above cases apply, raise an error. **(provided)**

`read_tail`:

- If there are no more tokens, then the list is missing a close parenthesis and we should raise an error. **(provided)**
- If the token is `)`, then we've reached the end of the list or pair. **Remove this token from the buffer** and return the `nil` object.
- If none of the above cases apply, the next token is the operator in a combination, e.g. src contains `+ 2 3)`. To parse this:
  1. Read the next complete expression in the buffer. (*Hint:* Which function can we use to read a complete expression and remove it from the buffer?)
  2. Read the rest of the combination until the matching closing parenthesis. (*Hint:* Which function can we use to read the rest of a list and remove it from the buffer?)
  3. Return the results as a `Pair` instance, where the first element is the next complete expression from (1) and the second element is the rest of the combination from (2).

For more hints and a start on how to approach this problem, take a look at [this portion of lecture](https://inst.eecs.berkeley.edu/~cs61a/su20/proj/scheme/ https://youtu.be/qNH7XZZklh0?t=464 ) for additional skeleton code.

After writing code, test your implementation:

```
python3 ok -q 01
```

Now that your parser is complete, you should test the read-eval-print loop by running `python3 scheme_reader.py --repl`. Every time you type in a value into the prompt, both the `str` and `repr` values of the parsed expression are printed. You can try the following inputs

```
    read> 42
    str : 42
    repr: 42
    read> nil
    str : ()
    repr: nil
    read> (1 (2 3) (4 (5)))
    str : (1 (2 3) (4 (5)))
    repr: Pair(1, Pair(Pair(2, Pair(3, nil)), Pair(Pair(4, Pair(Pair(5, nil), nil)), nil)))
```

To exit the interpreter, you can type `exit`

```python
def scheme_read(src):
    """Read the next expression from SRC, a Buffer of tokens.

    >>> scheme_read(Buffer(tokenize_lines(['nil'])))
    nil
    >>> scheme_read(Buffer(tokenize_lines(['1'])))
    1
    >>> scheme_read(Buffer(tokenize_lines(['true'])))
    True
    >>> scheme_read(Buffer(tokenize_lines(['(+ 1 2)'])))
    Pair('+', Pair(1, Pair(2, nil)))
    """
    if src.current() is None:
        raise EOFError
    val = src.pop_first() # Get the first token
    if val == 'nil':
        return nil
    elif val == '(':
        return read_tail(src)
    elif val in quotes:
        return Pair(quotes[val], scheme_read(src))
    elif val not in DELIMITERS:
        return val
    else:
        raise SyntaxError('unexpected token: {0}'.format(val))
def read_tail(src):
    """Return the remainder of a list in SRC, starting before an element or ).

    >>> read_tail(Buffer(tokenize_lines([')'])))
    nil
    >>> read_tail(Buffer(tokenize_lines(['2 3)'])))
    Pair(2, Pair(3, nil))
    """
    try:
        if src.current() is None:
            raise SyntaxError('unexpected end of file')
        elif src.current() == ')':
            src.pop_first()
            return nil
        else:
            return Pair(scheme_read(src), read_tail(src)) 
    except EOFError:
        raise SyntaxError('unexpected end of file')
```

## Part II: Some Core Functionality

> **Important submission note:** For full credit:
>
> - submit with Parts I and II done by **Monday, 8/3** (worth 1 pt), and
> - submit with Parts III and IV complete by **Thursday, 8/6** (worth 1 pt), and
> - submit the entire project by **Monday, 8/10**. You will get an extra credit point for submitting the entire project by Sunday, 8/9. All changes in this part should be made in `scheme.py`.

In the starter implementation given to you, the evaluator can only evaluate self-evaluating expressions: numbers, booleans, and `nil`.

Read the first two sections of `scheme.py`, called Eval/Apply and Environments.

- `scheme_eval` evaluates a Scheme expression in the given environment. This function is nearly complete but is missing the logic for call expressions.
- When evaluating a special form, `scheme_eval` redirects evaluation to an appropriate `do_?_form` function found in the Special Forms section in `scheme.py`.
- `scheme_apply` applies a procedure to some arguments. **(provided)**
- The `.apply` methods in subclasses of `Procedure` and the `make_call_frame` function assist in applying built-in and user-defined procedures.
- The `Frame` class implements an environment frame.
- The `LambdaProcedure` class (in the Procedures section) represents user-defined procedures.

These are all of the essential components of the interpreter; the rest of `scheme.py` defines special forms and input/output behavior.

Test your understanding of how these components fit together by unlocking the tests for `eval_apply`. For some questions you'll have to read the code in `scheme.py`!

```
python3 ok -q eval_apply -u
```

#### Problem 2 (1 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 02 -u
```

Implement the `define` and `lookup` methods of the `Frame` class. Each `Frame` object has the following instance attributes:

- `bindings` is a dictionary representing the bindings in the frame. It maps Scheme symbols (represented as Python strings) to Scheme values.
- `parent` is the parent `Frame` instance. The parent of the Global Frame is `None`.

\1) `define` takes a symbol (represented by a Python string) and a value and binds the value to that symbol in the frame.

\2) `lookup` takes a symbol and returns the value bound to that name in the first `Frame` that the name is found in the current environment. Recall that an *environment* is defined as a frame, its parent frame, and all its ancestor frames, including the Global Frame. Therefore,

- If the name is found in the current frame, return its value.
- If the name is not found in the current frame and the frame has a parent frame, continue lookup in the parent frame.
- If the name is not found in the current frame and there is no parent frame, raise a `SchemeError` **(provided)**.

```python
	def define(self, symbol, value):
        """Define Scheme SYMBOL to have VALUE."""
        self.bindings.update({symbol: value})

    def lookup(self, symbol):
        """Return the value bound to SYMBOL. Errors if SYMBOL is not found."""
        if symbol in self.bindings:
            return self.bindings[symbol]
        elif self.parent:
            return self.parent.lookup(symbol)
        else:
            raise SchemeError('unknown identifier: {0}'.format(symbol))
```

#### Problem 3 (2 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 03 -u
```

To be able to call built-in procedures, such as `+`, you need to complete the `apply` method in the class `BuiltinProcedure`. Built-in procedures are applied by calling a corresponding Python function that implements the procedure. For example, the `+` procedure in Scheme is implemented as the `add` function in Python.

> To see a list of all Scheme built-in procedures used in the project, look in the `scheme_builtins.py` file. Any function decorated with `@builtin` will be added to the globally-defined `BUILTINS` list.

A `BuiltinProcedure` has two instance attributes:

- `fn` is the *Python* function that implements the built-in Scheme procedure.
- `use_env` is a Boolean flag that indicates whether or not this built-in procedure will expect the current environment to be passed in as the last argument. The environment is required, for instance, to implement the built-in `eval` procedure.

The `apply` method of `BuiltinProcedure` takes a list of argument values and the current environment. Note that `args` is a Scheme list represented as a `Pair` object. Your implementation should do the following:

- Convert the Scheme list to a Python list of arguments. *Hint:* `args` is a Pair, which has a `.first` and `.rest` similar to a Linked List. Think about how you would put the values of a Linked List into a list.
- If `self.use_env` is `True`, then add the current environment `env` as the last argument to this Python list.
- Call `self.fn` on all of those arguments using `*args` notation (`f(1, 2, 3)` is equivalent to `f(*[1, 2, 3]`)), and return the result.
- If calling the function results in a `TypeError` exception being raised, then the wrong number of arguments were passed. Use a `try`/`except` block to intercept the exception and raise an appropriate `SchemeError` in its place.

`try`/`except` is a block we can use in Python to catch errors and handle that might be thrown by the Python interpreter. The general structure of a `try`/`except` block is

```
try:
    <code that might throw an error>
except <type of error that might be thrown>:
    <code that we want to execute instead if the error happens>
```

For example, an implementation of `try`/`except` could be

```
>>> def try_divide(a, b):
...     try:
...         return a / b
...     except ZeroDivisionError:
...         print('unacceptable!')
...
>>> try_divide(3, 4)
0.75
>>> try_divide(1, 0)
unacceptable!
```

```python
def apply(self, args, env):
        """Apply SELF to ARGS in ENV, where ARGS is a Scheme list (a Pair instance).

        >>> env = create_global_frame()
        >>> plus = env.bindings['+']
        >>> twos = Pair(2, Pair(2, nil))
        >>> plus.apply(twos, env)
        4
        """
        if not scheme_listp(args):
            raise SchemeError('arguments are not in a list: {0}'.format(args))
        # Convert a Scheme list to a Python list
        python_args = []
        def convert_to_list(pair):
            nonlocal python_args
            if pair != nil:
                python_args.append(pair.first)
                convert_to_list(pair.rest)
        convert_to_list(args)
        if self.use_env:
            python_args.append(env)
        try:
            return self.fn(*python_args)
        except TypeError:
            raise SchemeError('The wrong number of arguments were passed')
```

#### Problem 4 (2 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 04 -u
```

`scheme_eval` evaluates a Scheme expression, represented as a sequence of `Pair` objects, in a given environment. Most of `scheme_eval` has already been implemented for you. It currently looks up names in the current environment, returns self-evaluating expressions (like numbers) and evaluates special forms.

Implement the missing part of `scheme_eval`, which evaluates a call expression. To evaluate a call expression, we do the following:

1. Evaluate the operator (which should evaluate to an instance of `Procedure`)
2. Evaluate all of the operands (when there are multiple operands, we evaluate from left-to-right)
3. Apply the procedure on the evaluated operands, and return the result

You'll have to recursively call `scheme_eval` in the first two steps. Here are some other functions/methods you should use:

- The `validate_procedure` function raises an error if the provided argument is not a Scheme procedure. You can use this to validate that your operator indeed evaluates to a procedure.
- The `map` method of `Pair` returns a new Scheme list constructed by applying a *one-argument function* to every item in a Scheme list.
- The `scheme_apply` function applies a Scheme procedure to a Scheme list of arguments.

```python

def scheme_eval(expr, env, _=None): # Optional third argument is ignored
    """Evaluate Scheme expression EXPR in environment ENV.

    >>> expr = read_line('(+ 2 2)')
    >>> expr
    Pair('+', Pair(2, Pair(2, nil)))
    >>> scheme_eval(expr, create_global_frame())
    4
    """
    # Evaluate atoms
    if scheme_symbolp(expr):
        return env.lookup(expr)
    elif self_evaluating(expr):
        return expr

    # All non-atomic expressions are lists (combinations)
    if not scheme_listp(expr):
        raise SchemeError('malformed list: {0}'.format(repl_str(expr)))
    first, rest = expr.first, expr.rest
    if scheme_symbolp(first) and first in SPECIAL_FORMS:
        return SPECIAL_FORMS[first](rest, env)
    else:
        procedure = scheme_eval(first, env)
        validate_procedure(procedure)
        evaluated_args = rest.map(lambda x: scheme_eval(x, env))
        return scheme_apply(procedure, evaluated_args, env)
```

#### Problem 5 (1 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 05 -u
```

Next, we'll implement defining names. Recall that the `define` special form in Scheme can be used to either assign a name to the value of a given expression or to create a procedure and bind it to a name:

```
scm> (define a (+ 2 3))  ; Binds the name a to the value of (+ 2 3)
a
scm> (define (foo x) x)  ; Creates a procedure and binds it to the name foo
foo
```

The type of the first operand tells us what is being defined:

- If it is a symbol, e.g. `a`, then the expression is defining a name
- If it is a list, e.g. `(foo x)`, then the expression is defining a procedure.

> Read the [Scheme Specifications](https://inst.eecs.berkeley.edu/~cs61a/su20/articles/scheme-spec.html#define) to understand the behavior of the `define` special form! This problem only provides the behavior for binding expressions, not procedures, to names.

There are two missing parts in the `do_define_form` function, which handles the `(define ...)` special forms. For this problem, implement **just the first part**, which evaluates the second operand to obtain a value and binds the first operand, a symbol, to that value. `do_define_form` should return the name after performing the binding.

```
scm> (define tau (* 2 3.1415926))
tau
```

```python
def do_define_form(expressions, env):
    """Evaluate a define form.

    >>> # Problem 5
    >>> env = create_global_frame()
    >>> do_define_form(read_line("(x 2)"), env)
    'x'
    >>> scheme_eval("x", env)
    2
    >>> do_define_form(read_line("(x (+ 2 8))"), env)
    'x'
    >>> scheme_eval("x", env)
    10
    >>> # Problem 9
    >>> env = create_global_frame()
    >>> do_define_form(read_line("((f x) (+ x 2))"), env)
    'f'
    >>> scheme_eval(read_line("(f 3)"), env)
    5
    """
    validate_form(expressions, 2) # Checks that expressions is a list of length at least 2
    target = expressions.first
    if scheme_symbolp(target):
        validate_form(expressions, 2, 2) # Checks that expressions is a list of length exactly 2
        env.define(target, scheme_eval(expressions.rest.first, env))
        return target
    elif isinstance(target, Pair) and scheme_symbolp(target.first):
        # BEGIN PROBLEM 9
        "*** YOUR CODE HERE ***"
        # END PROBLEM 9
    else:
        bad_target = target.first if isinstance(target, Pair) else target
        raise SchemeError('non-symbol: {0}'.format(bad_target))
```

#### Problem 6 (1 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 06 -u
```

To complete the core functionality, let's implement quoting in our interpreter. In Scheme, you can quote expressions in two ways: with the `quote` special form or with the symbol `'`. Recall that the `quote` special form returns its operand expression without evaluating it:

```
scm> (quote hello)
hello
scm> '(cons 1 2)  ; Equivalent to (quote (cons 1 2))
(cons 1 2)
```

> Read the [Scheme Specifications](https://inst.eecs.berkeley.edu/~cs61a/su20/articles/scheme-spec.html#quote) to understand the behavior of the `quote` special form.

Implement the `do_quote_form` function in `scheme.py` so that it simply returns the unevaluated operand of the quote.

After completing this function, you should be able to evaluate quoted expressions. Try out some of the following in your interpreter!

```
scm> (quote a)
a
scm> (quote (1 2))
(1 2)
scm> (quote (1 (2 three (4 5))))
(1 (2 three (4 5)))
scm> (car (quote (a b)))
a
```

Next, complete your implementation of `scheme_read` in `scheme_reader.py` by handling the case for `'`, ```, and `,`. First, notice that `'<expr>` translates to `(quote <expr>)`, ``<expr>` translates to `(quasiquote <expr>)`, and `,<expr>` translates to `(unquote <expr>)`. That means that we need to wrap the expression following one of these characters (which you can get by recursively calling `scheme_read`) into the appropriate special form, which, like all special forms, is really just a list.

For example, `'bagel` should be represented as `Pair('quote', Pair('bagel', nil))`

For another example, `'(1 2)` should be represented as `Pair('quote', Pair(Pair(1, Pair(2, nil)), nil))`.

After completing your `scheme_read` implementation, the following quoted expressions should now work as well.""

```
scm> 'hello
hello
scm> '(1 2)
(1 2)
scm> '(1 (2 three (4 5)))
(1 (2 three (4 5)))
scm> (car '(a b))
a
scm> (eval (cons 'car '('(1 2))))
1
```

```python
def do_quote_form(expressions, env):
    """Evaluate a quote form.

    >>> env = create_global_frame()
    >>> do_quote_form(read_line("((+ x 2))"), env)
    Pair('+', Pair('x', Pair(2, nil)))
    """
    validate_form(expressions, 1, 1)
    return expressions.first

def scheme_read(src):
    """Read the next expression from SRC, a Buffer of tokens.

    >>> scheme_read(Buffer(tokenize_lines(['nil'])))
    nil
    >>> scheme_read(Buffer(tokenize_lines(['1'])))
    1
    >>> scheme_read(Buffer(tokenize_lines(['true'])))
    True
    >>> scheme_read(Buffer(tokenize_lines(['(+ 1 2)'])))
    Pair('+', Pair(1, Pair(2, nil)))
    """
    if src.current() is None:
        raise EOFError
    val = src.pop_first() # Get the first token
    if val == 'nil':
        return nil
    elif val == '(':
        return read_tail(src)
    elif val in quotes:
        return Pair(quotes[val], Pair(scheme_read(src), nil))
    elif val not in DELIMITERS:
        return val
    else:
        raise SyntaxError('unexpected token: {0}'.format(val))
```

