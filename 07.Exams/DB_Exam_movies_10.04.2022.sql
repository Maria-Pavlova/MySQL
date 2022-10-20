CREATE DATABASE `softuni_imdb`;
USE softuni_imdb;

CREATE TABLE `countries`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL UNIQUE,
`continent` VARCHAR(30) NOT NULL,
`currency` VARCHAR(5) NOT NULL
);


CREATE TABLE `genres`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE `actors`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(50) NOT NULL,
`last_name` VARCHAR(50) NOT NULL,
`birthdate` DATE NOT NULL,
`height` INT,
`awards` INT,
`country_id` INT NOT NULL,
CONSTRAINT fk_actors_countries
FOREIGN KEY (`country_id`)
REFERENCES `countries`(`id`)
);

CREATE TABLE `movies_additional_info`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`rating` DECIMAL(10,2) NOT NULL,
`runtime` INT NOT NULL,
`picture_url` VARCHAR(80) NOT NULL,
`budget` DECIMAL(10,2),
`release_date` DATE NOT NULL,
`has_subtitles` BOOLEAN,
`description` TEXT
);

CREATE TABLE `movies`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`title` VARCHAR(70) NOT NULL UNIQUE,
`country_id` INT NOT NULL,
`movie_info_id` INT NOT NULL UNIQUE,
CONSTRAINT fk_movies_movies_info
FOREIGN KEY (`movie_info_id`)
REFERENCES `movies_additional_info`(`id`),
CONSTRAINT fk_movies_countries
FOREIGN KEY (`country_id`)
REFERENCES `countries`(`id`)
);

CREATE TABLE `movies_actors`(
`movie_id` INT,
`actor_id` INT,
CONSTRAINT fk_movies_actors_to_movies
FOREIGN KEY (`movie_id`)
REFERENCES `movies`(`id`),
CONSTRAINT fk_movies_actors_to_actors
FOREIGN KEY (`actor_id`)
REFERENCES `actors`(`id`)
);



CREATE TABLE `genres_movies`(
`genre_id` INT,
`movie_id` INT,
CONSTRAINT fk_genres_movies_to_movies
FOREIGN KEY (`movie_id`)
REFERENCES `movies`(`id`),
CONSTRAINT fk_genres_movies_to_genres
FOREIGN KEY (`genre_id`)
REFERENCES `genres`(`id`)
);

INSERT INTO actors (`first_name`, `last_name`, `birthdate`, `height`, `awards`, `country_id`)
SELECT reverse(a.first_name),
		reverse(a.last_name),
        DATE_SUB(a.birthdate, INTERVAL 2 DAY),
        a.height +10,
        a.country_id,
        (SELECT id FROM countries WHERE `name` = 'Armenia')
FROM actors AS a
WHERE a.id <= 10 ;

UPDATE movies_additional_info
SET runtime = runtime - 10
WHERE id BETWEEN 15 AND 25;

DELETE c
FROM countries AS c
LEFT JOIN movies AS m ON c.id = m.country_id
WHERE m.id IS NULL;

SELECT id, name, continent, currency
FROM countries
ORDER BY currency DESC, id;

SELECT m.id, m.title, mi.runtime, mi.budget, mi.release_date
FROM movies_additional_info AS mi
JOIN movies AS m ON mi.id = m.movie_info_id
WHERE YEAR(mi.release_date) BETWEEN '1996' and '1999'
ORDER BY mi.runtime, mi.id
LIMIT 20;

SELECT CONCAT_WS(' ', a.first_name, a.last_name) AS 'full_name',
	   CONCAT(reverse(a.last_name), CHAR_LENGTH(a.last_name), '@cast.com') AS 'email',
       2022 - YEAR(birthdate) AS 'age',
       a.height
FROM actors AS a
LEFT JOIN movies_actors AS ma ON a.id = ma.actor_id
WHERE ma.actor_id IS NULL 
ORDER BY a.height;

SELECT c.name, COUNT(m.id) AS 'movies_count'
FROM countries AS c
JOIN movies AS m ON c.id = m.country_id
GROUP BY c.name
HAVING movies_count >= 7
ORDER BY c.name DESC;

SELECT 
    m.title,
    CASE
        WHEN mi.rating <= 4 THEN 'poor'
        WHEN mi.rating <= 7 THEN 'good'
        ELSE 'excellent'
    END AS 'rating',
    IF(mi.has_subtitles = 1, 'english', '-') AS 'subtitles',
    mi.budget
FROM movies_additional_info AS mi
JOIN movies AS m ON mi.id = m.movie_info_id
ORDER BY mi.budget DESC;

DELIMITER $$
CREATE FUNCTION udf_actor_history_movies_count(full_name VARCHAR(50)) 
RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN(SELECT COUNT(ma.actor_id)
FROM actors AS a
JOIN movies_actors AS ma ON a.id = ma.actor_id
JOIN movies AS m ON m.id = ma.movie_id
JOIN genres_movies AS gm ON m.id = gm.movie_id
JOIN genres AS g ON g.id = gm.genre_id
WHERE g.name = 'history' AND
concat(a.first_name, ' ', a.last_name) = full_name);
END
$$

delimiter $$
CREATE PROCEDURE  udp_award_movie (movie_title VARCHAR(50))
BEGIN
UPDATE actors AS a
JOIN movies_actors AS ma ON a.id = ma.actor_id
JOIN movies AS m ON m.id = ma.movie_id
 SET awards = awards + 1 
WHERE m.title = movie_title;
END
$$


