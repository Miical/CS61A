.read data.sql


CREATE TABLE bluedog AS
  SELECT color, pet from students where color = "blue" and pet = "dog";

CREATE TABLE bluedog_songs AS
  SELECT color, pet, song from students where color = "blue" and pet = "dog";


CREATE TABLE matchmaker AS
  SELECT a.pet, a.song, a.color, b.color from students as a, students as b 
    where a.pet == b.pet and a.song == b.song and a.time < b.time;


CREATE TABLE sevens AS
  SELECT students.seven from students, numbers where students.time == numbers.time 
    and students.number == 7 and numbers.'7' == "True";


CREATE TABLE favpets AS
  SELECT pet, count(*) as count from students group by pet order by count DESC limit 10;

CREATE TABLE dog AS
  SELECT pet, count(*) from students where pet == "dog";


CREATE TABLE bluedog_agg AS
  SELECT song, count(*) as count from bluedog_songs group by song order by count DESC;


CREATE TABLE instructor_obedience AS
  SELECT seven, instructor, count(*) from students where seven = '7' group by instructor;

