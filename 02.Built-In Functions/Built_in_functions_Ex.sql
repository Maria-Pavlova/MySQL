-- 01
SELECT `first_name`, `last_name`
FROM `employees`
WHERE LEFT(`first_name`, 2) = 'Sa'
ORDER BY `employee_id`;

-- 02---------------------------------------
SELECT `first_name`, `last_name`
FROM `employees`
WHERE `last_name` LIKE '%ei%'
ORDER BY `employee_id`; 

-- 03--------------------------------------------
SELECT `first_name` FROM `employees`
WHERE `department_id` IN (3, 10)
AND year(`hire_date`) BETWEEN '1995' AND '2005'
ORDER BY `employee_id`; 

-- 04----------------------------------------
SELECT `first_name`, `last_name` FROM `employees`
WHERE `job_title` NOT LIKE '%engineer%'
ORDER BY `employee_id`; 

-- 05---------------------------------
SELECT `name` FROM `towns`
WHERE char_length(`name`) IN (5, 6)
ORDER BY `name`;

-- 06------------------------------
SELECT `town_id`, `name` FROM `towns`
WHERE left(`name`, 1) IN ('M', 'K', 'B', 'E')
ORDER BY `name`;

SELECT `town_id`, `name` FROM `towns`
WHERE `name` REGEXP '^[MmKkBbEe]'
ORDER BY `name`;

-- 07 ----------------------------------- 
SELECT `town_id`, `name` FROM `towns`
WHERE left(`name`, 1) NOT IN ('R', 'B', 'D')
ORDER BY `name`;

SELECT `town_id`, `name` FROM `towns`
WHERE `name` REGEXP '^[^RrBbDd]'
ORDER BY `name`;

-- 08----------------------------------------
 CREATE VIEW `v_employees_hired_after_2000` AS
    SELECT `first_name`, `last_name` FROM `employees`
    WHERE YEAR(`hire_date`) > '2000';
SELECT * FROM `v_employees_hired_after_2000`;

-- 09 ------------------------------------
SELECT `first_name`, `last_name` FROM `employees`
WHERE char_length(`last_name`) = 5; 

-- 10 -----------------------------------------
SELECT `country_name`, `iso_code` FROM `countries`
WHERE `country_name` LIKE '%a%a%a%'
ORDER BY `iso_code`;

SELECT `country_name`, `iso_code` FROM `countries`
WHERE `country_name` REGEXP '(.*a.*){3,}'
ORDER BY `iso_code`;

SELECT `country_name`, `iso_code` FROM `countries`
WHERE char_length(`country_name`) - char_length(REPLACE(LOWER(`country_name`), 'a', '')) >=3
ORDER BY `iso_code`;


-- 11------------------------------------------
SELECT 
    p.peak_name, r.river_name, 
    LOWER(concat(LEFT(p.peak_name, 
    CHAR_LENGTH(p.peak_name)-1), r.river_name)) AS mix
FROM
    `peaks` AS p, `rivers` AS r
    WHERE lower(RIGHT(p.peak_name, 1)) = 
          lower(left(r.river_name, 1))
          ORDER BY mix;
  --   ---------------------------------------------      
SELECT p.peak_name, r.river_name, 
LOWER(concat(p.peak_name, SUBSTRING(r.river_name, 2))) AS mix
FROM
    `peaks` AS p, `rivers` AS r
    WHERE lower(RIGHT(p.peak_name, 1)) = 
          lower(left(r.river_name, 1))
          ORDER BY mix;
          
-- 12---------------------------------------------
SELECT `name`, substring(`start`,1 , 10) AS 'start' 
FROM `games`
WHERE YEAR(`start`) IN ('2011', '2012')
ORDER BY `start`,`name`
LIMIT 50;

SELECT `name`, DATE_FORMAT(`start`, '%Y-%m-%d') AS 'start' 
FROM `games`
WHERE YEAR(`start`) IN ('2011', '2012')
ORDER BY `start`,`name`
LIMIT 50;

-- 13 --------------------------------------------
SELECT `user_name`, REGEXP_REPLACE(`email`, '.*@', '') AS 'email provider'  
FROM `users`
ORDER BY `email provider`, `user_name`;


SELECT `user_name`, SUBSTRING_INDEX(`email`, '@', -1) AS 'email provider'  
FROM `users`
ORDER BY `email provider`, `user_name`;

-- 14 ---------------------------------------
SELECT `user_name`, `ip_address` FROM `users`
WHERE `ip_address` LIKE '___.1%.%.___'
ORDER BY  `user_name`;

-- 15 ----------------------------------
SELECT `name` AS game,
CASE
WHEN HOUR(g.start) BETWEEN 0 AND 11 THEN 'Morning'
WHEN HOUR(g.start) BETWEEN 12 AND 17 THEN 'Afternoon'
ELSE 'Evening'
END as 'Part of day',
CASE
WHEN g.duration <= 3 THEN 'Extra Short'
WHEN g.duration BETWEEN 4 AND 6 THEN 'Short'
WHEN g.duration BETWEEN 7 AND 10 THEN 'Long'
ELSE 'Extra Long'
END AS 'Duration'
FROM games AS g;

-- 16 --------------------------------------------------
SELECT `product_name`, `order_date`,
adddate(`order_date`, INTERVAL 3 DAY) AS 'pay_date',
adddate(`order_date`, INTERVAL 1 MONTH) AS 'deliver_date'
FROM `orders`;