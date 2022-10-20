 CREATE DATABASE `colonial_journey_management_system_db`;
use colonial_journey_management_system_db;

CREATE TABLE `planets`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL
);

CREATE TABLE `spaceports`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
`planet_id` INT,
CONSTRAINT fk_spaceports_planets
FOREIGN KEY (`planet_id`)
REFERENCES `planets`(`id`)
);

CREATE TABLE `spaceships`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
`manufacturer` VARCHAR(30) NOT NULL,
`light_speed_rate` INT DEFAULT 0
);

CREATE TABLE `colonists`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(20) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`ucn` CHAR(10) NOT NULL UNIQUE,
`birth_date` DATE NOT NULL
);

CREATE TABLE `journeys`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`journey_start` DATETIME NOT NULL,
`journey_end` DATETIME NOT NULL,
`purpose` ENUM('Medical','Technical','Educational','Military'),
`destination_spaceport_id` INT,
`spaceship_id` INT,
CONSTRAINT fk_journeys_destination_spaceports
FOREIGN KEY (`destination_spaceport_id`)
REFERENCES `spaceports`(`id`),
CONSTRAINT fk_journeys_spaceports
FOREIGN KEY (`spaceship_id`)
REFERENCES `spaceships`(`id`)
);

CREATE TABLE `travel_cards`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`card_number` CHAR(10) NOT NULL UNIQUE,
`job_during_journey` ENUM('Pilot', 'Engineer', 'Trooper',  'Cleaner', 'Cook'),
`colonist_id` INT,
`journey_id` INT,
CONSTRAINT fk_travel_cards_colonists
FOREIGN KEY (`colonist_id`)
REFERENCES `colonists`(`id`),
CONSTRAINT fk_travel_cards_journeys
FOREIGN KEY (`journey_id`)
REFERENCES `journeys`(`id`)
);

INSERT INTO travel_cards (card_number, job_during_journey, colonist_id, journey_id)
(SELECT 
	IF(birth_date > '1980-01-01', 
		 concat(YEAR(birth_date), DAY(birth_date), substring(`ucn`, 1,4)),
         concat(YEAR(birth_date), MONTH(birth_date), right(`ucn`, 4)))
         as '1',
     CASE
		WHEN id % 2 = 0 THEN 'Pilot'
		WHEN id % 3 = 0 THEN 'Cook'
        ELSE 'Engineer'
        END AS '2',
        id,
        LEFT(ucn, 1)
FROM colonists
WHERE id BETWEEN 96 AND 100);

UPDATE journeys
	SET purpose =
    CASE
    WHEN id % 2 = 0 THEN 'Medical'
    WHEN id % 3 = 0 THEN 'Technical'
    WHEN id % 5 = 0 THEN 'Educational'
    WHEN id % 7 = 0 THEN 'Military'
    ELSE purpose
    END;
    
      
    DELETE c FROM colonists AS c
    LEFT JOIN travel_cards AS tc ON tc.colonist_id = c.id
    WHERE tc.journey_id IS NULL;
    
    SELECT card_number, job_during_journey
    FROM travel_cards
    ORDER BY card_number;
    
    SELECT id, 
		   CONCAT_WS(' ', first_name, last_name) AS 'full_name',
           ucn
		FROM colonists
        ORDER BY first_name, last_name, id;
        
	SELECT id, journey_start, journey_end
    FROM journeys
    WHERE purpose LIKE 'Military'
    ORDER BY journey_start;
    
    SELECT c.id, 
		   CONCAT_WS(' ', c.first_name, c.last_name) AS 'full_name'
    FROM colonists AS c
    JOIN travel_cards AS tc ON tc.colonist_id = c.id
    WHERE job_during_journey LIKE 'Pilot'
    ORDER BY c.id;
   
   SELECT COUNT(*) AS 'count'
   FROM colonists AS c
   JOIN travel_cards AS tc ON tc.colonist_id = c.id
   JOIN journeys AS j ON tc.journey_id = j.id
   WHERE j.purpose LIKE 'Technical';
   
   
   SELECT s.name, sp.name
   FROM spaceships AS s
   JOIN journeys AS j ON j.spaceship_id = s.id
   JOIN spaceports AS sp ON j.destination_spaceport_id = sp.id
   ORDER BY s.light_speed_rate DESC
   LIMIT 1;
   
   
     SELECT s.name, s.manufacturer
   FROM spaceships AS s
   JOIN journeys AS j ON j.spaceship_id = s.id
   JOIN travel_cards AS tc ON tc.journey_id = j.id
   JOIN colonists AS c ON tc.colonist_id = c.id
   WHERE timestampdiff( YEAR, c.birth_date, '2019-01-01') < 30
     AND tc.job_during_journey LIKE 'Pilot'
	ORDER BY s.name;
    
SELECT p.name AS 'planet_name', s.name AS 'spaceport_name'
FROM planets AS p
LEFT JOIN spaceports AS s ON s.planet_id = p.id
JOIN journeys AS j ON j.destination_spaceport_id = s.id
WHERE j.purpose LIKE 'Educational'
ORDER BY `spaceport_name` DESC;

SELECT p.name AS 'planet_name', COUNT(j.id) AS 'journeys_count'
FROM planets AS p
LEFT JOIN spaceports AS s ON s.planet_id = p.id
JOIN journeys AS j ON j.destination_spaceport_id = s.id
GROUP BY p.id
ORDER BY `journeys_count` DESC, `planet_name`;

SELECT j.id,
		p.name AS 'planet_name', 
        s.name AS 'spaceport_name',
        j.purpose AS 'journey_purpose'
FROM planets AS p
LEFT JOIN spaceports AS s ON s.planet_id = p.id
JOIN journeys AS j ON j.destination_spaceport_id = s.id
ORDER BY datediff( j.journey_end, j.journey_start )
LIMIT 1;


SELECT tc.job_during_journey AS 'job_name'
FROM colonists AS c
        JOIN travel_cards AS tc ON tc.colonist_id = c.id
        JOIN journeys AS j ON tc.journey_id = j.id
GROUP BY j.id , tc.job_during_journey
ORDER BY DATEDIFF(journey_end, journey_start) DESC , COUNT(tc.job_during_journey)
LIMIT 1;

DELIMITER $$
CREATE FUNCTION udf_count_colonists_by_destination_planet (planet_name VARCHAR (30)) 
RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN  (SELECT COUNT(tc.colonist_id)
FROM planets AS p
JOIN spaceports AS s ON s.planet_id = p.id
JOIN journeys AS j ON j.destination_spaceport_id = s.id  
JOIN travel_cards AS tc ON tc.journey_id = j.id
WHERE p.name = planet_name);
END
$$

DELIMITER $$
CREATE PROCEDURE udp_modify_spaceship_light_speed_rate(
			spaceship_name VARCHAR(50), light_speed_rate_increse INT(11)) 
BEGIN
 START TRANSACTION;
	IF (SELECT name FROM spaceships 
	WHERE name =  spaceship_name) IS NULL
    THEN ROLLBACK;
         SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Spaceship you are trying to modify does not exists.';
    ELSE
		UPDATE spaceships 
		SET light_speed_rate = light_speed_rate + light_speed_rate_increse
		WHERE name =  spaceship_name;
	COMMIT;
	END IF;
END
$$
DELIMITER ;


CALL udp_modify_spaceship_light_speed_rate ('Fade', 5);
SELECT name, light_speed_rate FROM spaceships WHERE name = 'Fade';

CALL udp_modify_spaceship_light_speed_rate ('Na Pesho koraba', 1914);
SELECT name, light_speed_rate FROM spacheships WHERE name = 'Na Pesho koraba'



    