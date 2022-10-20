CREATE DATABASE `movies`;
USE `movies`;

CREATE TABLE `directors` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
 `director_name` VARCHAR(30) NOT NULL, 
 `notes` VARCHAR(50)
);

INSERT INTO `directors`(`director_name`)
VALUES
('Tarantino'), 
('Scorsese'),
('Ford'), 
('Hitchcock'), 
('Scott');

CREATE TABLE `genres` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
 `genre_name` VARCHAR(30) NOT NULL, 
 `notes` VARCHAR(50)
);

INSERT INTO `genres` (`genre_name`)
VALUES
('drama'), 
('comedy'),
('action'), 
('crime'), 
('thriller');

CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`category_name` VARCHAR(20) NOT NULL, 
`notes` VARCHAR(50)
); 

INSERT INTO `categories` (`category_name`)
VALUES
('family'), 
('serials'),
('sport'), 
('documental'), 
('science');

CREATE TABLE `movies` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
 `title` VARCHAR(30) NOT NULL,
 `director_id` INT,
 `copyright_year`YEAR,
 `length` TIME,
 `genre_id` INT,
 `category_id` INT,
 `rating` INT,
 `notes` VARCHAR(50),
 CONSTRAINT fk_movie_director
 FOREIGN KEY `movies`(`director_id`) REFERENCES `directors`(`id`),
 CONSTRAINT fk_movie_genres
 FOREIGN KEY `movies`(`genre_id`) REFERENCES `genres`(`id`),
 CONSTRAINT fk_movie_categories
 FOREIGN KEY `movies`(`category_id`) REFERENCES `categories`(`id`)
);

INSERT INTO `movies` (`title`, `director_id`, `genre_id`, `category_id`)
VALUES
('Movie1', 1, 1, 1),
('Movie2', 2, 2, 2),
('Movie3', 3, 3, 3),
('Movie4', 1, 2, 4),
('Movie5', 5, 5, 5);