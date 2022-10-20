-- --LAB 01----------------
SELECT e.department_id, count(`id`) AS 'Number of employees'
FROM `employees` AS e
GROUP BY e.department_id
ORDER BY e.department_id, `Number of employees`;

-- 02 --------------------------------
SELECT e.department_id, round(AVG(`salary`), 2) AS 'Average Salary'
FROM `employees` AS e
GROUP BY e.department_id
ORDER BY e.department_id;

-- 03 --------------------------------
SELECT e.department_id, round(MIN(`salary`), 2) AS 'Min Salary'
FROM `employees` AS e
GROUP BY e.department_id
HAVING `Min Salary` > 800;

-- 04 -----------------------------------
SELECT COUNT(*) FROM products
 WHERE price > 8
 GROUP BY category_id
 HAVING category_id = 2;
 
 -- 05 ----------------------------------------
 SELECT category_id, 
 Round(AVG(price), 2) AS 'Average Price',
 Round(MIN(price), 2) AS 'Cheapest Product',
 Round(MAX(price), 2) AS 'Most Expensive Product'
 FROM products
 GROUP BY category_id;
 
--  Exercise -------------------------------------------------------
 -- 01
 SELECT COUNT(*) AS 'count' FROM `wizzard_deposits`;
 
--  02 ------------------------------
SELECT max(magic_wand_size) AS 'longest_magic_wand'
FROM  `wizzard_deposits`;

--  03 ------------------------------
SELECT deposit_group, max(magic_wand_size) AS 'longest_magic_wand'
FROM  `wizzard_deposits`
GROUP BY deposit_group
ORDER BY `longest_magic_wand`, `deposit_group`;

--  04 ------------------------------
SELECT deposit_group 
FROM  `wizzard_deposits`
GROUP BY deposit_group
ORDER BY AVG(magic_wand_size)
LIMIT 1;

--  05 ------------------------------
SELECT deposit_group, SUM(deposit_amount) AS 'total_sum'
FROM  `wizzard_deposits`
GROUP BY deposit_group
ORDER BY total_sum;

--  06 ------------------------------
SELECT deposit_group, SUM(deposit_amount) AS 'total_sum'
FROM  `wizzard_deposits`
WHERE magic_wand_creator = 'Ollivander family'
GROUP BY deposit_group
ORDER BY deposit_group;

--  07 ------------------------------
SELECT deposit_group, SUM(deposit_amount) AS 'total_sum'
FROM  `wizzard_deposits`
WHERE magic_wand_creator = 'Ollivander family'
GROUP BY deposit_group
HAVING `total_sum` < 150000
ORDER BY total_sum DESC;

--  08 ------------------------------
SELECT deposit_group, 
	   magic_wand_creator,
       MIN(deposit_charge) AS 'min_deposit_charge'
FROM  `wizzard_deposits`
GROUP BY deposit_group, magic_wand_creator
ORDER BY magic_wand_creator, deposit_group;

--  09 ------------------------------
SELECT 
CASE
WHEN age BETWEEN 0 AND 10 THEN '[0-10]'
WHEN age BETWEEN 11 AND 20 THEN '[11-20]'
WHEN age BETWEEN 21 AND 30 THEN '[21-30]'
WHEN age BETWEEN 31 AND 40 THEN '[31-40]'
WHEN age BETWEEN 41 AND 50 THEN '[41-50]'
WHEN age BETWEEN 51 AND 60 THEN '[51-60]'
ELSE '[61+]'
END AS 'age_group',
 COUNT(id) AS 'wizard_count' 
FROM  `wizzard_deposits`
GROUP BY  age_group
ORDER BY age_group;

--  10 ------------------------------
SELECT left(first_name, 1) AS 'first_letter'
FROM `wizzard_deposits`
WHERE deposit_group LIKE 'Troll Chest'
GROUP BY first_letter
ORDER BY first_letter;

--  11 ------------------------------
SELECT deposit_group, 
       is_deposit_expired,
       AVG(deposit_interest) AS 'average_interest'
FROM `wizzard_deposits`
WHERE deposit_start_date > '1985-01-01'
GROUP BY deposit_group, is_deposit_expired
ORDER BY deposit_group DESC, is_deposit_expired;

--  12 ------------------------------
SELECT department_id, MIN(salary) AS 'minimum_salary'
FROM `employees`
WHERE hire_date > '2000-01-01' 
GROUP BY department_id
HAVING department_id IN (2,5,7)
ORDER BY department_id;

--  13 ------------------------------
SELECT department_id,
IF(department_id = 1, AVG(salary) + 5000, AVG(salary)) AS 'avg_salary'
FROM `employees`
WHERE salary > 30000 AND manager_id != 42
GROUP BY department_id
ORDER BY department_id;

--  14 ------------------------------
SELECT department_id, MAX(salary) AS 'max_salary'
FROM `employees`
GROUP BY department_id
HAVING max_salary NOT BETWEEN 30000 AND 70000
ORDER BY department_id;

--  15 ------------------------------
SELECT COUNT(salary) AS ''
FROM `employees`
WHERE manager_id IS NULL;

--  16 ------------------------------
SELECT 
    department_id,
    (SELECT DISTINCT
            salary
        FROM
            `employees` AS e2
        WHERE
            e1.department_id = e2.department_id
        ORDER BY salary DESC
        LIMIT 2 , 1) AS 'third_highest_salary'
FROM
    `employees` AS e1
GROUP BY department_id
HAVING third_highest_salary IS NOT NULL
ORDER BY department_id;

--  17 ------------------------------
SELECT e1.first_name, e1.last_name, e1.department_id
FROM employees as e1
JOIN (
SELECT e2.department_id, AVG(e2.salary) as 'salary'
FROM employees as e2
GROUP BY e2.department_id) AS `dep_salary` 
ON e1.department_id = dep_salary.department_id
WHERE e1.salary > dep_salary.salary
ORDER BY department_id, employee_id
LIMIT 10;

SELECT e.first_name, e.last_name, e.department_id
FROM employees as e
WHERE e.salary > (
SELECT AVG(salary) FROM employees
WHERE department_id = e.department_id
GROUP BY department_id )
ORDER BY department_id, employee_id
LIMIT 10;


--  18 ------------------------------
SELECT department_id, SUM(salary) AS 'total_salary'
FROM employees
GROUP BY department_id
ORDER BY department_id;