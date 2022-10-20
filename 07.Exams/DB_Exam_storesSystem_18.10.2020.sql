-- CREATE DATABASE `softuni_stores_system`;
-- USE softuni_stores_system;

CREATE TABLE `pictures`(
`id` iNT PRIMARY KEY AUTO_INCREMENT,
`url` VARCHAR(100) NOT NULL,
`added_on` DATETIME NOT NULL
);

CREATE TABLE `categories`(
`id` iNT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `products`(
`id` iNT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE,
`best_before` DATE,
`price` DECIMAL(10,2) NOT NULL,
`description` TEXT,
`category_id` INT NOT NULL,
`picture_id` INT NOT NULL,
CONSTRAINT fk_products_categories
FOREIGN KEY (`category_id`)
REFERENCES `categories` (`id`),
CONSTRAINT fk_products_pictures
FOREIGN KEY (`picture_id`)
REFERENCES `pictures` (`id`)
);

CREATE TABLE `towns`(
`id` iNT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL UNIQUE
);


CREATE TABLE `addresses`(
`id` iNT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL UNIQUE,
`town_id` INT NOT NULL,
CONSTRAINT fk_addresses_towns
FOREIGN KEY (`town_id`)
REFERENCES `towns` (`id`)
);

CREATE TABLE `stores`(
`id` iNT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL UNIQUE,
`rating` FLOAT NOT NULL,
`has_parking` BOOLEAN DEFAULT FALSE,
`address_id` INT NOT NULL,
CONSTRAINT fk_stores_addresses
FOREIGN KEY (`address_id`)
REFERENCES `addresses` (`id`)
);

CREATE TABLE `products_stores`(
`product_id` INT NOT NULL,
`store_id` INT NOT NULL,
CONSTRAINT fk_products_stores_to_products
FOREIGN KEY (`product_id`)
REFERENCES `products` (`id`),
CONSTRAINT fk_products_stores_to_stores
FOREIGN KEY (`store_id`)
REFERENCES `stores` (`id`),
CONSTRAINT c_pk
PRIMARY KEY(`product_id`, `store_id`)
);

CREATE TABLE `employees`(
`id` iNT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(15) NOT NULL,
`middle_name` CHAR(1),
`last_name` VARCHAR(20) NOT NULL,
`salary` DECIMAL(19,2) DEFAULT 0,
`hire_date` DATE NOT NULL,
`manager_id` INT,
`store_id` INT NOT NULL,
CONSTRAINT fk_employees_employees
FOREIGN KEY (`manager_id`)
REFERENCES `employees` (`id`),
CONSTRAINT fk_employees_stores
FOREIGN KEY (`store_id`)
REFERENCES `stores` (`id`)
);

INSERT INTO `products_stores` (`product_id`, `store_id`)
SELECT p.id, 1 FROM `products` AS p
LEFT JOIN `products_stores` AS ps ON ps.product_id = p.id
WHERE ps.product_id IS NULL;

UPDATE employees AS e
JOIN stores AS s ON e.store_id = s.id
	SET e.manager_id = 3, 
		e.salary = e.salary - 500
WHERE s.name NOT IN('Cardguard', 'Veribet') 
	AND YEAR(e.hire_date) > 2003;
    
DELETE FROM employees
WHERE salary >= 6000
	AND manager_id IS NOT NULL;

SELECT e.first_name, e.middle_name, e.last_name,
	e.salary, e.hire_date 
FROM employees AS e
ORDER BY e.hire_date DESC;  

SELECT pr.name AS 'product_name',
		pr.price, 
        pr.best_before,  
        concat(SUBSTRING(pr.description, 1, 10), '...') AS 'short_description',
        p.url
FROM products AS pr
JOIN pictures AS p ON p.id = pr.picture_id
WHERE pr.price > 20
	AND YEAR(p.added_on) < 2019  
    AND char_length(pr.description) > 100
ORDER BY pr.price DESC;

SELECT s.name,
	COUNT(p.id) AS 'product_count',
    ROUND(AVG(p.price), 2) AS 'avg'
FROM stores AS s
LEFT JOIN products_stores AS ps ON s.id = ps.store_id
LEFT JOIN products AS p ON p.id = ps.product_id
GROUP BY s.id
ORDER BY `product_count` DESC, `avg` DESC, s.id;

SELECT CONCAT(e.first_name, ' ', e.last_name) AS 'Full_name',
		s.name AS 'Store_name',
        a.name AS 'address',
        e.salary
FROM employees AS e
JOIN stores AS s ON e.store_id = s.id
JOIN addresses AS a ON a.id = s.address_id
WHERE e.salary < 4000
	AND a.name LIKE '%5%'
    AND char_length(s.name) > 8
    AND e.last_name LIKE '%n';
    
SELECT reverse(s.name) AS 'reversed_name',
		CONCAT(UPPER(t.name), '-', a.name) AS 'full_address',
        COUNT(e.id) AS 'employees_count'
FROM stores AS s
JOIN addresses AS a ON a.id = s.address_id
JOIN towns AS t ON t.id = a.town_id
JOIN employees AS e ON e.store_id = s.id
GROUP BY s.id
HAVING `employees_count` >= 1
ORDER BY `full_address`;

DELIMITER $$
CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50)) 
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN

DECLARE full_name VARCHAR(100);
DECLARE experience INT;
DECLARE employee_id INT;
DECLARE info VARCHAR(255);

SET employee_id := (SELECT e.id
FROM employees AS e
JOIN stores AS s ON s.id = e.store_id
WHERE s.name = store_name
ORDER BY e.salary DESC
LIMIT 1);

SET full_name := (SELECT CONCAT( e.first_name, ' ', e.middle_name, '. ', e.last_name)
FROM employees AS e
WHERE e.id = employee_id);

SET experience := (
SELECT timestampdiff(YEAR, e.hire_date, '2020-10-18')
FROM employees AS e
WHERE e.id = employee_id);

SET info := CONCAT_WS(' ', full_name,  'works in store for', experience, 'years');
RETURN info;
END
$$

DELIMITER $$
CREATE PROCEDURE udp_update_product_price (address_name VARCHAR (50))
BEGIN
	UPDATE products AS p
	JOIN products_stores AS ps ON ps.product_id = p.id
	JOIN stores AS s ON ps.store_id = s.id
	JOIN addresses AS a ON s.address_id = a.id
	SET p.price = IF(a.name LIKE '0%', p.price + 100, p.price + 200)
	WHERE a.name = address_name;
 END
$$
