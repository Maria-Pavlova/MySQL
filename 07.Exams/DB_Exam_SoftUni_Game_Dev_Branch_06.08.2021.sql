-- CREATE DATABASE `SoftUni Game Dev Branch`;
-- USE `SoftUni Game Dev Branch`;

CREATE TABLE `addresses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL
);

CREATE TABLE `categories`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(10) NOT NULL
);

CREATE TABLE `offices`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`workspace_capacity` INT NOT NULL,
`website` VARCHAR(50),
`address_id` INT NOT NULL,
CONSTRAINT fk_offices_addresses
FOREIGN KEY (`address_id`)
REFERENCES `addresses`(`id`)
);

CREATE TABLE `employees`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(30) NOT NULL,
`last_name` VARCHAR(30) NOT NULL,
`age` INT NOT NULL,
`salary` DECIMAL(10, 2) NOT NULL,
`job_title` VARCHAR(20) NOT NULL,
`happiness_level` CHAR(1) NOT NULL
);

CREATE TABLE `teams`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL,
`office_id` INT NOT NULL,
`leader_id` INT NOT NULL UNIQUE,
CONSTRAINT fk_teams_offices
FOREIGN KEY (`office_id`)
REFERENCES `offices`(`id`),
CONSTRAINT fk_teams_employees
FOREIGN KEY (`leader_id`)
REFERENCES `employees`(`id`)
);

CREATE TABLE `games`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL UNIQUE,
`description` TEXT,
`rating` FLOAT NOT NULL DEFAULT 5.5,
`budget` DECIMAL(10, 2) NOT NULL,
`release_date` DATE,
`team_id` INT NOT NULL,
CONSTRAINT fk_games_teams
FOREIGN KEY (`team_id`)
REFERENCES `teams`(`id`)
);

CREATE TABLE `games_categories`(
`game_id` INT NOT NULL,
`category_id` INT NOT NULL,
CONSTRAINT fk_games_categories_to_games
FOREIGN KEY (`game_id`)
REFERENCES `games`(`id`),
CONSTRAINT fk_games_categories_to_categories
FOREIGN KEY (`category_id`)
REFERENCES `categories`(`id`),
CONSTRAINT pk
PRIMARY KEY(`game_id`, `category_id`)
);

INSERT INTO `games`(`name`, `rating`, `budget`, `team_id`)
SELECT 
	SUBSTRING(LOWER(reverse(t.name)), 1, char_length(t.name) - 1),
	t.id, 
    t.leader_id * 1000, 
    t.id
FROM `teams` AS t
WHERE t.id BETWEEN 1 AND 9;

UPDATE employees e
JOIN teams AS t ON t.leader_id = e.id
SET salary = salary + 1000
WHERE salary < 5000 AND age < 40;

DELETE g FROM games g
LEFT JOIN games_categories gc ON g.id = gc.game_id
WHERE release_date IS NULL AND gc.game_id IS NULL;

SELECT e.first_name, e.last_name, e.age, e.salary, e.happiness_level
FROM employees AS e
ORDER BY e.salary, e.id;

SELECT t.name AS 'team_name',
	   a.name AS 'address_name',
       char_length(a.name) AS 'count_of_characters'
FROM teams AS t
JOIN offices AS o ON o.id = t.office_id
JOIN addresses AS a ON a.id = o.address_id
WHERE o.website IS NOT NULL
ORDER BY `team_name`, `address_name`;

SELECT c.name, 
		COUNT(g.id) AS 'games_count', 
        ROUND( AVG(g.budget), 2),
        MAX(g.rating) AS 'max_rating'
FROM categories AS c
JOIN games_categories AS gc ON c.id = gc.category_id
JOIN games AS g ON gc.game_id = g.id
GROUP BY c.name
HAVING `max_rating` >= 9.5
ORDER BY `games_count` DESC, c.name;

SELECT g.name,
	g.release_date,
	CONCAT(LEFT(g.description, 10), '...') AS 'summary',
    CASE
		WHEN MONTH(g.release_date) <= 3 THEN 'Q1'
		WHEN MONTH(g.release_date) <= 6 THEN 'Q2'
		WHEN MONTH(g.release_date) <= 9 THEN 'Q3'
        ELSE 'Q4'
        END AS 'quarter',
        t.name AS 'team_name'
FROM games AS g
JOIN teams AS t ON t.id = g.team_id
   WHERE YEAR(g.release_date) = 2022 
	  AND MONTH(g.release_date) % 2 = 0
      AND RIGHT(g.name, 1) LIKE 2
ORDER BY `quarter`;

DELIMITER $$
CREATE FUNCTION udf_game_info_by_name (game_name VARCHAR (20)) 
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN

DECLARE info VARCHAR(255);
DECLARE team_name VARCHAR (40);
DECLARE address_text VARCHAR (50);
	
	SET team_name := (SELECT t.`name`
        	FROM teams AS t 
        	JOIN games AS g 
        	ON g.team_id = t.id 
        	WHERE g.`name` = game_name);
	
  	SET address_text := (SELECT a.`name`
        	FROM addresses AS a
        	JOIN offices AS o
        	ON a.id = o.address_id
        	JOIN teams AS t
        	ON o.id = t.office_id
        	WHERE t.`name` = team_name);
    
  	SET info := concat_ws(' ', 'The', game_name, 'is developed by a', team_name, 'in an office with an address', address_text);
  	RETURN info;
END
$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE udp_update_budget(min_game_rating FLOAT)
BEGIN
UPDATE games AS g
LEFT JOIN games_categories AS gc ON gc.game_id = g.id
SET g.budget = g.budget + 100000,
	g.release_date = DATE_SUB(g.release_date, INTERVAL 1 YEAR)
WHERE g.rating > min_game_rating
	AND gc.game_id IS NULL
    AND g.release_date IS NOT NULL;
END
$$

	




