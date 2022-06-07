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

## Part III: User-Defined Procedures

> **Important submission note:** For full credit:
>
> - submit with Parts III and IV complete by **Thursday, 8/6** (worth 1 pt), and
> - submit the entire project by **Monday, 8/10**. You will get an extra credit point for submitting the entire project by Sunday, 8/9.

User-defined procedures are represented as instances of the `LambdaProcedure` class. A `LambdaProcedure` instance has three instance attributes:

- `formals` is a Scheme list of the formal parameters (symbols) that name the arguments of the procedure.
- `body` is a Scheme list of expressions; the body of the procedure.
- `env` is the environment in which the procedure was **defined**.

#### Problem 7 (1 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 07 -u
```

> Read the [Scheme Specifications](https://inst.eecs.berkeley.edu/~cs61a/su20/articles/scheme-spec.html#begin) to understand the behavior of the `begin` special form!

Change the `eval_all` function (which is called from `do_begin_form`) to complete the implementation of the `begin` special form. A `begin` expression is evaluated by evaluating all sub-expressions in order. The value of the `begin` expression is the value of the final sub-expression.

```
scm> (begin (+ 2 3) (+ 5 6))
11
scm> (define x (begin (display 3) (newline) (+ 2 3)))
3
x
scm> (+ x 3)
8
scm> (begin (print 3) '(+ 2 3))
3
(+ 2 3)
```

If `eval_all` is passed an empty list of expressions (`nil`), then it should return the Python value `None`, which represents an undefined Scheme value.

```python
def eval_all(expressions, env):
    """Evaluate each expression in the Scheme list EXPRESSIONS in
    environment ENV and return the value of the last.

    >>> eval_all(read_line("(1)"), create_global_frame())
    1
    >>> eval_all(read_line("(1 2)"), create_global_frame())
    2
    >>> x = eval_all(read_line("((print 1) 2)"), create_global_frame())
    1
    >>> x
    2
    >>> eval_all(read_line("((define x 2) x)"), create_global_frame())
    2
    """
    # BEGIN PROBLEM 7
    if expressions == nil:
        return None
    elif expressions.rest == nil:
        return scheme_eval(expressions.first, env)
    else:
        scheme_eval(expressions.first, env)
        return eval_all(expressions.rest, env)
    # END PROBLEM 7
```

#### Problem 8 (1 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 08 -u
```

> Read the [Scheme Specifications](https://inst.eecs.berkeley.edu/~cs61a/su20/articles/scheme-spec.html#lambda) to understand the behavior of the `lambda` special form!

A `LambdaProcedure` represents a user-defined procedure. It has a list of `formals` (parameter names), a `body` of expressions to evaluate, and a parent frame `env`.

Implement the `do_lambda_form` function, which creates and returns a `LambdaProcedure` instance. While you cannot call a user-defined procedure yet, you can verify that you have created the procedure correctly by typing a lambda expression into the interpreter prompt:

```
scm> (lambda (x y) (+ x y))
(lambda (x y) (+ x y))
```

In Scheme, it is legal to place more than one expression in the body of a procedure (there must be at least one expression). The `body` attribute of a `LambdaProcedure` instance is a Scheme list of body expressions.

```python
def do_lambda_form(expressions, env):
    """Evaluate a lambda form.

    >>> env = create_global_frame()
    >>> do_lambda_form(read_line("((x) (+ x 2))"), env)
    LambdaProcedure(Pair('x', nil), Pair(Pair('+', Pair('x', Pair(2, nil))), nil), <Global Frame>)
    """
    validate_form(expressions, 2)
    formals = expressions.first
    validate_formals(formals)
    return LambdaProcedure(expressions.first, expressions.rest, env)
```

#### Problem 9 (1 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 09 -u
```

> Read the [Scheme Specifications](https://inst.eecs.berkeley.edu/~cs61a/su20/articles/scheme-spec.html#define) to understand the behavior of the `define` special form! In this problem, we'll finish defining the `define` form for procedures.

Currently, your Scheme interpreter is able to bind symbols to user-defined procedures in the following manner:

```
scm> (define f (lambda (x) (* x 2)))
f
```

However, we'd like to be able to use the shorthand form of defining named procedures:

```
scm> (define (f x) (* x 2))
```

Modify the `do_define_form` function so that it correctly handles the shorthand procedure definition form above. Make sure that it can handle multi-expression bodies.

Your implementation should do the following:

- Using the given variables `target` and `expressions`, find the defined function's name, formals, and body.
- Create a `LambdaProcedure` instance using the formals and body. *Hint:* You can use what you've done in Problem 8
- Bind the name to the `LambdaProcedure` instance

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
        env.define(target.first, do_lambda_form(Pair(target.rest, expressions.rest), env))
        return target.first
    else:
        bad_target = target.first if isinstance(target, Pair) else target
        raise SchemeError('non-symbol: {0}'.format(bad_target))

```

#### Problem 10 (1 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 10 -u
```

Implement the `make_child_frame` method of the `Frame` class which will be used to create new call frames for user-defined procedures. This method takes in two arguments: `formals`, which is a Scheme list of symbols, and `vals`, which is a Scheme list of values. It should return a new child frame, binding the formal parameters to the values.

To do this:

- If the number of argument values does not match with the number of formal parameters, raise a `SchemeError`. **(provided)**
- Create a new `Frame` instance, the parent of which is `self`.
- Bind each formal parameter to its corresponding argument value in the newly created frame. The first symbol in `formals` should be bound to the first value in `vals`, and so on. If the number of argument values does not match with the number of formal parameters, raise a `SchemeError`.
- Return the new frame.

> *Hint:* The `define` method of a `Frame` instance creates a binding in that frame.

```python
    def make_child_frame(self, formals, vals):
        """Return a new local frame whose parent is SELF, in which the symbols
        in a Scheme list of formal parameters FORMALS are bound to the Scheme
        values in the Scheme list VALS. Raise an error if too many or too few
        vals are given.

        >>> env = create_global_frame()
        >>> formals, expressions = read_line('(a b c)'), read_line('(1 2 3)')
        >>> env.make_child_frame(formals, expressions)
        <{a: 1, b: 2, c: 3} -> <Global Frame>>
        """
        if len(formals) != len(vals):
            raise SchemeError('Incorrect number of arguments to function call')
        # BEGIN PROBLEM 10
        new_env = Frame(self) 
        while formals != nil:
            new_env.define(formals.first, vals.first)
            formals, vals = formals.rest, vals.rest
        return new_env
        # END PROBLEM 10
```

#### Problem 11 (2 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 11 -u
```

Implement the `make_call_frame` method in `LambdaProcedure`, which is needed by `scheme_apply`. It should create and return a new `Frame` instance using the `make_child_frame` method of the appropriate parent frame, binding formal parameters to argument values.

Since lambdas are lexically scoped, your new frame should be a child of the frame in which the lambda is defined. The `env` provided as an argument to `make_call_frame` is instead the frame in which the procedure is called, which will be useful as you implement dynamically scoped procedures in problem 15.

```python
    def make_call_frame(self, args, env):
        """Make a frame that binds my formal parameters to ARGS, a Scheme list
        of values, for a lexically-scoped call evaluated in my parent environment."""
        # BEGIN PROBLEM 11
        return self.env.make_child_frame(self.formals, args)
        # END PROBLEM 11
```

## Part IV: Special Forms

> **Important submission note:** For full credit:
>
> - submit with Parts III and IV complete by **Thursday, 8/6** (worth 1 pt), and
> - submit the entire project by **Monday, 8/10**. You will get an extra credit point for submitting the entire project by Sunday, 8/9.

Logical special forms include `if`, `and`, `or`, and `cond`. These expressions are special because not all of their sub-expressions may be evaluated.

In Scheme, only `False` is a false value. All other values (including `0` and `nil`) are true values. You can test whether a value is a true or false value using the provided Python functions `is_true_primitive` and `is_false_primitive`, defined in `scheme_builtins.py`.

> Note: Scheme traditionally uses `#f` to indicate the false Boolean value. In our interpreter, that is equivalent to `false` or `False`. Similarly, `true`, `True`, and `#t` are all equivalent. However when unlocking tests, use `#t` and `#f`.

To get you started, we've provided an implementation of the `if` special form in the `do_if_form` function. Make sure you understand that implementation before starting the following questions.

#### Problem 12 (1 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 12 -u
```

> Read the [Scheme Specifications](https://inst.eecs.berkeley.edu/~cs61a/su20/articles/scheme-spec.html#and) to understand the behavior of the `and` and `or` special forms!

Implement `do_and_form` and `do_or_form` so that `and` and `or` expressions are evaluated correctly.

The logical forms `and` and `or` are *short-circuiting*. For `and`, your interpreter should evaluate each sub-expression from left to right, and if any of these evaluates to a false value, then `#f` is returned. Otherwise, it should return the value of the last sub-expression. If there are no sub-expressions in an `and` expression, it evaluates to `#t`.

```
scm> (and)
#t
scm> (and 4 5 6)  ; all operands are true values
6
scm> (and 4 5 (+ 3 3))
6
scm> (and #t #f 42 (/ 1 0))  ; short-circuiting behavior of and
#f
```

For `or`, evaluate each sub-expression from left to right. If any sub-expression evaluates to a true value, return that value. Otherwise, return `#f`. If there are no sub-expressions in an `or` expression, it evaluates to `#f`.

```
scm> (or)
#f
scm> (or 5 2 1)  ; 5 is a true value
5
scm> (or #f (- 1 1) 1)  ; 0 is a true value in Scheme
0
scm> (or 4 #t (/ 1 0))  ; short-circuiting behavior of or
4
```

Remember that you can use the provided Python functions `is_true_primitive` and `is_false_primitive` to test boolean values.

```python
def do_and_form(expressions, env):
    """Evaluate a (short-circuited) and form.

    >>> env = create_global_frame()
    >>> do_and_form(read_line("(#f (print 1))"), env)
    False
    >>> do_and_form(read_line("((print 1) (print 2) (print 3) (print 4) 3 #f)"), env)
    1
    2
    3
    4
    False
    """
    # BEGIN PROBLEM 12
    if expressions == nil:
        return True
    val = scheme_eval(expressions.first, env) 
    while not val is False and expressions.rest != nil:
        expressions = expressions.rest
        val = scheme_eval(expressions.first, env) 
    return val
    # END PROBLEM 12

def do_or_form(expressions, env):
    """Evaluate a (short-circuited) or form.

    >>> env = create_global_frame()
    >>> do_or_form(read_line("(10 (print 1))"), env)
    10
    >>> do_or_form(read_line("(#f 2 3 #t #f)"), env)
    2
    >>> do_or_form(read_line("((begin (print 1) #f) (begin (print 2) #f) 6 (begin (print 3) 7))"), env)
    1
    2
    6
    """
    # BEGIN PROBLEM 12
    if expressions == nil:
        return False
    val = scheme_eval(expressions.first, env) 
    while val is False and expressions.rest != nil:
        expressions = expressions.rest
        val = scheme_eval(expressions.first, env) 
    return val
    # END PROBLEM 12
```

#### Problem 13 (2 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 13 -u
```

> Read the [Scheme Specifications](https://inst.eecs.berkeley.edu/~cs61a/su20/articles/scheme-spec.html#cond) to understand the behavior of the `cond` special form!

Fill in the missing parts of `do_cond_form` so that it returns the value of the first result sub-expression corresponding to a true predicate, or the result sub-expression corresponding to `else`. Some special cases:

- When the true predicate does not have a corresponding result sub-expression, return the predicate value.
- When a result sub-expression of a `cond` case has multiple expressions, evaluate them all and return the value of the last expression. (*Hint*: Use `eval_all`.)

Your implementation should match the following examples and the additional tests in `tests.scm`.

```
scm> (cond ((= 4 3) 'nope)
           ((= 4 4) 'hi)
           (else 'wait))
hi
scm> (cond ((= 4 3) 'wat)
           ((= 4 4))
           (else 'hm))
#t
scm> (cond ((= 4 4) 'here (+ 40 2))
           (else 'wat 0))
42
```

The value of a `cond` is `undefined` if there are no true predicates and no `else`. In such a case, `do_cond_form` should return `None`. If there is only an `else`, return its sub-expression. If it doesn't have one, return `#t`.

```
scm> (cond (False 1) (False 2))
scm> (cond (else))
#t
```

```python
def do_cond_form(expressions, env):
    """Evaluate a cond form.

    >>> do_cond_form(read_line("((#f (print 2)) (#t 3))"), create_global_frame())
    3
    """
    while expressions is not nil:
        clause = expressions.first
        validate_form(clause, 1)
        if clause.first == 'else':
            test = True
            if expressions.rest != nil:
                raise SchemeError('else must be last')
        else:
            test = scheme_eval(clause.first, env)
        if is_true_primitive(test):
            if clause.rest == nil:
                return test
            else: 
                return eval_all(clause.rest, env)
        expressions = expressions.rest
```

#### Problem 14 (1 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 14 -u
```

> Read the [Scheme Specifications](https://inst.eecs.berkeley.edu/~cs61a/su20/articles/scheme-spec.html#let) to understand the behavior of the `let` special form!

The `let` special form binds symbols to values locally, giving them their initial values. For example:

```
scm> (define x 5)
x
scm> (define y 'bye)
y
scm> (let ((x 42)
           (y (* x 10)))  ; x refers to the global value of x, not 42
       (list x y))
(42 50)
scm> (list x y)
(5 bye)
```

Implement `make_let_frame`, which returns a child frame of `env` that binds the symbol in each element of `bindings` to the value of its corresponding expression. The `bindings` scheme list contains pairs that each contain a symbol and a corresponding expression.

You may find the following functions and methods useful:

- `validate_form`: this function can be used to validate the structure of each binding. It takes in a list `expr` of expressions and a `min` and `max` length. If `expr` is not a proper list or does not have between `min` and `max` items inclusive, it raises an error. If no `max` is passed in, the default is infinity.
- `validate_formals`: this function validates that formal parameters are a Scheme list of symbols for which each symbol is distinct.
- `make_child_frame`: this method of the `Frame` class (which you implemented in [Problem 11](https://inst.eecs.berkeley.edu/~cs61a/su20/proj/scheme/#problem-11)) takes a `Pair` of formal parameters (symbols) and a `Pair` of values, and returns a new frame with all the symbols bound to the corresponding values.

```python
def make_let_frame(bindings, env):
    """Create a child frame of ENV that contains the definitions given in
    BINDINGS. The Scheme list BINDINGS must have the form of a proper bindings
    list in a let expression: each item must be a list containing a symbol
    and a Scheme expression."""
    if not scheme_listp(bindings):
        raise SchemeError('bad bindings list in let form')
    names, values = nil, nil
    # BEGIN PROBLEM 14
    while bindings != nil:
        validate_form(bindings.first, 2, 2)
        names = Pair(bindings.first.first, names)
        values = Pair(scheme_eval(bindings.first.rest.first, env), values)
        bindings = bindings.rest
    validate_formals(names)
    # END PROBLEM 14
    return env.make_child_frame(names, values)
```

#### Problem 15 (2 pt)

Before writing any code, test your understanding of the problem:

```
python3 ok -q 15 -u
```

> Read the [Scheme Specifications](https://inst.eecs.berkeley.edu/~cs61a/su20/articles/scheme-spec.html#mu) to understand the behavior of the `mu` special form!

All of the Scheme procedures we've seen so far use *lexical scoping:* the parent of the new call frame is the environment in which the procedure was **defined**. Another type of scoping, which is not standard in Scheme, is called *dynamic scoping:* the parent of the new call frame is the environment in which the procedure was **evaluated**. With dynamic scoping, calling the same procedure in different parts of your code can lead to different results (because of varying parent frames).

In this problem, we will implement the `mu` special form, a non-standard Scheme expression type representing a procedure that is dynamically scoped.

In the example below, we use the `mu` keyword instead of `lambda` to define a dynamically scoped procedure `f`:

```
scm> (define f (mu () (* a b)))
f
scm> (define g (lambda () (define a 4) (define b 5) (f)))
g
scm> (g)
20
```

The procedure `f` does not have an `a` or `b` defined; however, because `f` gets called within the procedure `g`, it has access to the `a` and `b` defined in `g`'s frame.

Implement `do_mu_form` to evaluate the `mu` special form. A `mu` expression is similar to a `lambda` expression, but evaluates to a `MuProcedure` instance that is **dynamically scoped**. Most of the `MuProcedure` class has been provided for you.

In addition to filling out the body of `do_mu_form`, you'll need to complete the `MuProcedure` class so that when a call on such a procedure is executed, it is dynamically scoped. This means that when a `MuProcedure` created by a `mu` expression is called, the parent of the new call frame is the environment in which the call expression was **evaluated**. As a result, a `MuProcedure` does not need to store an environment as an instance attribute. It can refer to names in the environment from which it was called.

Looking at `LambdaProcedure` should give you a clue about what needs to be done to `MuProcedure` to complete it. You will not need to modify any existing methods, but may wish to implement new ones.

```python
class MuProcedure(Procedure):
    """A procedure defined by a mu expression, which has dynamic scope.
     _________________
    < Scheme is cool! >
     -----------------
            \   ^__^
             \  (oo)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||
    """

    def __init__(self, formals, body):
        """A procedure with formal parameter list FORMALS (a Scheme list) and
        Scheme list BODY as its definition."""
        self.formals = formals
        self.body = body

    # BEGIN PROBLEM 15
    def make_call_frame(self, args, env):
        return env.make_child_frame(self.formals, args)
    # END PROBLEM 15

    def __str__(self):
        return str(Pair('mu', Pair(self.formals, self.body)))

    def __repr__(self):
        return 'MuProcedure({0}, {1})'.format(
            repr(self.formals), repr(self.body))

def do_mu_form(expressions, env):
    """Evaluate a mu form."""
    validate_form(expressions, 2)
    formals = expressions.first
    validate_formals(formals)
    # BEGIN PROBLEM 18
    return MuProcedure(expressions.first, expressions.rest)
    # END PROBLEM 18
```

