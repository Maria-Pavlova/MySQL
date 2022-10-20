CREATE DATABASE `colonial_blog`;
USE colonial_blog;

CREATE TABLE `categories`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`category` VARCHAR(30) NOT NULL
);

CREATE TABLE `users`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`username` VARCHAR(30) NOT NULL UNIQUE,
`password` VARCHAR(30) NOT NULL,
`email` VARCHAR(50) NOT NULL
);

CREATE TABLE `articles`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`title` VARCHAR(50) NOT NULL,
`content`TEXT NOT NULL,
`category_id` INT,
CONSTRAINT fk_articles_categories
FOREIGN KEY (`category_id`)
REFERENCES `categories` (`id`)
);

CREATE TABLE users_articles (
`user_id` INT,
`article_id` INT,
CONSTRAINT fk_users_articles_users
FOREIGN KEY (`user_id`)
REFERENCES `users` (`id`),
CONSTRAINT fk_users_articles_articles
FOREIGN KEY (`article_id`)
REFERENCES `articles` (`id`)
);

CREATE TABLE `comments`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`comment` VARCHAR(255) NOT NULL,
`article_id` INT NOT NULL,
`user_id` INT NOT NULL,
CONSTRAINT fk_comments_users
FOREIGN KEY (`user_id`)
REFERENCES `users` (`id`),
CONSTRAINT fk_comments_articles
FOREIGN KEY (`article_id`)
REFERENCES `articles` (`id`)
);

CREATE TABLE `likes`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`article_id` INT,
`comment_id`INT,
`user_id` INT NOT NULL,
CONSTRAINT fk_likes_users
FOREIGN KEY (`user_id`)
REFERENCES `users` (`id`),
CONSTRAINT fk_likes_articles
FOREIGN KEY (`article_id`)
REFERENCES `articles` (`id`),
CONSTRAINT fk_likes_comments
FOREIGN KEY (`comment_id`)
REFERENCES `comments` (`id`)
);

INSERT INTO likes (article_id, comment_id, user_id)
SELECT 
	IF(id % 2 = 0, CHAR_LENGTH(username), null),
	IF(id % 2 = 1, CHAR_LENGTH(email), null),
    id
FROM users
WHERE id BETWEEN 16 AND 20;

UPDATE comments
SET comment = 
	CASE
		WHEN id % 2 = 0 THEN 'Very good article.'
		WHEN id % 3 = 0 THEN 'This is interesting.'
		WHEN id % 5 = 0 THEN 'I definitely will read the articl again.'
		WHEN id % 7 = 0 THEN 'The universe is such an amazing thing.'
		ELSE comment
    END
WHERE id BETWEEN 1 AND 15;


DELETE FROM articles
WHERE category_id IS NULL;

SELECT s.title, s.summary
FROM (SELECT id, title, CONCAT(LEFT(content, 20), '...') AS 'summary'
	FROM articles 
	ORDER BY char_length(content) DESC
	LIMIT 3) AS s
ORDER BY s.id; 

SELECT a.id, a.title
FROM articles AS a
JOIN users_articles AS ua ON ua.article_id = a.id
WHERE ua.user_id = ua.article_id
ORDER BY a.id;


SELECT c.category,
		COUNT(DISTINCT a.id) AS 'articles',
        COUNT(l.id) AS 'likes'
FROM categories AS c
LEFT JOIN articles AS a ON c.id = a.category_id
LEFT JOIN likes AS l ON l.article_id = a.id
GROUP BY c.category
ORDER BY `articles` DESC, `likes` DESC, c.id;


SELECT a.title, COUNT(c.id) AS 'comments'
FROM articles AS a
JOIN comments AS c ON c.article_id = a.id
JOIN categories AS cat ON cat.id = a.category_id
WHERE cat.category LIKE 'Social'
GROUP BY a.id
ORDER BY `comments` DESC
LIMIT 1;


SELECT CONCAT(LEFT(c.comment, 20), '...') AS 'summary'
FROM comments AS c
LEFT JOIN likes As l ON l.comment_id = c.id
WHERE l.comment_id IS NULL
ORDER BY c.id DESC;


DELIMITER $$
CREATE FUNCTION udf_users_articles_count(user_name VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN(
		SELECT COUNT(ua.article_id) FROM users AS u
        JOIN users_articles AS ua ON ua.user_id = u.id
        WHERE u.username = user_name); 
END
$$


DELIMITER $$
CREATE PROCEDURE udp_like_article(user_name VARCHAR(30),
									title VARCHAR(30))
BEGIN

	IF ((SELECT COUNT(*) FROM users AS u  
		WHERE u.username = user_name) = 0)
        THEN SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Non-existent user.';
        ROLLBACK;
	ELSEIF ((SELECT COUNT(*) FROM articles AS a  
		WHERE a.title = title) = 0)
        THEN SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Non-existent article';
        ROLLBACK;
	ELSE
		   INSERT INTO likes (atricle_id, comment_id, user_id)
    (SELECT a.id, NULL, u.id FROM users AS u
    JOIN users_articles AS ua ON ua.user_id = u.id
    JOIN articles AS a ON ua.article_id = a.id
    WHERE u.username = user_name
    AND a.title = title);
    END IF;
END
$$

