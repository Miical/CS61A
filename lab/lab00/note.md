## Python Basics

### Primitive expressions

```python
>>> 3
3
>>> 12.5
12.5
>>> True
True
```

### Arithmetic expressions

- `+` operator - addition
- `-` operator - subtraction
- `*` operator - multiplication
- `**` operator - exponentiation
- division-like operator
  - Floating point division (`/`)
  - Floor division (`//`)   
  - Module (`%`)

### Assignment statements

```python
>> a = (100 + 50) // 2
```



## Doing the assignment

### Unlocking tests

```python 
python3 ok -q python-basics -u
```

### Understanding problems

```python
def twenty_twenty():
    """Come up with the most creative expression that evaluates to 2020,
    using only numbers and the +, *, and - operators.

    >>> twenty_twenty()
    2020
    """
    return ______
```

The lines in the triple-quotes `"""` are called a **docstring**, which is a description of what the function is supposed to do.

The lines that begin with '>>>' are called **doctests**. Doctests explain what the function does by showing actual python code. it answers the question: "If we input this Python code, what should the expected output be?"

 ### Running tests

```python
python3 ok
```

###  Submitting the assignment

```python
python3 ok --submit
```

>  More information on OK is available [here](https://inst.eecs.berkeley.edu/~cs61a/su20/articles/using-ok.html)
>
> You can also use the `--help` flag:
>
> ```python 
> python3 ok --help
> ```



### Appendix: Useful Python command line options

- Using no command-line options will run the code in the file you provide and return you to the command line.

  ```python
  python3
  ```

- `-i`: The `-i` option runs your Python script, then opens an interactive session. In an interactive session, you run Python code line by line and get immediate feedback instead of running an entire file all at once. To exit, type `exit()` into the interpreter prompt. You can also use the keyboard shortcut `Ctrl-D` on Linux/Max machines or `Ctrl-Z Enter'

  ```python
  python3 -i
  ```

- **`-m doctest`**: Runs doctests in a particular file. Doctests are surrounded by triple quotes (`"""`) within functions.

  Each test in the file consists of `>>>` followed by some Python code and the expected output (though the `>>>` are not seen in the output of the doctest command).

  ```python
   python3 -m doctest 
  ```

