CREATE DATABASE `restaurant_exam`;
USE `restaurant_exam`;

CREATE TABLE `products`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL UNIQUE,
`type` VARCHAR(30) NOT NULL,
`price` DECIMAL(10,2) NOT NULL
);


CREATE TABLE `clients`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(50) NOT NULL,
`last_name` VARCHAR(50) NOT NULL,
`birthdate` DATE NOT NULL,
`card` VARCHAR(50),
`review` TEXT
);


CREATE TABLE `tables`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`floor` INT NOT NULL,
`reserved` BOOLEAN,
`capacity` INT NOT NULL
);

CREATE TABLE `waiters`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(50) NOT NULL,
`last_name` VARCHAR(50) NOT NULL,
`email` VARCHAR(50) NOT NULL,
`phone` VARCHAR(50),
`salary` DECIMAL(10,2)
);

CREATE TABLE `orders`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`table_id` INT NOT NULL,
`waiter_id` INT NOT NULL,
`order_time` TIME NOT NULL,
`payed_status` BOOLEAN,
CONSTRAINT fk_orders_tables
FOREIGN KEY (`table_id`)
REFERENCES `tables`(`id`),
CONSTRAINT fk_orders_waiters
FOREIGN KEY (`waiter_id`)
REFERENCES `waiters`(`id`)
);


CREATE TABLE `orders_clients`(
`order_id` INT,
`client_id` INT,
CONSTRAINT fk_orders_clients_to_orders
FOREIGN KEY (`order_id`)
REFERENCES `orders`(`id`),
CONSTRAINT fk_orders_clients_to_clients
FOREIGN KEY (`client_id`)
REFERENCES `clients`(`id`)
);

CREATE TABLE `orders_products`(
`order_id` INT,
`product_id` INT,
CONSTRAINT fk_orders_products_to_orders
FOREIGN KEY (`order_id`)
REFERENCES `orders`(`id`),
CONSTRAINT fk_orders_products_to_products
FOREIGN KEY (`product_id`)
REFERENCES `products`(`id`)
);

INSERT INTO products (name, type, price)
SELECT 
	concat(last_name, ' ', 'specialty'),
    'Cocktail',
    CEIL(salary * 0.01)
FROM waiters
WHERE id > 6;

UPDATE orders
SET table_id = table_id - 1
WHERE id BETWEEN 12 AND 23;

DELETE w FROM waiters AS w
LEFT JOIN orders AS o ON o.waiter_id = w.id
WHERE o.waiter_id IS NULL;

SELECT * FROM clients
ORDER BY birthdate DESC, id DESC;

SELECT first_name, last_name, birthdate, review
FROM clients
WHERE card IS NULL AND YEAR(birthdate) BETWEEN 1978 AND 1993
ORDER BY last_name DESC, id
LIMIT 5;

SELECT 
	concat(last_name, first_name, char_length(first_name), 'Restaurant') AS 'username',
    reverse(substring(email, 2, 12)) AS 'password'
FROM waiters
WHERE salary IS NOT NULL
ORDER BY `password` DESC;

SELECT p.id, p.name, count(op.order_id) AS 'count'
FROM products AS p
JOIN orders_products AS op ON p.id = op.product_id
GROUP BY p.id
HAVING count >= 5
ORDER BY count DESC, p.name;

SELECT t.id, 
		t.capacity,
        COUNT(c.id) AS 'count_clients',
   CASE
 			WHEN t.capacity > COUNT(c.id) THEN 'Free seats'
 			WHEN t.capacity = COUNT(c.id) THEN 'Full'
             ELSE 'Extra seats'
		END AS 'availability'
FROM tables AS t
JOIN orders AS o ON o.table_id = t.id
JOIN orders_clients AS oc ON oc.order_id = o.id
JOIN clients AS c ON oc.client_id = c.id
WHERE t.floor = 1
GROUP BY t.id
ORDER BY t.id DESC;

DELIMITER $$
CREATE FUNCTION udf_client_bill(full_name VARCHAR(50)) 
RETURNS DECIMAL(19,2)
DETERMINISTIC
BEGIN
RETURN (SELECT SUM(p.price)
FROM clients AS c
JOIN orders_clients AS oc ON c.id = oc.client_id
JOIN orders AS o ON o.id = oc.order_id
JOIN orders_products AS op ON op.order_id = o.id
JOIN products AS p ON p.id = op.product_id
WHERE concat(c.first_name, ' ', c.last_name) = full_name);
END
$$

SELECT c.first_name,c.last_name, udf_client_bill('Silvio Blyth') as 'bill' FROM clients c
WHERE c.first_name = 'Silvio' AND c.last_name= 'Blyth';


