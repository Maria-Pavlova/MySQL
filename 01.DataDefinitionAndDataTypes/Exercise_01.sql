CREATE DATABASE `minions`;
USE `minions`;

CREATE TABLE `minions` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL,
`age` INT
);

CREATE TABLE `towns`(
`town_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL
);

ALTER TABLE `towns`
CHANGE COLUMN `town_id` `id` INT;

INSERT INTO `minions` (`id`, `name`, `age`) VALUES
(1, 'Minion1', 20 ),
(2, 'Minion2', null );

ALTER TABLE `minions`
ADD COLUMN `town_id` INT,
ADD CONSTRAINT fk_minions_towns
FOREIGN KEY (`town_id`)
REFERENCES `towns`(`id`);

INSERT INTO  `towns`(`id`, `name`)
VALUES (1, 'Sofia'), (2, 'Plovdiv'), (3, 'Varna');

INSERT INTO `minions` (`id`, `name`, `age`, `town_id`)
VALUES 
(1, 'Kevin', 22, 1),
(2, 'Bob', 15, 3),
(3, 'Steward', NULL, 2);

TRUNCATE `minions`;

DROP TABLE `minions`;
DROP TABLE `towns`;

CREATE TABLE `people` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(200) NOT NULL,
`picture` BLOB,
`height` DOUBLE(3, 2),
`weight` DOUBLE(5, 2),
`gender` CHAR(1) NOT NULL,
`birthdate` DATE NOT NULL,
`biography` TEXT
);

INSERT INTO `people` (`id`, `name`, `picture`, `height`,  `weight`, `gender`, `birthdate`, `biography`)
VALUES
(1, 'Maria Ivanova', NULL, 1.65, 55.80, 'f', '1998-08-10', NULL),
(2, 'Victoria Ivanova', NULL, 1.70, 65.50, 'f', '1999-06-10', NULL),
(3, 'Ivan Ivanov', NULL, 1.75, 59.20, 'm', '1989-09-10', NULL),
(4, 'Todor Todorov', NULL, 1.62, 62.80, 'm', '1982-08-10', NULL),
(5, 'Georgi Georgiev', NULL, 1.60, 58.30, 'm', '1984-11-10', NULL);

CREATE TABLE `users`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`username` VARCHAR(30) UNIQUE NOT NULL,
`password` VARCHAR(26) NOT NULL,
`profile_picture` BLOB,
`last_login_time` DATETIME,
`is_deleted` BOOLEAN DEFAULT FALSE
);

INSERT INTO `users` (`id`, `username`, `password`, `profile_picture`,  `last_login_time`, `is_deleted`)
VALUES
(1, 'USER1', 'PAS1234', NULL, '2022-08-30 23:20:00', false),
(2, 'USER2', '123pass', NULL, '2022-08-30 11:20:00', false),
(3, 'USER3', 'password', NULL, '2022-08-30 15:40:00', false),
(4, 'USER4', 'pass789', NULL, '2022-08-31 19:20:00', false),
(5, 'USER5', 'pass456', NULL, '2022-08-29 23:45:20', false);

ALTER TABLE `users` 
DROP PRIMARY KEY,
ADD CONSTRAINT `pk_users`
PRIMARY KEY `users`(`id`, `username`);

ALTER TABLE `users`
MODIFY `last_login_time` DATETIME DEFAULT current_timestamp; 

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT `id` 
PRIMARY KEY `users` (`id`); 

ALTER TABLE `users`
ADD CONSTRAINT `unique` UNIQUE (`username`); 

CREATE DATABASE `car_rental`;


CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`category` VARCHAR(30) NOT NULL, 
`daily_rate` DOUBLE, 
`weekly_rate`DOUBLE, 
`monthly_rate`DOUBLE, 
`weekend_rate`DOUBLE
); 

INSERT INTO `categories` (`id`, `category`, `daily_rate`, `weekly_rate`, `monthly_rate`, `weekend_rate`)
VALUES
(1, 'car', 20.50, 140, 500, 50),
(2, 'bus', 30.50, 200, 590, 60),
(3, 'track', 40.50, 240, 700, 80);

CREATE TABLE `cars` (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`plate_number` VARCHAR(15), 
`make` VARCHAR(15) NOT NULL, 
`model` VARCHAR(15), 
`car_year` YEAR, 
`category_id` INT, 
`doors` INT, 
`picture` BLOB, 
`car_condition` TEXT, 
`available` BOOLEAN,
CONSTRAINT fk_cars_categories
FOREIGN KEY `cars`(`category_id`)
REFERENCES `categories`(`id`)
);

INSERT INTO `cars` (`id`, `plate_number`, `make`, `model`, `car_year`, `category_id`)
VALUES
(1, 'alabala', 'bmw', 'x6', 2012, 1),
(2, 'tralala', 'bmw', 'x5', 2012, 1),
(3, 'ala12', 'audi', 'A6', 2015, 1);

CREATE TABLE `employees` (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`first_name` VARCHAR(15) NOT NULL, 
`last_name` VARCHAR(15) NOT NULL, 
`title` VARCHAR(15), 
`note` TEXT
);

INSERT INTO `employees` (`id`, `first_name`, `last_name`, `title`, `note`)
VALUES
(1, 'Ivan', 'Ivanov', 'Manager', NULL),
(2, 'Ani', 'Ivanova', 'Worker', NULL),
(3, 'Ivanka', 'Todorova', 'Cleaner', NULL);

CREATE TABLE `customers` (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`driver_licence_number` VARCHAR(15), 
`full_name` VARCHAR(30) NOT NULL, 
`address` VARCHAR(30), 
`city` VARCHAR(30), 
`zip_code` INT, 
`note` TEXT
);

INSERT INTO `customers` (`id`, `driver_licence_number`, `full_name`, `address`, `city`, `zip_code`, `note`)
VALUES
(1, '12548', 'Gary Smith', NULL, 'Sofia', 1000, NULL),
(2, '254892', 'Tom Smith', NULL, 'Varna', 2000, NULL),
(3, '254875', 'Ben Tomson', NULL, 'Plovdiv', 6000, NULL);

CREATE TABLE `rental_orders` (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`employee_id` INT, 
`customer_id`INT, 
`car_id` INT, 
`car_condition` TEXT, 
`tank_level` DOUBLE, 
`kilometrage_start` INT, 
`kilometrage_end` INT, 
`total_kilometrage` INT, 
`start_date` DATETIME, 
`end_date` DATETIME, 
`total_days` INT, 
`rate_applied` DOUBLE, 
`tax_rate` DOUBLE, 
`order_status`BOOLEAN, 
`note` TEXT,
CONSTRAINT fk_rental_orders_employees
FOREIGN KEY `rental_orders`(`employee_id`) REFERENCES `employees`(`id`),
CONSTRAINT fk_rental_orders_customers
FOREIGN KEY `rental_orders`(`customer_id`) REFERENCES `customers`(`id`),
CONSTRAINT fk_rental_orders_cars
FOREIGN KEY `rental_orders`(`car_id`) REFERENCES `cars`(`id`)
); 

INSERT INTO `rental_orders` (`id`,`employee_id`,`customer_id`, `car_id`,`tank_level`, `kilometrage_start` , 
`kilometrage_end` , `total_kilometrage`, `start_date`, `end_date` , `total_days`, `rate_applied`, `tax_rate`, `order_status`)
VALUES
(1,2,1,1,20.5,56850,56890,40,'2022-08-20 08:00:00','2022-08-21 08:05:00',1,20.50,20,NULL),
(2,1,3,2,36.5,56850,56990,140,'2022-08-20 10:10:00','2022-08-27 11:00:00',7,20.50,20,NULL),
(3, 2, 2, 3, 30.5, 56850, 56895, 45, '2022-08-20 15:10:00', '2022-08-21 15:00:00', 1, 20.50, 20, NULL);




 




