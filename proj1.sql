-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthYear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthYear
  FROM people
  WHERE nameFirst LIKE '% %'
  ORDER BY nameFirst ASC, nameLast ASC
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthYear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthYear
  ORDER BY birthYear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthYear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthYear
  HAVING AVG(height) > 70
  ORDER BY birthYear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT nameFirst, nameLast, people.playerID, yearid
  FROM people INNER JOIN halloffame
  ON people.playerID = halloffame.playerID
  WHERE inducted = 'Y'
  ORDER BY yearid DESC, people.playerID ASC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT nameFirst, nameLast, people.playerID, schools.schoolID, yearid
  FROM people 
  INNER JOIN halloffame
  ON people.playerID = halloffame.playerID
  INNER JOIN collegeplaying
  ON people.playerID = collegeplaying.playerid
  INNER JOIN schools
  ON collegeplaying.schoolID = schools.schoolID
  WHERE schoolState = 'CA' and inducted = 'Y'
  ORDER BY yearid DESC, schools.schoolID ASC, people.playerID ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT people.playerID, nameFirst, nameLast, collegeplaying.schoolID
  FROM people 
  INNER JOIN halloffame
  ON people.playerID = halloffame.playerID
  LEFT JOIN collegeplaying
  ON people.playerID = collegeplaying.playerid
  WHERE inducted = 'Y'
  ORDER BY people.playerID DESC, collegeplaying.schoolID ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerID, p.nameFirst, p.nameLast, b.yearID, CAST((H + H2B + 2 * H3B + 3 * HR) AS float) / CAST(AB AS float) as slg
  FROM people AS p
  INNER JOIN batting AS b
  ON p.playerID = b.playerID
  WHERE AB > 50 AND slg IN (
    SELECT DISTINCT CAST((H + H2B + 2 * H3B + 3 * HR) AS float) / CAST(AB AS float) as max_slg
    FROM batting
    WHERE AB > 50
    ORDER BY max_slg DESC
    LIMIT 10
  )
  ORDER BY slg DESC, b.yearID ASC, p.playerID ASC
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerID, p.nameFirst, p.nameLast, CAST(SUM((H + H2B + 2 * H3B + 3 * HR)) AS float) / CAST(SUM(AB) AS float) as lslg
  FROM people AS p
  INNER JOIN batting AS b
  ON p.playerID = b.playerID
  GROUP BY p.playerID, p.nameFirst, p.nameLast 
  HAVING SUM(AB) > 50 AND lslg IN (
    SELECT DISTINCT CAST(SUM((H + H2B + 2 * H3B + 3 * HR)) AS float) / CAST(SUM(AB) AS float) lslg
    FROM batting
    GROUP BY playerID
    HAVING SUM(AB) > 50
    ORDER BY lslg DESC
    LIMIT 10
  )
  ORDER BY lslg DESC, p.playerID ASC
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT p.nameFirst, p.nameLast, CAST(SUM((H + H2B + 2 * H3B + 3 * HR)) AS float) / CAST(SUM(AB) AS float) as lslg
  FROM people AS p
  INNER JOIN batting AS b
  ON p.playerID = b.playerID
  WHERE nameFirst <> 'Willie' and nameLast <> 'Mays'
  GROUP BY p.playerID, p.nameFirst, p.nameLast 
  HAVING SUM(AB) > 50 AND lslg > (
    SELECT CAST(SUM((H + H2B + 2 * H3B + 3 * HR)) AS float) / CAST(SUM(AB) AS float) lslg
    FROM people AS p
    INNER JOIN batting AS b
    ON p.playerID = b.playerID
    WHERE nameFirst = 'Willie' and nameLast = 'Mays'
  )
  ORDER BY lslg DESC, p.playerID ASC
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearID, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries
  GROUP BY yearID
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH X AS (SELECT MIN(salary) as min, MAX(salary) as max
             FROM salaries WHERE yearid = '2016'
  ), Y AS (SELECT binid, 
                  binid*(X.max-X.min)/10.0 + X.min AS low,
                  (binid+1)*(X.max-X.min)/10.0 + X.min AS high
           FROM binids, X)
  SELECT binid, low, high, COUNT(*) 
  FROM Y INNER JOIN salaries AS s 
         ON s.salary >= Y.low 
            AND (s.salary < Y.high OR binid = 9 AND s.salary <= Y.high)
            AND yearid = '2016'
  GROUP BY binid, low, high
  ORDER BY binid ASC
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH X AS (
    SELECT yearid, MIN(salary) as min, MAX(salary) as max, AVG(salary) as avg
    FROM salaries
    GROUP BY yearid)

  SELECT x1.yearid, 
         x1.min - x2.min AS mindiff, 
	 x1.max - x2.max AS maxdiff, 
	 x1.avg - x2.avg as avgdiff
  FROM X x1 INNER JOIN X x2
  ON x2.yearid = x1.yearid - 1
  ORDER BY x1.yearid ASC
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  WITH max_salaries AS (
    SELECT yearid, MAX(salary) as max
    FROM salaries
    WHERE yearid = 2000 or yearid = 2001
    GROUP BY yearid
  )

  SELECT people.playerID, nameFirst, nameLast, salary, salaries.yearid
  FROM people
  INNER JOIN salaries
  on people.playerID = salaries.playerID
  INNER JOIN max_salaries 
  ON salaries.yearID = max_salaries.yearid
  AND salary = max_salaries.max 
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamid, MAX(salary) - MIN(salary) as diffAvg
  FROM salaries AS s 
  INNER JOIN allstarfull as a
  ON s.playerid = a.playerid and s.yearid = a.yearid
  WHERE s.yearid = 2016
  GROUP by a.teamid
;

