## Streams

### Q1: Run-Length Encoding

Run-length encoding is a very simple data compression technique, whereby runs of data are compressed and stored as a single value. A *run* is defined to be a contiguous sequence of the same number. For example, in the (finite) sequence

```
1, 1, 1, 1, 1, 6, 6, 6, 6, 2, 5, 5, 5
```

there are four runs: one each of 1, 6, 2, and 5. We can represent the same sequence as a sequence of two-element lists:

```
(1 5), (6 4), (2 1), (5 3)
```

Notice that the first element of each list is the number in a run, and the second element is the number of times that number appears in the run.

We will extend this idea to streams. Write a function called `rle` that takes in a stream of data, and returns a corresponding stream of two-element lists, which represents the run-length encoded version of the stream. You do not have to consider compressing infinite streams - the stream passed in will eventually terminate with `nil`.

```scheme
(define (rle s)
    (define (helper number cnt ss)
        (if (null? ss)
            (if (= 0 cnt)
                nil   
                (cons-stream (list number cnt) nil)   
            )
            (if (= (car ss) number)
                (helper number (+ 1 cnt) (cdr-stream ss))
                (if (= cnt 0)
                    (helper (car ss) (+ 1 cnt) (cdr-stream ss))
                    (cons-stream
                        (list number cnt)
                        (helper -1 0 ss)
                    )
                )
            )
        )
    )
    (helper -1 0 s)
)


(define (group-by-nondecreasing s)
    'YOUR-CODE-HERE)


(define finite-test-stream
    (cons-stream 1
        (cons-stream 2
            (cons-stream 3
                (cons-stream 1
                    (cons-stream 2
                        (cons-stream 2
                            (cons-stream 1 nil))))))))

(define infinite-test-stream
    (cons-stream 1
        (cons-stream 2
            (cons-stream 2
                infinite-test-stream))))
```

### Q2: Group By Nondecreasing

Define a function `group-by-nondecreasing`, which takes in a stream of numbers and outputs a stream of lists, which overall has the same numbers in the same order, but grouped into segments that are non-decreasing.

For example, if the input is a stream containing elements

```
1 2 3 4 1 2 3 4 1 1 1 2 1 1 0 4 3 2 1 ...
```

the output should contain elements

```
(1 2 3 4) (1 2 3 4) (1 1 1 2) (1 1) (0 4) (3) (2) (1) ...
```

If the input is an infinite stream, the output should be an infinite stream and if the input is finite, the output should also be finite. Even if the input is an infinite stream, you can assume that every non-decreasing segment is finite.

> Hint: avoid any direct recursive calls outside the context of a second part of a call to `cons-stream`, otherwise your solution won't work for infinite streams!

```scheme
(define (group-by-nondecreasing s)
    (define (helper now last_num ss)
        (if (null? ss)
            (if (null? now)
                nil
                (cons-stream now nil)
            )    
            (if (>= (car ss) last_num)
                (helper (append now (list (car ss))) (car ss) (cdr-stream ss))
                (cons-stream
                    now
                    (helper nil -1 ss)
                )
            )
        )
    )
    (helper nil -1 s)
)
```

## SQL

### Dog Data

In each question below, you will define a new table based on the following tables.

```
CREATE TABLE parents AS
  SELECT "abraham" AS parent, "barack" AS child UNION
  SELECT "abraham"          , "clinton"         UNION
  SELECT "delano"           , "herbert"         UNION
  SELECT "fillmore"         , "abraham"         UNION
  SELECT "fillmore"         , "delano"          UNION
  SELECT "fillmore"         , "grover"          UNION
  SELECT "eisenhower"       , "fillmore";

CREATE TABLE dogs AS
  SELECT "abraham" AS name, "long" AS fur, 26 AS height UNION
  SELECT "barack"         , "short"      , 52           UNION
  SELECT "clinton"        , "long"       , 47           UNION
  SELECT "delano"         , "long"       , 46           UNION
  SELECT "eisenhower"     , "short"      , 35           UNION
  SELECT "fillmore"       , "curly"      , 32           UNION
  SELECT "grover"         , "short"      , 28           UNION
  SELECT "herbert"        , "curly"      , 31;

CREATE TABLE sizes AS
  SELECT "toy" AS size, 24 AS min, 28 AS max UNION
  SELECT "mini"       , 28       , 35        UNION
  SELECT "medium"     , 35       , 45        UNION
  SELECT "standard"   , 45       , 60;
```

Your tables should still perform correctly even if the values in these tables change. For example, if you are asked to list all dogs with a name that starts with h, you should write:

```
SELECT name FROM dogs WHERE "h" <= name AND name < "i";
```

Instead of assuming that the `dogs` table has only the data above and writing

```
SELECT "herbert";
```

The former query would still be correct if the name `grover` were changed to `hoover` or a row was added with the name `harry`.

### Q3: Size of Dogs

The Fédération Cynologique Internationale classifies a standard poodle as over 45 cm and up to 60 cm. The `sizes` table describes this and other such classifications, where a dog must be over the `min` and less than or equal to the `max` in `height` to qualify as a `size`.

Create a `size_of_dogs` table with two columns, one for each dog's `name` and another for its `size`.

```
-- The size of each dog
CREATE TABLE size_of_dogs AS
  SELECT "REPLACE THIS LINE WITH YOUR SOLUTION";
```

The output should look like the following:

```
sqlite> select * from size_of_dogs;
abraham|toy
barack|standard
clinton|standard
delano|standard
eisenhower|mini
fillmore|mini
grover|toy
herbert|mini
```

```sql
-- The size of each dog
CREATE TABLE size_of_dogs AS
  SELECT  dogs.name AS "name", sizes.size AS "size" FROM dogs, sizes
    WHERE sizes.min < dogs.height and dogs.height <= sizes.max;
```

### Q4: By Parent Height

Create a table `by_parent_height` that has a column of the names of all dogs that have a `parent`, ordered by the height of the parent from tallest parent to shortest parent.

```
-- All dogs with parents ordered by decreasing height of their parent
CREATE TABLE by_parent_height AS
  SELECT "REPLACE THIS LINE WITH YOUR SOLUTION";
```

For example, `fillmore` has a parent (`eisenhower`) with height 35, and so should appear before `grover` who has a parent (`fillmore`) with height 32. The names of dogs with parents of the same height should appear together in any order. For example, `barack` and `clinton` should both appear at the end, but either one can come before the other.

```
sqlite> select * from by_parent_height;
herbert
fillmore
abraham
delano
grover
barack
clinton
```

```sql
CREATE TABLE by_parent_height AS
  SELECT parents.child as "name" FROM parents, dogs WHERE dogs.name == parents.parent ORDER BY -dogs.height
```

### Q5: Sentences

There are two pairs of siblings that have the same size. Create a table that contains a row with a string for each of these pairs. Each string should be a sentence describing the siblings by their size.

```
-- Filling out this helper table is optional
CREATE TABLE siblings AS
  SELECT "REPLACE THIS LINE WITH YOUR SOLUTION";

-- Sentences about siblings that are the same size
CREATE TABLE sentences AS
  SELECT "REPLACE THIS LINE WITH YOUR SOLUTION";
```

Each sibling pair should appear only once in the output, and siblings should be listed in alphabetical order (e.g. `"barack and clinton..."` instead of `"clinton and barack..."`), as follows:

```
sqlite> select * from sentences;
abraham and grover are toy siblings
barack and clinton are standard siblings
```

> *Hint*: First, create a helper table containing each pair of siblings. This will make comparing the sizes of siblings when constructing the main table easier.
>
> **Hint**: If you join a table with itself, use `AS` within the `FROM` clause to give each table an alias.
>
> **Hint**: In order to concatenate two strings into one, use the `||` operator.

```sql
-- Ways to stack 4 dogs to a height of at least 170, ordered by total height
CREATE TABLE stacks_helper(dogs, stack_height, last_height, n);

-- Add your INSERT INTOs here
  INSERT INTO stacks_helper SELECT dogs.name, dogs.height, dogs.height, 1 FROM dogs;
  INSERT INTO stacks_helper SELECT stacks_helper.dogs || ", " || dogs.name, 
    dogs.height + stacks_helper.stack_height, dogs.height, 2
    FROM stacks_helper, dogs WHERE dogs.height > stacks_helper.last_height;
  INSERT INTO stacks_helper SELECT stacks_helper.dogs || ", " || dogs.name, 
    dogs.height + stacks_helper.stack_height, dogs.height, 3
    FROM stacks_helper, dogs WHERE dogs.height > stacks_helper.last_height;
  INSERT INTO stacks_helper SELECT stacks_helper.dogs || ", " || dogs.name, 
    dogs.height + stacks_helper.stack_height, dogs.height, 4
    FROM stacks_helper, dogs WHERE dogs.height > stacks_helper.last_height;

CREATE TABLE stacks AS
  SELECT stacks_helper.dogs || "|" || stacks_helper.stack_height FROM stacks_helper 
    WHERE stacks_helper.stack_height > 170 ORDER BY stacks_helper.stack_height;
```

