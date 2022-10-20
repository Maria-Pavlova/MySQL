CREATE DATABASE `SoftUni_Taxi_Company`;
USE SoftUni_Taxi_Company;

CREATE TABLE `addresses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(100) NOT NULL
);

CREATE TABLE `categories`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(10) NOT NULL
);

CREATE TABLE `clients`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`full_name` VARCHAR(50) NOT NULL,
`phone_number` VARCHAR(20) NOT NULL
);

CREATE TABLE `drivers`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(30) NOT NULL,
`last_name` VARCHAR(30) NOT NULL,
`age` INT NOT NULL,
`rating` FLOAT DEFAULT 5.5
);

CREATE TABLE `cars`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`make` VARCHAR(20) NOT NULL,
`model` VARCHAR(20),
`year` INT NOT NULL DEFAULT 0,
`mileage` INT DEFAULT 0,
`condition` CHAR(1) NOT NULL,
`category_id` INT NOT NULL,
CONSTRAINT fk_cars_categories
FOREIGN KEY (`category_id`)
REFERENCES `categories`(`id`)
);

CREATE TABLE `courses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`from_address_id` INT NOT NULL,
`start` DATETIME NOT NULL,
`bill` DECIMAL(10, 2) DEFAULT 10,
`car_id` INT NOT NULL,
`client_id` INT NOT NULL,
CONSTRAINT fk_courses_addresses
FOREIGN KEY (`from_address_id`)
REFERENCES `addresses`(`id`),
CONSTRAINT fk_courses_cars
FOREIGN KEY (`car_id`)
REFERENCES `cars`(`id`),
CONSTRAINT fk_courses_clients
FOREIGN KEY (`client_id`)
REFERENCES `clients`(`id`)
);

CREATE TABLE `cars_drivers`(
`car_id` INT NOT NULL,
`driver_id` INT NOT NULL,
 CONSTRAINT fk_cars_drivers_to_cars
FOREIGN KEY (`car_id`)
REFERENCES `cars`(`id`),
CONSTRAINT fk_cars_drivers_to_drivers
FOREIGN KEY (`driver_id`)
REFERENCES `drivers`(`id`),
CONSTRAINT pk
PRIMARY KEY(`car_id`, `driver_id`)
);

INSERT INTO `clients`(`full_name`,`phone_number`) 
SELECT CONCAT(`first_name`, ' ', `last_name`),
		CONCAT('(088) 9999', d.id * 2)
FROM drivers AS d
WHERE d.id BETWEEN 10 AND 20;

UPDATE cars 
SET `condition` = 'C'
WHERE `year` <= 2010
    AND `make` NOT LIKE 'Mercedes-Benz'
	AND (`mileage` >= 800000 OR `mileage` IS NULL);

DELETE cl FROM `clients` AS cl
LEFT JOIN `courses` AS c ON c.client_id = cl.id
WHERE char_length(`full_name`) > 3 
		AND c.client_id IS NULL;
        
SELECT `make`, `model`, `condition` FROM cars
ORDER BY `id`;

SELECT d.`first_name`, 
		d.`last_name`,
        c.`make`,
        c.`model`,
        c.`mileage`
FROM `drivers` AS d
JOIN `cars_drivers` AS cd ON d.id = cd.driver_id
JOIN `cars` AS c ON c.id = cd.car_id
WHERE c.mileage IS NOT NULL
ORDER BY  c.`mileage` DESC, d.`first_name`;

SELECT c.id AS 'car_id ', c.make, c.mileage,
		COUNT(cr.id) AS 'count_of_courses', 
        ROUND(AVG(cr.bill), 2) AS 'avg_bill'
FROM cars AS c
LEFT JOIN courses AS cr ON cr.car_id = c.id
GROUP BY c.id
HAVING count_of_courses != 2
ORDER BY `count_of_courses` DESC, c.id;
        
SELECT cl.full_name, 
		COUNT(c.car_id) AS 'count_of_cars',
        SUM(c.bill) AS 'total_sum'
 FROM `clients` AS cl
JOIN `courses` AS c ON cl.id = c.client_id
GROUP BY cl.id
HAVING cl.full_name LIKE '_a%' AND `count_of_cars` > 1
ORDER BY cl.full_name;

SELECT a.name,
		IF (HOUR(cr.start) BETWEEN 6 AND 20, 'Day', 'Night') AS 'day_time',
        cr.bill,
        cl.full_name,
        c.make,
        c.model,
        ct.name
FROM `courses` AS cr 
JOIN `addresses` AS a ON a.id = cr.from_address_id
JOIN `clients` AS cl ON cr.client_id = cl.id
JOIN `cars` AS c ON c.id = cr.car_id
JOIN `categories` AS ct ON ct.id = c.category_id
ORDER BY cr.id;

DELIMITER $$
CREATE FUNCTION `udf_courses_by_client`(phone_num VARCHAR (20)) 
RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN (SELECT COUNT(c.id) FROM courses AS c
	JOIN clients AS cl ON cl.id = c.client_id
	WHERE cl.phone_number = phone_num);
END
$$

DELIMITER $$
CREATE PROCEDURE udp_courses_by_address (address_name VARCHAR(100))
BEGIN
	SELECT a.name,
		cl.full_name,
        CASE
			WHEN cr.bill <= 20 THEN 'Low'
			WHEN cr.bill <= 30 THEN 'Medium'
            ELSE 'High'
		END AS 'level_of_bill',
        c.make,
        c.condition,
        ct.name AS 'cat_name'
	FROM addresses AS a
	JOIN courses AS cr ON a.id = cr.from_address_id
	JOIN clients AS cl ON cl.id = cr.client_id
	JOIN cars AS c ON c.id = cr.car_id
	JOIN categories AS ct ON ct.id = c.category_id
	WHERE a.name = address_name
	ORDER BY c.make, cl.full_name;
END
$$
DELIMITER ;

CALL udp_courses_by_address('66 Thompson Drive');







