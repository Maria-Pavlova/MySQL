CREATE DATABASE `online_store`;
use online_store;

CREATE TABLE `brands`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `categories`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `reviews`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`content` TEXT,
`rating` DECIMAL(10,2) NOT NULL,
`picture_url` VARCHAR(80) NOT NULL,
`published_at` DATETIME NOT NULL
);

CREATE TABLE `products`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL,
`price` DECIMAL(19,2) NOT NULL,
`quantity_in_stock` INT,
`description` TEXT,
`brand_id` INT NOT NULL,
`category_id` INT NOT NULL,
`review_id` INT,
CONSTRAINT fk_products_brands
FOREIGN KEY (`brand_id`)
REFERENCES `brands`(`id`),
CONSTRAINT fk_products_categories
FOREIGN KEY (`category_id`)
REFERENCES `categories`(`id`),
CONSTRAINT fk_products_reviews
FOREIGN KEY (`review_id`)
REFERENCES `reviews`(`id`)
);

CREATE TABLE `customers`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(20) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`phone` VARCHAR(30) NOT NULL UNIQUE,
`address` VARCHAR(60) NOT NULL,
`discount_card` BIT(1) NOT NULL DEFAULT FALSE
);

CREATE TABLE `orders`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`order_datetime` DATETIME NOT NULL,
`customer_id` INT NOT NULL,
CONSTRAINT fk_orders_customers
FOREIGN KEY (`customer_id`)
REFERENCES `customers`(`id`)
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

INSERT INTO `reviews` (`content`, `rating`, `picture_url`, `published_at`)
SELECT substring(p.description,1, 15),
		p.price / 8,
        reverse(p.name),
        '2010-10-10'
FROM products AS p
WHERE p.id >= 5;

UPDATE products
SET quantity_in_stock = quantity_in_stock - 5
WHERE quantity_in_stock BETWEEN 60 AND 70;

DELETE c  FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.id
WHERE o.customer_id IS NULL;

SELECT * FROM categories
ORDER BY name DESC;

SELECT id, brand_id, name, quantity_in_stock
FROM products
WHERE price > 1000 AND quantity_in_stock < 30
ORDER BY quantity_in_stock, id;

SELECT * FROM reviews
WHERE content LIKE 'My%' AND char_length(content) > 61
ORDER BY rating DESC;

SELECT CONCAT(c.first_name, ' ', c.last_name) AS 'full_name',
		c.address,
        o.order_datetime AS 'order_date'
FROM `customers` AS c
JOIN `orders` AS o ON c.id = o.customer_id
WHERE year(o.order_datetime) <= 2018
ORDER BY `full_name` DESC;

SELECT COUNT(p.id) AS 'items_count',
		c.name, 
        SUM(quantity_in_stock) AS 'total_quantity'
FROM categories AS c
JOIN products AS p ON c.id = p.category_id
GROUP BY c.id
ORDER BY `items_count` DESC, `total_quantity`
LIMIT 5;

DELIMITER $$
CREATE FUNCTION udf_customer_products_count(name VARCHAR(30)) 
RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN (SELECT COUNT(op.order_id)
	FROM customers AS c
	JOIN orders AS o ON o.customer_id = c.id
	JOIN orders_products AS op ON o.id = op.order_id
	WHERE c.first_name = name);
END
$$

DELIMITER $$
CREATE PROCEDURE udp_reduce_price  (category_name VARCHAR(50))
BEGIN
	UPDATE products AS p
JOIN categories AS c ON c.id = p.category_id
JOIN reviews AS r ON r.id = p.review_id
SET p.price = p.price * 0.7
WHERE c.name = category_name 
	AND r.rating < 4;
END
$$

