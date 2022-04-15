Project Website: https://inst.eecs.berkeley.edu/~cs61a/su20/proj/hog/

## Rules

In Hog, two players alternate turns trying to be the first to end a turn with at least 100 total points. On each turn, the current player chooses some number of dice to roll, up to 10. That player's score for the turn is the sum of the dice outcomes. However, a player who rolls too many dice risks:

- **Pig Out**. If any of the dice outcomes is a 1, the current player's score for the turn is 1.

In a normal game of Hog, those are all the rules. To spice up the game, we'll include some special rules:

- **Free Bacon**. A player who chooses to roll zero dice scores points equal to ten minus the value of the opponent score's ones digit, summed with the value of the opponent's score's tens digit.

- **Feral Hogs**. If the number of dice you roll is exactly 2 away (absolute difference) from the number of points you scored on the previous turn, you get 3 extra points for the turn. Treat the turn before the first turn as scoring 0 points. Do **not** take into account any previous feral hog bonuses or swine swap (next rule) when calculating the number of points scored the previous turn.

- **Swine Swap**. After points for the turn are added to the current player's score, if the absolute value of the difference between the current player score's ones digit and the opponent score's ones digit is equal to the value of the opponent score's tens digit, the scores should be swapped. **A swap may occur at the end of a turn in which a player reaches the goal score, leading to the opponent winning.**

## Phase 1: Simulator

### Problem 1 (2 pt)

Implement the `roll_dice` function in `hog.py`. It takes two arguments: a positive integer called `num_rolls` giving the number of dice to roll and a `dice` function. It returns the number of points scored by rolling the dice that number of times in a turn: either the sum of the outcomes or 1 (*Pig Out*).

```python
def roll_dice(num_rolls, dice=six_sided):
    """Simulate rolling the DICE exactly NUM_ROLLS > 0 times. Return the sum of
    the outcomes unless any of the outcomes is 1. In that case, return 1.

    num_rolls:  The number of dice rolls that will be made.
    dice:       A function that simulates a single dice roll outcome.
    """
    # These assert statements ensure that num_rolls is a positive integer.
    assert type(num_rolls) == int, 'num_rolls must be an integer.'
    assert num_rolls > 0, 'Must roll at least once.'
    # BEGIN PROBLEM 1
    "*** YOUR CODE HERE ***"
    sum, num_ones = 0, 0
    while num_rolls:
        num = dice()
        if num == 1:
            num_ones += 1
        sum, num_rolls = sum + num, num_rolls - 1
    return 1 if num_ones else sum
    # END PROBLEM 1
```

### Problem 2 (1 pt)

Implement the `free_bacon` helper function that returns the number of points scored by rolling 0 dice, based on the opponent's current `score`. You can assume that `score` is less than 100. For a score less than 10, assume that the tens digit of a player's score is 0.

```python
def free_bacon(score):
    """Return the points scored from rolling 0 dice (Free Bacon).

    score:  The opponent's current score.
    """
    assert score < 100, 'The game should be over.'
    # BEGIN PROBLEM 2
    "*** YOUR CODE HERE ***"
    return (10 - score%10) + (score//10%10)
    # END PROBLEM 2
```

### Problem 3 (2 pt)

Implement the `take_turn` function, which returns the number of points scored for a turn by rolling the given `dice` `num_rolls` times.

Your implementation of `take_turn` should call both `roll_dice` and `free_bacon` when possible.

```python
def take_turn(num_rolls, opponent_score, dice=six_sided):
    """Simulate a turn rolling NUM_ROLLS dice, which may be 0 (Free Bacon).
    Return the points scored for the turn by the current player.

    num_rolls:       The number of dice rolls that will be made.
    opponent_score:  The total score of the opponent.
    dice:            A function that simulates a single dice roll outcome.
    """
    # Leave these assert statements here; they help check for errors.
    assert type(num_rolls) == int, 'num_rolls must be an integer.'
    assert num_rolls >= 0, 'Cannot roll a negative number of dice in take_turn.'
    assert num_rolls <= 10, 'Cannot roll more than 10 dice.'
    assert opponent_score < 100, 'The game should be over.'
    # BEGIN PROBLEM 3
    "*** YOUR CODE HERE ***"
    if num_rolls:
        return roll_dice(num_rolls, dice)
    else:
        return free_bacon(opponent_score)
    # END PROBLEM 3
```

### Problem 4 (2 pt)

Implement `is_swap`, which returns whether or not the scores should be swapped.

> The Swine Swap rule is reproduced below:

- **Swine Swap**. After points for the turn are added to the current player's score, if the absolute value of the difference between the current player score's ones digit and the opponent score's ones digit is equal to the value of the opponent score's tens digit, the scores should be swapped. **A swap may occur at the end of a turn in which a player reaches the goal score, leading to the opponent winning.**

> **Hint**: The `%` operator may be useful here.

The `is_swap` function takes two arguments: the current player's score and the opponent's score. It returns a boolean value to indicate whether the *Swine Swap* condition is met.

```python
def is_swap(player_score, opponent_score):
    """
    Return whether the two scores should be swapped
    """
    # BEGIN PROBLEM 4
    "*** YOUR CODE HERE ***"
    diff = abs(player_score%10 - opponent_score%10)
    return diff == (opponent_score//10%10)
    # END PROBLEM 4
```

### Problem 5a (3 pt)

Implement the `play` function, which simulates a full game of Hog. Players alternate turns rolling dice until one of the players reaches the `goal` score.

You can ignore the **Feral Hogs** rule and `feral_hogs` argument for now; You'll implement it in Problem 5b.

To determine how much dice are rolled each turn, each player uses their respective strategy (Player 0 uses `strategy0` and Player 1 uses `strategy1`). A *strategy* is a function that, given a player's score and their opponent's score, returns the number of dice that the current player wants to roll in the turn. Each strategy function should be called only once per turn. Don't worry about the details of implementing strategies yet. You will develop them in Phase 3.

When the game ends, `play` returns the final total scores of both players, with Player 0's score first, and Player 1's score second.

Here are some hints:

- You should use the functions you have already written! You will need to call `take_turn` with all three arguments.
- Only call `take_turn` once per turn.
- Enforce all the special rules except for feral hogs.
- You can get the number of the other player (either 0 or 1) by calling the provided function `other`.
- You can ignore the `say` argument to the `play` function for now. You will use it in Phase 2 of the project.

```python
def play(strategy0, strategy1, score0=0, score1=0, dice=six_sided,
         goal=GOAL_SCORE, say=silence, feral_hogs=True):
    """Simulate a game and return the final scores of both players, with Player
    0's score first, and Player 1's score second.

    A strategy is a function that takes two total scores as arguments (the
    current player's score, and the opponent's score), and returns a number of
    dice that the current player will roll this turn.

    strategy0:  The strategy function for Player 0, who plays first.
    strategy1:  The strategy function for Player 1, who plays second.
    score0:     Starting score for Player 0
    score1:     Starting score for Player 1
    dice:       A function of zero arguments that simulates a dice roll.
    goal:       The game ends and someone wins when this score is reached.
    say:        The commentary function to call at the end of the first turn.
    feral_hogs: A boolean indicating whether the feral hogs rule should be active.
    """
    who = 0  # Who is about to take a turn, 0 (first) or 1 (second)
    # BEGIN PROBLEM 5
    "*** YOUR CODE HERE ***"
    while score0 < goal and score1 < goal:
        if who == 0:
            score0 += take_turn(strategy0(score0, score1), score1, dice)
            if (is_swap(score0, score1)):
                score0, score1 = score1, score0
        else:
            score1 += take_turn(strategy1(score1, score0), score0, dice)
            if (is_swap(score1, score0)):
                score0, score1 = score1, score0

        who = other(who)
    # END PROBLEM 5
    # (note that the indentation for the problem 6 prompt (***YOUR CODE HERE***) might be misleading)
    # BEGIN PROBLEM 6
    "*** YOUR CODE HERE ***"
    # END PROBLEM 6
    return score0, score1
```

### Problem 5b (1 pt)

Now, implement the Feral Hogs rule. When `play` is called **and** its `feral_hogs` argument is `True`, then this rule should be imposed. If `feral_hogs` is `False`, this rule should be ignored. (That way, test cases for 5a will still pass after you solve 5b.)

```python
ef play(strategy0, strategy1, score0=0, score1=0, dice=six_sided,
         goal=GOAL_SCORE, say=silence, feral_hogs=True):
    """Simulate a game and return the final scores of both players, with Player
    0's score first, and Player 1's score second.

    A strategy is a function that takes two total scores as arguments (the
    current player's score, and the opponent's score), and returns a number of
    dice that the current player will roll this turn.

    strategy0:  The strategy function for Player 0, who plays first.
    strategy1:  The strategy function for Player 1, who plays second.
    score0:     Starting score for Player 0
    score1:     Starting score for Player 1
    dice:       A function of zero arguments that simulates a dice roll.
    goal:       The game ends and someone wins when this score is reached.
    say:        The commentary function to call at the end of the first turn.
    feral_hogs: A boolean indicating whether the feral hogs rule should be active.
    """
    who = 0  # Who is about to take a turn, 0 (first) or 1 (second)
    # BEGIN PROBLEM 5
    "*** YOUR CODE HERE ***"
    if feral_hogs == False:
        while score0 < goal and score1 < goal:
            if who == 0:
                score0 += take_turn(strategy0(score0, score1), score1, dice)
                if is_swap(score0, score1):
                    score0, score1 = score1, score0
            else:
                score1 += take_turn(strategy1(score1, score0), score0, dice)
                if is_swap(score1, score0):
                    score0, score1 = score1, score0
            who = other(who)
    # END PROBLEM 5
    # (note that the indentation for the problem 6 prompt (***YOUR CODE HERE***) might be misleading)
    # BEGIN PROBLEM 6
    # "*** YOUR CODE HERE ***"
    else:
        last0, last1 = 0, 0
        while score0 < goal and score1 < goal:
            if who == 0:
                dice_num = strategy0(score0, score1) 
                score_now = take_turn(dice_num, score1, dice) 
                score0 += score_now
                if abs(dice_num - last0) == 2:
                    score0 += 3
                last0 = score_now

                if is_swap(score0, score1):
                    score0, score1 = score1, score0
            else:
                dice_num = strategy1(score1, score0) 
                score_now = take_turn(dice_num, score0, dice) 
                score1 += score_now
                if abs(dice_num - last1) == 2:
                    score1 += 3
                last1 = score_now

                if is_swap(score1, score0):
                    score0, score1 = score1, score0
            who = other(who)
    # END PROBLEM 6

    return score0, score1
```

## Phase 2: Commentary

In the second phase, you will implement commentary functions that print remarks about the game after each turn, such as, `"22 points! That's the biggest gain yet for Player 1."`

A commentary function takes two arguments, Player 0's current score and Player 1's current score. It can print out commentary based on either or both current scores and any other information in its parent environment. Since commentary can differ from turn to turn depending on the current point situation in the game, a commentary function always returns another commentary function to be called on the next turn. The only side effect of a commentary function should be to print.

### Commentary examples

**!!!!! Important**

The function `say_scores` in `hog.py` is an example of a commentary function that simply announces both players' scores. Note that `say_scores` returns itself, meaning that the same commentary function will be called each turn.

```
def say_scores(score0, score1):
    """A commentary function that announces the score for each player."""
    print("Player 0 now has", score0, "and Player 1 now has", score1)
    return say_scores
```

The function `announce_lead_changes` is an example of a higher-order function that returns a commentary function that tracks lead changes. A different commentary function will be called each turn.

```
def announce_lead_changes(last_leader=None):
    """Return a commentary function that announces lead changes.

    >>> f0 = announce_lead_changes()
    >>> f1 = f0(5, 0)
    Player 0 takes the lead by 5
    >>> f2 = f1(5, 12)
    Player 1 takes the lead by 7
    >>> f3 = f2(8, 12)
    >>> f4 = f3(8, 13)
    >>> f5 = f4(15, 13)
    Player 0 takes the lead by 2
    """
    def say(score0, score1):
        if score0 > score1:
            leader = 0
        elif score1 > score0:
            leader = 1
        else:
            leader = None
        if leader != None and leader != last_leader:
            print('Player', leader, 'takes the lead by', abs(score0 - score1))
        return announce_lead_changes(leader)
    return say
```

You should also understand the function `both`, which takes two commentary functions (`f` and `g`) and returns a *new* commentary function. This returned commentary function returns *another* commentary function which calls the functions returned by calling `f` and `g`, in that order.

```
def both(f, g):
    """Return a commentary function that says what f says, then what g says.

    NOTE: the following game is not possible under the rules, it's just
    an example for the sake of the doctest

    >>> h0 = both(say_scores, announce_lead_changes())
    >>> h1 = h0(10, 0)
    Player 0 now has 10 and Player 1 now has 0
    Player 0 takes the lead by 10
    >>> h2 = h1(10, 6)
    Player 0 now has 10 and Player 1 now has 6
    >>> h3 = h2(6, 17)
    Player 0 now has 6 and Player 1 now has 17
    Player 1 takes the lead by 11
    """
    def say(score0, score1):
        return both(f(score0, score1), g(score0, score1))
    return say
```

### Problem 6 (2 pt)

Update your `play` function so that a commentary function is called at the end of each turn. The return value of calling a commentary function gives you the commentary function to call on the next turn.

For example, `say(score0, score1)` should be called at the end of the first turn. Its return value (another commentary function) should be called at the end of the second turn. Each consecutive turn, call the function that was returned by the call to the previous turn's commentary function.

```python 
say = say(score0, score1)
```

### Problem 7 (3 pt)

Implement the `announce_highest` function, which is a higher-order function that returns a commentary function. This commentary function announces whenever a particular player gains more points in a turn than ever before. E.g., `announce_highest(1)` and its return value ignore Player 0 entirely and just print information about Player 1. To compute the gain, it must compare the score from last turn to the score from this turn for the player of interest, which is designated by the `who` argument. This function must also keep track of the highest gain for the player so far.

The way in which `announce_highest` announces is very specific, and your implementation should match the doctests provided. Don't worry about singular versus plural when announcing point gains; you should simply use "point(s)" for both cases.

```python 
def announce_highest(who, last_score=0, running_high=0):
    """Return a commentary function that announces when WHO's score
    increases by more than ever before in the game.

    NOTE: the following game is not possible under the rules, it's just
    an example for the sake of the doctest

    >>> f0 = announce_highest(1) # Only announce Player 1 score gains
    >>> f1 = f0(12, 0)
    >>> f2 = f1(12, 11)
    11 point(s)! That's the biggest gain yet for Player 1
    >>> f3 = f2(20, 11)
    >>> f4 = f3(13, 20)
    >>> f5 = f4(20, 35)
    15 point(s)! That's the biggest gain yet for Player 1
    >>> f6 = f5(20, 47) # Player 1 gets 12 points; not enough for a new high
    >>> f7 = f6(21, 47)
    >>> f8 = f7(21, 77)
    30 point(s)! That's the biggest gain yet for Player 1
    >>> f9 = f8(77, 22) # Swap!
    >>> f10 = f9(33, 77) # Swap!
    55 point(s)! That's the biggest gain yet for Player 1
    """
    assert who == 0 or who == 1, 'The who argument should indicate a player.'
    # BEGIN PROBLEM 7
    "*** YOUR CODE HERE ***"
    def say(score0, score1):
        score = score1 if who else score0
        delta = score - last_score
        if delta > running_high:
            print(delta, "point(s)! That's the biggest gain yet for Player",
             who)
        return announce_highest(who, score, max(delta, running_high))
    return say
    # END PROBLEM 7
```

## Phase 3: Strategies

In the third phase, you will experiment with ways to improve upon the basic strategy of always rolling a fixed number of dice. First, you need to develop some tools to evaluate strategies.

### Problem 8 (2 pt)

Implement the `make_averaged` function, which is a higher-order function that takes a function `original_function` as an argument. It returns another function that takes the same number of arguments as `original_function` (the function originally passed into `make_averaged`). This returned function differs from the input function in that it returns the average value of repeatedly calling `original_function` on the same arguments. This function should call `original_function` a total of `trials_count` times and return the average of the results.

To implement this function, you need a new piece of Python syntax! You must write a function that accepts an arbitrary number of arguments, then calls another function using exactly those arguments. Here's how it works.

Instead of listing formal parameters for a function, you can write `*args`. To call another function using exactly those arguments, you call it again with `*args`. For example,

```
>>> def printed(f):
...     def print_and_return(*args):
...         result = f(*args)
...         print('Result:', result)
...         return result
...     return print_and_return
>>> printed_pow = printed(pow)
>>> printed_pow(2, 8)
Result: 256
256
>>> printed_abs = printed(abs)
>>> printed_abs(-10)
Result: 10
10
```

Read the docstring for `make_averaged` carefully to understand how it is meant to work.

```python
def make_averaged(original_function, trials_count=1000):
    """Return a function that returns the average value of ORIGINAL_FUNCTION when called.

    To implement this function, you will have to use *args syntax, a new Python
    feature introduced in this project.  See the project description.

    >>> dice = make_test_dice(4, 2, 5, 1)
    >>> averaged_dice = make_averaged(dice, 1000)
    >>> averaged_dice()
    3.0
    """
    # BEGIN PROBLEM 8
    "*** YOUR CODE HERE ***"
    def calc(*args):
        i, sum = 0, 0
        while i < trials_count:
            sum, i = sum + original_function(*args), i+1
        return sum / trials_count
    return calc
    # END PROBLEM 8
```

### Problem 9 (2 pt)

Implement the `max_scoring_num_rolls` function, which runs an experiment to determine the number of rolls (from 1 to 10) that gives the maximum average score for a turn. Your implementation should use `make_averaged` and `roll_dice`.

If two numbers of rolls are tied for the maximum average score, return the lower number. For example, if both 3 and 6 achieve a maximum average score, return 3.

Before writing any code, unlock the tests to verify your understanding of the question.

```
python3 ok -q 09 -u
```

Once you are done unlocking, begin implementing your solution. You can check your correctness with:

```
python3 ok -q 09
```

To run this experiment on randomized dice, call `run_experiments` using the `-r` option:

```
python3 hog.py -r
```

**Running experiments** For the remainder of this project, you can change the implementation of `run_experiments` as you wish. By calling `average_win_rate`, you can evaluate various Hog strategies. For example, change the first `if False:` to `if True:` in order to evaluate `always_roll(8)` against the baseline strategy of `always_roll(6)`.

Some of the experiments may take up to a minute to run. You can always reduce the number of trials in your call to `make_averaged` to speed up experiments.

```python
def max_scoring_num_rolls(dice=six_sided, trials_count=1000):
    """Return the number of dice (1 to 10) that gives the highest average turn
    score by calling roll_dice with the provided DICE over TRIALS_COUNT times.
    Assume that the dice always return positive outcomes.

    >>> dice = make_test_dice(1, 6)
    >>> max_scoring_num_rolls(dice)
    1
    """
    # BEGIN PROBLEM 9
    id, max_score = -1, -1
    f = make_averaged(roll_dice, trials_count)
    for i in range(1, 11):
        average_score = f(i, dice)
        if average_score > max_score:
            id, max_score = i, average_score
    return id
    "*** YOUR CODE HERE ***"
    # END PROBLEM 9
```

### Problem 10 (1 pt)

A strategy can try to take advantage of the *Free Bacon* rule by rolling 0 when it is most beneficial to do so. Implement `bacon_strategy`, which returns 0 whenever rolling 0 would give **at least** `cutoff` points and returns `num_rolls` otherwise.

> Note it is impossible for strategies to know what number of points the current player earned on the previous turn, and thus we cannot predict feral hogs. For strategies, we do not take into account bonuses from feral hogs to calculate bonuses against the cutoff or whether a swap will occur

```python
def bacon_strategy(score, opponent_score, cutoff=8, num_rolls=6):
    """This strategy rolls 0 dice if that gives at least CUTOFF points, and
    rolls NUM_ROLLS otherwise.
    """
    # BEGIN PROBLEM 10
    return 0 if free_bacon(opponent_score) >= cutoff else num_rolls 
    # END PROBLEM 10
```

### Problem 11 (2 pt)

A strategy can also take advantage of the *Swine Swap* rule. The swap strategy always rolls 0 if doing so triggers a beneficial swap and always avoids rolling 0 if doing so triggers a detrimental swap. In other cases, it rolls 0 if rolling 0 would give **at least** `cutoff` points. Otherwise, the strategy rolls `num_rolls`.

> Note it is impossible for strategies to know what number of points the current player earned on the previous turn, and thus we cannot predict feral hogs. For strategies, we do not take into account bonuses from feral hogs to calculate bonuses against the cutoff or whether a swap will occur
>
> Hint: a tie is technically a "swap" (e.g., 43 being swapped with 43), but is considered neither detrimental nor beneficial for the purposes of this problem.

Before writing any code, unlock the tests to verify your understanding of the question.

```
python3 ok -q 11 -u
```

Once you are done unlocking, begin implementing your solution. You can check your correctness with:

```
python3 ok -q 11
```

Once you have implemented this strategy, update `run_experiments` to evaluate your new strategy against the baseline. You should find that it gives a significant edge over `always_roll(4)`.

```python
def swap_strategy(score, opponent_score, cutoff=8, num_rolls=6):
    """This strategy rolls 0 dice when it triggers a beneficial swap. It also
    rolls 0 dice if it gives at least CUTOFF points and does not trigger a
    non-beneficial swap. Otherwise, it rolls NUM_ROLLS.
    """
    # BEGIN PROBLEM 11
    score_bacon = score + free_bacon(opponent_score) 
    if is_swap(score_bacon, opponent_score) and score_bacon < opponent_score:
        return 0
    elif is_swap(score_bacon, opponent_score) and score_bacon > opponent_score:
        return num_rolls
    else:
        return bacon_strategy(score, opponent_score, cutoff, num_rolls)
    # END PROBLEM 11
```

### Optional: Problem 12 (0 pt)

Implement `final_strategy`, which combines these ideas and any other ideas you have to achieve a high win rate against the `always_roll(4)` strategy. Some suggestions:

- `swap_strategy` is a good default strategy to start with.
- There's no point in scoring more than 100. Check whether you can win by rolling 0, 1 or 2 dice. If you are in the lead, you might take fewer risks.
- Try to force a beneficial swap rolling more than 0 dice.
- Choose the `num_rolls` and `cutoff` arguments carefully.
- Take the action that is most likely to win the game.

