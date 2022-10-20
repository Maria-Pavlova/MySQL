-- LAB--------------
-- 01
CREATE TABLE `mountains`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45)
);

CREATE TABLE `peaks`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45),
`mountain_id` INT,
CONSTRAINT fk_peaks_mountains
FOREIGN KEY (`mountain_id`)
REFERENCES `mountains`(`id`)
);

-- 02 Lab-----------------------------
SELECT v.driver_id, v.vehicle_type,
concat_ws(' ', first_name, last_name) AS driver_name 
FROM vehicles AS v
JOIN campers AS c ON v.driver_id = c.id;

-- 03 Lab-----------------------------
SELECT 
    r.starting_point AS 'route_starting_point',
    r.end_point AS 'route_ending_point',
    r.leader_id,
    CONCAT_WS(' ', c.first_name, c.last_name) AS 'leader_name'
FROM routes AS r
        JOIN
    campers AS c ON r.leader_id = c.id;
 
 -- 04 Lab-----------------------------
 CREATE TABLE `mountains`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45)
);

CREATE TABLE `peaks`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45),
`mountain_id` INT,
CONSTRAINT fk_peaks_mountains
FOREIGN KEY (`mountain_id`)
REFERENCES `mountains`(`id`)
ON DELETE CASCADE
);

-- 05 Lab-----------------------------
CREATE DATABASE labFive;
use labFive;

 CREATE TABLE `clients`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`client_name` VARCHAR(100)
);

 CREATE TABLE `projects`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`client_id` INT,
`project_lead_id` INT,
CONSTRAINT fk_project_client
FOREIGN KEY (`client_id`)
REFERENCES `clients`(`id`)
);

 CREATE TABLE `employees`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(30),
`last_name` VARCHAR(30),
`project_id` INT(11),
CONSTRAINT fk_employee_project
FOREIGN KEY (`project_id`)
REFERENCES `projects`(`id`)
);

ALTER TABLE projects
ADD CONSTRAINT fk_project_employee
FOREIGN KEY (`project_lead_id`)
REFERENCES `employees`(`id`);

-- ------------ EXERCISE ------------------------------
-- 01 One-To-One Relationship------------------------------------------------
CREATE DATABASE reletion_exercise;
USE reletion_exercise;

CREATE TABLE people (
`person_id` INT AUTO_INCREMENT UNIQUE NOT NULL,
`first_name` VARCHAR(30) NOT NULL,
`salary` DECIMAL(10,2) NOT NULL DEFAULT 0,
`passport_id` INT NOT NULL UNIQUE
);

CREATE TABLE passports(
`passport_id` INT UNIQUE NOT NULL AUTO_INCREMENT ,
`passport_number` VARCHAR(8) NOT NULL UNIQUE
) AUTO_INCREMENT = 101;

INSERT INTO `people`(`first_name`, `salary`, `passport_id`)
 VALUES
 ('Roberto', 43300, 102),
 ('Tom', 56100, 103),
 ('Yana', 60200, 101);
 
INSERT INTO `passports` (`passport_number`)
VALUES
('N34FG21B'),
('K65LO4R7'),
('ZE657QP2');

ALTER TABLE `people`
ADD CONSTRAINT pk_people
PRIMARY KEY (`person_id`),
ADD CONSTRAINT fk_people_passports
FOREIGN KEY(`passport_id`) 
REFERENCES `passports`(`passport_id`);

-- 02. One-To-Many Relationship ----------------------------------------------

CREATE TABLE `manufacturers` (
`manufacturer_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL,
`established_on` DATE 
);

CREATE TABLE `models` (
`model_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL,
`manufacturer_id` INT,
CONSTRAINT fk_model_manufacturer
FOREIGN KEY (`manufacturer_id`)
REFERENCES `manufacturers`(`manufacturer_id`)
)AUTO_INCREMENT = 101;

INSERT INTO  `manufacturers` (`name`, `established_on`)
VALUES
('BMW', '1916-03-01'),
('Tesla', '2003-01-01'),
('Lada', '1966-05-01');

INSERT INTO `models` (`name`, `manufacturer_id`)
VALUES
('X1', 1),
('i6', 1),
('Model S', 2),
('Model X', 2),
('Model 3', 2),
('Nova', 3);
    
 -- 03. Many-To-Many Relationship--------------------------------------------------------------------------   
   
CREATE TABLE `students`(
`student_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL
); 

CREATE TABLE `exams`(
`exam_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL
)AUTO_INCREMENT = 101;

CREATE TABLE `students_exams`(
`student_id` INT NOT NULL,
`exam_id` INT NOT NULL,
CONSTRAINT pk_students_exams
PRIMARY KEY(`student_id`, `exam_id`),
CONSTRAINT fk_exams
FOREIGN KEY(`exam_id`)
REFERENCES `exams`(`exam_id`),
CONSTRAINT fk_students
FOREIGN KEY(`student_id`)
REFERENCES `students`(`student_id`)
); 

INSERT INTO `students` (`name`)
VALUES ('Mila'), ('Toni'), ('Ron');

INSERT INTO `exams` (`name`)
VALUES ('Spring MVC'), ('Neo4j'), ('Oracle 11g');

INSERT INTO `students_exams`
VALUES (1, 101), (1, 102), (2, 101),
		(3, 103), (2, 102), (2, 103);
        
  -- 04. Self-Referencing--------------------------------------------------------------------------------------
  
  CREATE TABLE `teachers` (
`teacher_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL,
`manager_id` INT DEFAULT NULL
)AUTO_INCREMENT = 101;

INSERT INTO `teachers` (`name`, `manager_id`)
VALUES
('John', null),
('Maya', 106),
('Silvia', 106),
('Ted', 105),
('Mark', 101),
('Greta', 101);

ALTER TABLE  `teachers` 
ADD CONSTRAINT fk_manager_teachers
FOREIGN KEY (`manager_id`)
REFERENCES `teachers`(`teacher_id`);

-- 05. Online Store Database---------------------------------------
CREATE DATABASE `online_store`;
USE `online_store`;

CREATE TABLE `item_types`(
`item_type_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) 
);

CREATE TABLE `items`(
`item_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50),
`item_type_id` INT,
CONSTRAINT fk_item_item_type
FOREIGN KEY(`item_type_id`)
REFERENCES `item_types`(`item_type_id`)
);

CREATE TABLE `cities`(
`city_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) 
);

CREATE TABLE `customers`(
`customer_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) ,
`birthday` DATE,
`city_id` INT,
CONSTRAINT fk_customer_city
FOREIGN KEY(`city_id`)
REFERENCES `cities`(`city_id`)
);

CREATE TABLE `orders` (
`order_id` INT PRIMARY KEY AUTO_INCREMENT ,
`customer_id` INT,
CONSTRAINT fk_order_customer
FOREIGN KEY(`customer_id`)
REFERENCES `customers`(`customer_id`)
);

CREATE TABLE `order_items` (
`order_id` INT NOT NULL,
`item_id` INT NOT NULL,
CONSTRAINT pk_order_items
PRIMARY KEY(`order_id`, `item_id` ),
CONSTRAINT fk_order_items_to_orders
FOREIGN KEY(`order_id`)
REFERENCES `orders`(`order_id`),
CONSTRAINT fk_order_items_to_items
FOREIGN KEY(`item_id`)
REFERENCES `items`(`item_id`)
);

-- 06. University Database-------------------------------------------------------------------

CREATE DATABASE `university`;
USE `university`;


CREATE TABLE `majors`(
`major_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) 
);

CREATE TABLE `students`(
`student_id` INT PRIMARY KEY AUTO_INCREMENT,
`student_number` VARCHAR(12),
`student_name` VARCHAR(50),
`major_id` INT,
 CONSTRAINT fk_student_major
 FOREIGN KEY( `major_id`)
 REFERENCES  `majors`(`major_id`)
);

CREATE TABLE `payments`(
`payment_id` INT PRIMARY KEY AUTO_INCREMENT,
`payment_date` DATE,
`payment_amount` DECIMAL(8, 2),
`student_id` INT,
 CONSTRAINT fk_payment_student
 FOREIGN KEY( `student_id`)
 REFERENCES  `students`(`student_id`)
);

CREATE TABLE `subjects`(
`subject_id` INT PRIMARY KEY AUTO_INCREMENT,
`subject_name` VARCHAR(50) 
);

CREATE TABLE `agenda`(
`student_id` INT NOT NULL,
`subject_id` INT NOT NULL,
CONSTRAINT pk_agenda
PRIMARY KEY(`student_id`,`subject_id`),
CONSTRAINT fk_agenda_students
FOREIGN KEY(`student_id`)
REFERENCES `students`(`student_id`),
CONSTRAINT fk_agenda_subjects
FOREIGN KEY (`subject_id`)
REFERENCES `subjects`(`subject_id`)
);

-- 09. Peaks in Rila-------------------------------------------------------------------

SELECT m.mountain_range, 
p.peak_name, p.elevation AS 'peak_elevation'
FROM mountains AS m  
JOIN peaks AS p ON m.id = p.mountain_id
WHERE m.mountain_range = 'Rila'
ORDER BY `peak_elevation` DESC;