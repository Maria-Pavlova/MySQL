-- CREATE DATABASE instd;
-- USE instd;

CREATE TABLE `photos`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`description` TEXT NOT NULL,
`date` DATETIME NOT NULL,
`views` INT NOT NULL DEFAULT 0
);

CREATE TABLE `comments`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`comment` VARCHAR(255) NOT NULL,
`date` DATETIME NOT NULL,
`photo_id` INT NOT NULL,
CONSTRAINT fk_comments_photos
FOREIGN KEY (`photo_id`)
REFERENCES `photos`(`id`) 

);

CREATE TABLE `users`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`username` VARCHAR(30) NOT NULL UNIQUE,
`password` VARCHAR(30) NOT NULL,
`email` VARCHAR(50) NOT NULL,
`gender` CHAR(1) NOT NULL,
`age` INT NOT NULL,
`job_title` VARCHAR(40) NOT NULL,
`ip` VARCHAR(30) NOT NULL
);

CREATE TABLE `addresses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`address` VARCHAR(30) NOT NULL,
`town` VARCHAR(30) NOT NULL,
`country` VARCHAR(30) NOT NULL,
`user_id` INT NOT NULL,
CONSTRAINT fk_addresses_users
FOREIGN KEY (`user_id`)
REFERENCES `users`(`id`)
);

CREATE TABLE `likes`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`photo_id` INT,
`user_id` INT,
CONSTRAINT fk_likes_photos
FOREIGN KEY (`photo_id`)
REFERENCES `photos`(`id`),
CONSTRAINT fk_likes_users
FOREIGN KEY (`user_id`)
REFERENCES `users`(`id`)
);

CREATE TABLE `users_photos`(
`user_id` INT NOT NULL,
`photo_id` INT NOT NULL,
CONSTRAINT fk_users_photos_to_users
FOREIGN KEY (`user_id`)
REFERENCES `users`(`id`),
CONSTRAINT fk_users_photos_to_photos
FOREIGN KEY (`photo_id`)
REFERENCES `photos`(`id`)
);

INSERT INTO `addresses` (`address`, `town`, `country`, `user_id`)
SELECT u.username, u.password, u.ip, u.age
FROM users AS u
WHERE u.gender = 'M';

-- UPDATE addresses 
-- SET country = (
-- 	CASE
--     WHEN country LIKE 'B%' THEN 'Blocked'
--     WHEN country LIKE 'T%' THEN 'Test'
--     WHEN country LIKE 'P%' THEN 'In Progress'
--     ELSE counry
--     END
-- );

UPDATE addresses
SET country = 'Blocked'
WHERE country LIKE 'B%';
UPDATE addresses
SET country = 'Test'
WHERE country LIKE 'T%';
UPDATE addresses
SET country = 'In Progress'
WHERE country LIKE 'P%';

DELETE FROM `addresses`
WHERE id % 3 = 0;

SELECT username, gender, age
FROM users
ORDER BY age DESC, username;

SELECT p.id,
	   p.date AS 'date_and_time', 
       p.description,
       COUNT(c.comment) AS 'commentsCount'
FROM photos AS p
JOIN comments  AS c ON c.photo_id = p.id
GROUP BY p.id
ORDER BY `commentsCount` DESC, p.id
LIMIT 5;

SELECT concat_ws(' ', u.id, u.username) AS 'id_username', u.email
FROM users AS u
JOIN users_photos AS up ON u.id = up.user_id
WHERE up.user_id = up.photo_id
ORDER BY u.id;

SELECT p.id, 
	   COUNT(DISTINCT l.id) AS 'likes_count',
	   COUNT(DISTINCT c.id) AS 'comments_count'
FROM photos AS p
	LEFT  join likes AS l   ON p.id = l.photo_id
	LEFT JOIN comments AS c ON p.id = c.photo_id
GROUP BY p.id
ORDER BY `likes_count` DESC, `comments_count` DESC, p.id;

SELECT CONCAT(substring(p.description, 1, 30), '...') AS 'summary', p.date
FROM photos AS p
WHERE DAY(p.date) = '10'
ORDER BY p.date DESC;

DELIMITER $$
CREATE FUNCTION udf_users_photos_count(username VARCHAR(30))
RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN (SELECT COUNT(up.photo_id)
	FROM users AS u
	JOIN users_photos AS up ON u.id = up.user_id
	WHERE u.username = username);
END
$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE udp_modify_user (address VARCHAR(30), town VARCHAR(30))
BEGIN
	UPDATE users AS u
	JOIN addresses AS a ON u.id = a.user_id
	SET age = age + 10
	WHERE a.address = address AND a.town = town ;
END
$$