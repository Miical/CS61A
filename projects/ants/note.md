### Problem 1 (1 pt)

Before writing any code, read the instructions and test your understanding of the problem:

```
python3 ok -q 01 -u
```

First, add food costs and implement harvesters. Currently, there is no cost for deploying any type of `Ant`, and so there is no challenge to the game. You'll notice that `Ant` has a base `food_cost` of zero. Override this value in each of the subclasses listed below with the correct costs.

| **Class**      | **Food Cost** | **Armor** |
| -------------- | ------------- | --------- |
| `HarvesterAnt` | 2             | 1         |
| `ThrowerAnt`   | 3             | 1         |

Now that deploying `Ant`s cost food, we need to be able to gather more food! To fix this issue, implement the `HarvesterAnt` class. A `HarvesterAnt` is a type of `Ant` that adds one food to the `gamestate.food` total as its `action`.

```python
 def action(self, gamestate):
        """Produce 1 additional food for the colony.

        gamestate -- The GameState, used to access game state information.
        """
        # BEGIN Problem 1
        gamestate.food += 1 
        # END Problem 1
```

### Problem 2 (3 pt)

Before writing any code, read the instructions and test your understanding of the problem:

```
python3 ok -q 02 -u
```

Complete the `Place` constructor by adding code that tracks entrances. Right now, a `Place` keeps track only of its `exit`. We would like a `Place` to keep track of its entrance as well. A `Place` needs to track only one `entrance`. Tracking entrances will be useful when an `Ant` needs to see what `Bee`s are in front of it in the tunnel.

However, simply passing an entrance to a `Place` constructor will be problematic; we would need to have both the exit and the entrance before creating a `Place`! (It's a [chicken or the egg](https://en.wikipedia.org/wiki/Chicken_or_the_egg) problem.) To get around this problem, we will keep track of entrances in the following way instead. The `Place` constructor should specify that:

- A newly created `Place` always starts with its `entrance` as `None`.
- If the `Place` has an `exit`, then the `exit`'s `entrance` is set to that `Place`.

> *Hint:* Remember that when the `__init__` method is called, the first parameter, `self`, is bound to the newly created object

> *Hint:* Try drawing out two `Place`s next to each other if things get confusing. In the GUI, a place's `entrance` is to its right while the `exit` is to its left.

```python
    def __init__(self, name, exit=None):
        """Create a Place with the given NAME and EXIT.

        name -- A string; the name of this Place.
        exit -- The Place reached by exiting this Place (may be None).
        """
        self.name = name
        self.exit = exit
        self.bees = []        # A list of Bees
        self.ant = None       # An Ant
        self.entrance = None  # A Place
        # Phase 1: Add an entrance to the exit
        # BEGIN Problem 2
        if exit:
            exit.entrance = self
        # END Problem 2
```

### Problem 3 (3 pt)

Before writing any code, read the instructions and test your understanding of the problem:

```
python3 ok -q 03 -u
```

In order for a `ThrowerAnt` to attack, it must know which bee it should hit. The provided implementation of the `nearest_bee` method in the `ThrowerAnt` class only allows them to hit bees in the same `Place`. Your job is to fix it so that a `ThrowerAnt` will `throw_at` the nearest bee in front of it that is not still in the `Hive`.

The `nearest_bee` method returns a random `Bee` from the nearest place that contains bees. Places are inspected in order by following their `entrance` attributes.

- Start from the current `Place` of the `ThrowerAnt`.
- For each place, return a random bee if there is any, or consider the next place that is stored as the current place's `entrance`.
- If there is no bee to attack, return `None`.

> *Hint*: The `rANTdom_else_none` function provided in `ants.py` returns a random element of a sequence or `None` if the sequence is empty.
>
> *Hint*: Having trouble visualizing the test cases? Try drawing them out on paper! The example diagram provided in [Game Layout](https://inst.eecs.berkeley.edu/~cs61a/su20//proj/ants/#game-layout) shows the first test case for this problem.

```python 
    def nearest_bee(self, beehive):
        """Return the nearest Bee in a Place that is not the HIVE, connected to
        the ThrowerAnt's Place by following entrances.

        This method returns None if there is no such Bee (or none in range).
        """
        # BEGIN Problem 3 and 4
        present_place = self.place
        while present_place.name != 'Hive' and not len(present_place.bees):
            present_place = present_place.entrance
        if present_place.name != 'Hive':
            return rANTdom_else_none(present_place.bees) # REPLACE THIS LINE
        else:
            return None
        # END Problem 3 and 4
```

## Phase 2: Ants!

Now that you've implemented basic gameplay with two types of `Ant`s, let's add some flavor to the ways ants can attack bees. In this phase, you'll be implementing several different `Ant`s with different offensive capabilities.

After you implement each `Ant` subclass in this section, you'll need to set its `implemented` attribute to `True` so that that type of ant will show up in the GUI. Feel free to try out the game with each new ant to test the functionality!

With your Phase 2 ants, try `python3 ants_gui.py -d easy` to play against a full swarm of bees in a multi-tunnel layout and try `-d normal`, `-d hard`, or `-d extra-hard` if you want a real challenge! If the bees are too numerous to vanquish, you might need to create some new ants.

### Problem 4 (2 pt)

Before writing any code, read the instructions and test your understanding of the problem:

```
python3 ok -q 04 -u
```

The `ThrowerAnt` is a great offensive unit, but it'd be nice to have a cheaper unit that can throw. Implement two subclasses of `ThrowerAnt` that are less costly but have constraints on the distance they can throw:

- The `LongThrower` can only `throw_at` a `Bee` that is found after following at least 5 `entrance` transitions. It cannot hit `Bee`s that are in the same `Place` as it or the first 4 `Place`s in front of it. If there are two `Bees`, one too close to the `LongThrower` and the other within its range, the `LongThrower` should throw past the closer `Bee`, instead targeting the farther one, which is within its range.
- The `ShortThrower` can only `throw_at` a `Bee` that is found after following at most 3 `entrance` transitions. It cannot throw at any ants further than 3 `Place`s in front of it.

Neither of these specialized throwers can `throw_at` a `Bee` that is exactly 4 `Place`s away.

| **Class**      | **Food Cost** | **Armor** |
| -------------- | ------------- | --------- |
| `ShortThrower` | 2             | 1         |
| `LongThrower`  | 2             | 1         |

A good way to approach the implementation to `ShortThrower` and `LongThrower` is to have it inherit the `nearest_bee` method from the base `ThrowerAnt` class. The logic of choosing which bee a thrower ant will attack is essentially the same, except the `ShortThrower` and `LongThrower` ants have maximum and minimum ranges, respectively.

To implement these behaviors, you will need to modify the `nearest_bee` method to reference `min_range` and `max_range` attributes, and only return a bee that is in range.

Make sure to give these `min_range` and `max_range` sensible defaults in `ThrowerAnt` that do not change its behavior. Then, implement the subclasses `LongThrower` and `ShortThrower` with appropriately constrained ranges and correct food costs.

> *Hint:* `float('inf')` returns an infinite positive value represented as a float that can be compared with other numbers.

Don't forget to set the `implemented` class attribute of `LongThrower` and `ShortThrower` to `True`.

> Note! Please make sure your attributes are called `max_range` and `min_range` rather than `maximum_range` and `minimum_range` or something. The tests directly reference this variable name.

```python 

class ThrowerAnt(Ant):
    """ThrowerAnt throws a leaf each turn at the nearest Bee in its range."""

    name = 'Thrower'
    implemented = True
    damage = 1
    # ADD/OVERRIDE CLASS ATTRIBUTES HERE
    def __init__(self):
        Ant.__init__(self)
        self.min_range = 0
        self.max_range = float('inf')

    def nearest_bee(self, beehive):
        """Return the nearest Bee in a Place that is not the HIVE, connected to
        the ThrowerAnt's Place by following entrances.

        This method returns None if there is no such Bee (or none in range).
        """
        # BEGIN Problem 3 and 4
        p, dist = self.place, 0
        while dist <= self.max_range and p.name!= 'Hive':
            if len(p.bees) and dist >= self.min_range:
                return rANTdom_else_none(p.bees)
            else:
                p, dist = p.entrance, dist + 1
        return None
        # END Problem 3 and 4

    def throw_at(self, target):
        """Throw a leaf at the TARGET Bee, reducing its armor."""
        if target is not None:
            target.reduce_armor(self.damage)

    def action(self, gamestate):
        """Throw a leaf at the nearest Bee in range."""
        self.throw_at(self.nearest_bee(gamestate.beehive))

def rANTdom_else_none(s):
    """Return a random element of sequence S, or return None if S is empty."""
    assert isinstance(s, list), "rANTdom_else_none's argument should be a list but was a %s" % type(s).__name__
    if s:
        return random.choice(s)

##############
# Extensions #
##############

class ShortThrower(ThrowerAnt):
    """A ThrowerAnt that only throws leaves at Bees at most 3 places away."""

    name = 'Short'
    food_cost = 2

    def __init__(self):
        ThrowerAnt.__init__(self)
        self.min_range = 0
        self.max_range = 3
    # BEGIN Problem 4
    implemented = True   # Change to True to view in the GUI
    # END Problem 4

class LongThrower(ThrowerAnt):
    """A ThrowerAnt that only throws leaves at Bees at least 5 places away."""

    name = 'Long'
    food_cost = 2

    def __init__(self):
        ThrowerAnt.__init__(self)
        self.min_range = 5
        self.max_range = float('inf')
    # BEGIN Problem 4
    implemented = True   # Change to True to view in the GUI
    # END Problem 4
```

### Problem 5 (3 pt)

Before writing any code, read the instructions and test your understanding of the problem:

```
python3 ok -q 05 -u
```

Implement the `FireAnt`, which does damage when it receives damage. Specifically, if it is damaged by `amount` armor units, it does a damage of `amount` to all bees in its place (this is called *reflected damage*).

If it dies, it does an additional amount of damage, which is specified by its `damage` attribute (by default 3).

To implement this, we have to override the `FireAnt`'s `reduce_armor` method. Normally, `Insect.reduce_armor` will decrement the insect's `armor` by the given `amount` and remove the insect from its place if `armor` reaches zero or lower. However, `FireAnt` also does damage to all the bees in its place when it receives damage, with an additional damange specified by its `damage` attribute when its armor drops to 0, before being removed from its `place`.

| **Class** | **Food Cost** | **Armor** |
| --------- | ------------- | --------- |
| `FireAnt` | 5             | 3         |

> *Hint:* To damage the `FireAnt`, call the `reduce_armor` method inherited from `Ant`. Do *not* call `self.reduce_armor`, or you'll end up stuck in a recursive loop. (Can you see why?)
>
> *Hint:* To damage a `Bee`, call the `reduce_armor` method inherited from `Insect`.
>
> *Hint:* Damaging a bee may cause it to be removed from its place. If you iterate over a list, but change the contents of that list at the same time, you [may not visit all the elements](https://docs.python.org/3/tutorial/controlflow.html#for-statements). This can be prevented by making a copy of the list. You can either use a list slice, or use the built-in `list` function.
>
> ```
>  >>> lst = [1,2,3,4]
>  >>> lst[:]
>  [1, 2, 3, 4]
>  >>> list(lst)
>  [1, 2, 3, 4]
>  >>> lst[:] is not lst and list(lst) is not lst
>  True
> ```

Once you've finished implementing the `FireAnt`, give it a class attribute `implemented` with the value `True`.

> Note, even though you are overriding the `Insect.reduce_armor` function, you can still use it in your implementation by calling it directly (rather than via `self`). Note that this is not recursion (why?)

```python
    def reduce_armor(self, amount):
        """Reduce armor by AMOUNT, and remove the FireAnt from its place if it
        has no armor remaining.

        Make sure to damage each bee in the current place, and apply the bonus
        if the fire ant dies.
        """
        # BEGIN Problem 5
        for bee in self.place.bees:
            bee.reduce_armor(amount)
        if self.armor <= amount:
            for bee in self.place.bees[:]:
                bee.reduce_armor(self.damage)
        Ant.reduce_armor(self, amount)
        # END Problem 5
```

### Problem 6 (2 pt)

Before writing any code, read the instructions and test your understanding of the problem:

```
python3 ok -q 06 -u
```

Implement the `HungryAnt`, which will select a random `Bee` from its `place` and eat it whole. After eating a `Bee`, it must spend 3 turns digesting before eating again. If there is no bee available to eat, it will do nothing.

| **Class**   | **Food Cost** | **Armor** |
| ----------- | ------------- | --------- |
| `HungryAnt` | 4             | 1         |

Give `HungryAnt` a `time_to_digest` class attribute that holds the number of turns that it takes a `HungryAnt` to digest (default to 3). Also, give each `HungryAnt` an instance attribute `digesting` that counts the number of turns it has left to digest (default is 0, since it hasn't eaten anything at the beginning).

Implement the `action` method of the `HungryAnt` to check if it is digesting; if so, decrement its `digesting` counter. Otherwise, eat a random `Bee` in its `place` by reducing the `Bee`'s armor to 0 and restart the `digesting` timer.

```python 
class HungryAnt(Ant):
    """HungryAnt will take three turns to digest a Bee in its place.
    While digesting, the HungryAnt can't eat another Bee.
    """
    name = 'Hungry'
    food_cost = 4
    # OVERRIDE CLASS ATTRIBUTES HERE
    # BEGIN Problem 6
    implemented = True   # Change to True to view in the GUI
    time_to_digest = 3
    # END Problem 6

    def __init__(self, armor=1):
        # BEGIN Problem 6
        self.digesting = 0
        Ant.__init__(self, armor) 
        # END Problem 6

    def eat_bee(self, bee):
        # BEGIN Problem 6
        self.digesting = self.time_to_digest
        bee.reduce_armor(bee.armor)
        # END Problem 6

    def action(self, gamestate):
        # BEGIN Problem 6
        if self.digesting:
            if self.digesting:
                self.digesting -= 1
        else:
            if self.place.bees:
                self.eat_bee(rANTdom_else_none(self.place.bees))
        # END Problem 6
```

### Problem 7 (2 pt)

Before writing any code, read the instructions and test your understanding of the problem:

```
python3 ok -q 07 -u
```

Implement the `NinjaAnt`, which damages all `Bee`s that pass by, but can never be stung.

| **Class**                                                    | **Food Cost** | **Armor** |
| ------------------------------------------------------------ | ------------- | --------- |
| ![img](https://inst.eecs.berkeley.edu/~cs61a/su20/proj/ants/assets/insects/ant_ninja.gif) `NinjaAnt` | 5             | 1         |

A `NinjaAnt` does not block the path of a `Bee` that flies by. To implement this behavior, first modify the `Ant` class to include a new class attribute `blocks_path` that is `True` by default. Set the value of `blocks_path` to `False` in the `NinjaAnt` class.

Second, modify the `Bee`'s method `blocked` to return `False` if either there is no `Ant` in the `Bee`'s `place` or if there is an `Ant`, but its `blocks_path` attribute is `False`. Now `Bee`s will just fly past `NinjaAnt`s.

Finally, we want to make the `NinjaAnt` damage all `Bee`s that fly past. Implement the `action` method in `NinjaAnt` to reduce the armor of all `Bee`s in the same `place` as the `NinjaAnt` by its `damage` attribute. Similar to the `FireAnt`, you must iterate over a list of bees that may change.

> *Hint*: Having trouble visualizing the test cases? Try drawing them out on paper! See the example in [Game Layout](https://inst.eecs.berkeley.edu/~cs61a/su20/proj/ants/#game-layout) for help.

```python
class NinjaAnt(Ant):
    """NinjaAnt does not block the path and damages all bees in its place."""

    name = 'Ninja'
    damage = 1
    food_cost = 5
    # OVERRIDE CLASS ATTRIBUTES HERE
    # BEGIN Problem 7
    blocks_path = False
    implemented = True# Change to True to view in the GUI
    # END Problem 7

    def action(self, gamestate):
        # BEGIN Problem 7
        for bee in self.place.bees[:]:
            bee.reduce_armor(self.damage)
        # END Problem 7

# ----------

    def blocked(self):
        """Return True if this Bee cannot advance to the next Place."""
        # Phase 4: Special handling for NinjaAnt
        # BEGIN Problem 7
        if self.place.ant:
            return self.place.ant.blocks_path
        else:
            return self.place.ant is not None
        # END Problem 7
```

