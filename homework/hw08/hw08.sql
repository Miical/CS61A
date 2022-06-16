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


-- The size of each dog
CREATE TABLE size_of_dogs AS
  SELECT  dogs.name AS "name", sizes.size AS "size" FROM dogs, sizes
    WHERE sizes.min < dogs.height and dogs.height <= sizes.max;


-- All dogs with parents ordered by decreasing height of their parent
CREATE TABLE by_parent_height AS
  SELECT parents.child as "name" FROM parents, dogs WHERE dogs.name == parents.parent ORDER BY -dogs.height;


-- Filling out this helper table is optional
CREATE TABLE siblings AS
  SELECT a.child AS "first", b.child AS "second" FROM parents AS a, parents AS b 
    WHERE a.child < b.child and a.parent == b.parent;

-- Sentences about siblings that are the same size
CREATE TABLE sentences AS 
  SELECT siblings.first || " and " || siblings.second || " are " || a.size || " siblings"
    FROM siblings, size_of_dogs AS a, size_of_dogs AS b 
    WHERE a.name == siblings.first and b.name == siblings.second and a.size == b.size;


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
