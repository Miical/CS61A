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

