CREATE DATABASE `car_rental`;
USE `car_rental`;

CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`category` VARCHAR(20), 
`daily_rate` DOUBLE, 
`weekly_rate`DOUBLE, 
`monthly_rate`DOUBLE, 
`weekend_rate`DOUBLE
); 

INSERT INTO `categories` (`category`, `daily_rate`, `weekly_rate`, `monthly_rate`, `weekend_rate`)
VALUES
('car', 20.50, 140, 500, 50),
('bus', 30.50, 200, 590, 60),
('track', 40.50, 240, 700, 80);

CREATE TABLE `cars` (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`plate_number` VARCHAR(20), 
`make` VARCHAR(20), 
`model` VARCHAR(20), 
`car_year` INT, 
`category_id` INT, 
`doors` INT, 
`picture` BLOB, 
`car_condition` VARCHAR(30), 
`available` BOOLEAN
);

ALTER TABLE `cars`
ADD CONSTRAINT fk_cars_categories
FOREIGN KEY (`category_id`)
REFERENCES `categories`(`id`);

INSERT INTO `cars` (`plate_number`, `make`, `model`, `car_year`, `category_id`)
VALUES
('alabala', 'bmw', 'x6', '2012' , 1),
('tralala', 'bmw', 'x5', '2012' , 2),
('ala12', 'audi', 'A6', '2015' , 3);

CREATE TABLE `employees` (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`first_name` VARCHAR(15) NOT NULL, 
`last_name` VARCHAR(15) NOT NULL, 
`title` VARCHAR(15), 
`notes` TEXT
);

INSERT INTO `employees` (`first_name`, `last_name`, `title`)
VALUES
('Ivan', 'Ivanov', 'Manager'),
('Ani', 'Ivanova', 'Worker'),
('Ivanka', 'Todorova', 'Cleaner');

CREATE TABLE `customers` (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`driver_licence_number` VARCHAR(15), 
`full_name` VARCHAR(30), 
`address` VARCHAR(30), 
`city` VARCHAR(30), 
`zip_code` INT, 
`notes` TEXT
);

INSERT INTO `customers` (`driver_licence_number`, `full_name`, `address`, `city`, `zip_code`, `notes`)
VALUES
('12548', 'Gary Smith', NULL, 'Sofia', 1000, NULL),
('254892', 'Tom Smith', NULL, 'Varna', 2000, NULL),
('254875', 'Ben Tomson', NULL, 'Plovdiv', 6000, NULL);

CREATE TABLE `rental_orders` (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`employee_id` INT, 
`customer_id`INT, 
`car_id` INT, 
`car_condition` VARCHAR(30), 
`tank_level` VARCHAR(20), 
`kilometrage_start` INT, 
`kilometrage_end` INT, 
`total_kilometrage` INT, 
`start_date` DATE, 
`end_date` DATE, 
`total_days` INT, 
`rate_applied` DOUBLE, 
`tax_rate` DOUBLE, 
`order_status`VARCHAR(20), 
`notes` TEXT
); 

ALTER TABLE `rental_orders`
ADD CONSTRAINT fk_rental_orders_employees
FOREIGN KEY `rental_orders`(`employee_id`) REFERENCES `employees`(`id`),
ADD CONSTRAINT fk_rental_orders_customers
FOREIGN KEY `rental_orders`(`customer_id`) REFERENCES `customers`(`id`),
ADD CONSTRAINT fk_rental_orders_cars
FOREIGN KEY `rental_orders`(`car_id`) REFERENCES `cars`(`id`);

INSERT INTO `rental_orders` (`employee_id`,`customer_id`, `car_id`,`tank_level`, `kilometrage_start` , 
`kilometrage_end` , `total_kilometrage`, `start_date`, `end_date` , `total_days`, `rate_applied`, `tax_rate`)
VALUES
(2,1,1,20,56850,56890,40,'2022-08-20','2022-08-21',1,20.50,20),
(1,3,2,36,56850,56990,140,'2022-08-20','2022-08-27',7,20.50,20),
(3, 2, 3, 30, 56850, 56895, 45, '2022-08-20', '2022-08-21', 1, 20.50, 20);

