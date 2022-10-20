-- LAB -----------------------------
-- 1. Managers----------------------

SELECT e.employee_id, 
       concat_ws(' ',e.first_name, e.last_name) AS 'full_name',
       d.department_id,
       d.name
FROM `employees` AS e
JOIN  `departments` AS d ON e.employee_id = d.manager_id
ORDER BY e.employee_id
LIMIT 5;

-- 2. Towns Addresses--------------------------
SELECT t.town_id, t.name AS 'town_name', a.address_text
FROM towns AS t
JOIN addresses AS a
ON t.town_id = a.town_id
WHERE t.name IN ('San Francisco', 'Sofia', 'Carnation')
ORDER BY t.town_id, a.address_id;

-- 3. Employees Without Managers --------------------
SELECT employee_id, first_name, last_name, department_id, salary
FROM employees
WHERE manager_id IS NULL;

-- 04. Higher salary----------
SELECT COUNT(e.employee_id) AS 'count'
FROM employees AS e
WHERE (SELECT AVG(salary)FROM employees) < e.salary;



-- EXERCISE -------------------------------------------------------------------------------
-- 1. Employee Address --------------------------------------------------

SELECT e.employee_id, e.job_title, e.address_id, a.address_text
FROM employees AS e
JOIN addresses AS a
USING (address_id)
ORDER BY e.address_id 
LIMIT 5;

-- 2. Addresses with Towns ---------------------------
SELECT e.first_name, e.last_name, t.name AS 'town', a.address_text
FROM employees AS e
JOIN addresses AS a
USING (address_id)
JOIN towns AS t
USING (town_id)
ORDER BY e.first_name, e.last_name
LIMIT 5;

-- 03. Sales Employee ---------------------------
SELECT e.employee_id, e.first_name, e.last_name,
       d.name AS 'department_name'
FROM employees AS e
JOIN departments AS d
USING (department_id)
WHERE d.name LIKE 'Sales'
ORDER BY e.employee_id DESC;

-- 04. Employee Departments---------------------------
SELECT e.employee_id, e.first_name, e.salary,
       d.name AS 'department_name'
FROM employees AS e
JOIN departments AS d
USING (department_id)
WHERE e.salary > 15000
ORDER BY d.department_id DESC
LIMIT 5;

-- 05. Employees Without Project -------------------------
SELECT e.employee_id, e.first_name
FROM employees AS e
LEFT JOIN employees_projects AS ep USING (employee_id)
WHERE ep.project_id IS NULL
ORDER BY e.employee_id DESC
LIMIT 3;

-- 06. Employees Hired After ---------------------------
SELECT e.first_name, e.last_name, e.hire_date,
 d.name AS 'dept_name'
FROM employees AS e
JOIN departments AS d
USING (department_id)
WHERE e.hire_date > '1999-01-01' AND d.name IN ('Sales', 'Finance')
ORDER BY e.hire_date;

-- 07. Employees with Project ---------------------------
SELECT e.employee_id, e.first_name, p.name AS 'project_name'
FROM employees AS e
JOIN employees_projects AS ep USING (employee_id)
JOIN projects AS p USING (project_id)
WHERE DATE(p.start_date) > '2002-08-13' AND p.end_date IS NULL
ORDER BY e.first_name, p.name
LIMIT 5;

-- 08. Employee 24 ------------------------------------

SELECT e.employee_id, e.first_name,
IF(YEAR(p.start_date) >= '2005', NULL, p.name)
AS 'project_name'
FROM employees AS e
JOIN employees_projects AS ep USING (employee_id)
JOIN projects AS p USING (project_id)
WHERE e.employee_id = 24
ORDER BY p.name;

-- 09. Employee Manager -------------------------------

SELECT e.employee_id, e.first_name, e.manager_id,
 m.first_name AS 'manager_name'
FROM employees AS e
JOIN employees AS m 
ON e.manager_id = m.employee_id
WHERE e.manager_id IN (3, 7)
ORDER BY e.first_name;

-- 10. Employee Summary-----------------------------------
SELECT e.employee_id,
       concat_ws(' ', e.first_name, e.last_name) AS 'employee_name',
       concat_ws(' ', m.first_name, m.last_name) AS 'manager_name',
       d.name AS 'department_name'
FROM employees AS e
JOIN employees AS m ON e.manager_id = m.employee_id
JOIN departments AS d ON e.department_id = d.department_id
ORDER BY e.employee_id
LIMIT 5;

-- 11. Min Average Salary --------------------------------
SELECT AVG(e.salary) AS 'min_average_salary'
FROM employees AS e
GROUP BY e.department_id
ORDER BY `min_average_salary`
LIMIT 1;

-- 12. Highest Peaks in Bulgaria -----------------------

SELECT c.country_code,
       m.mountain_range,
       p.peak_name,
       p.elevation
FROM countries AS c
JOIN mountains_countries AS mc USING (country_code)
JOIN mountains AS m ON m.id = mc.mountain_id
JOIN peaks AS p ON m.id = p.mountain_id
WHERE c.country_name LIKE 'Bulgaria' AND p.elevation > 2835
ORDER BY p.elevation DESC;

-- 13. Count Mountain Ranges ---------------------------
SELECT c.country_code,
      COUNT(m.mountain_range) AS 'mountain_range'
FROM countries AS c
JOIN mountains_countries AS mc USING (country_code) 
JOIN mountains AS m ON m.id = mc.mountain_id 
WHERE c.country_name IN ( 'Bulgaria', 'Russia', 'United States')
GROUP BY c.country_code
ORDER BY `mountain_range` DESC;

-- 14. Countries with Rivers --------------------------
SELECT c.country_name, r.river_name 
FROM countries AS c
LEFT JOIN countries_rivers AS cr USING (country_code) 
LEFT JOIN rivers AS r ON r.id = cr.river_id
WHERE c.continent_code LIKE 'AF'
ORDER BY c.country_name
LIMIT 5;

-- 15-- . *Continents and Currencies-------------------
SELECT 
    c.continent_code,
    c.currency_code,
    COUNT(*) AS 'currency_usage'
FROM
    countries AS c
GROUP BY c.continent_code , c.currency_code
HAVING currency_usage > 1
    AND currency_usage = (SELECT 
        COUNT(*) AS 'usage'
    FROM countries AS c2
    WHERE c2.continent_code = c.continent_code
    GROUP BY c2.currency_code
    ORDER BY `usage` DESC
    LIMIT 1)
ORDER BY c.continent_code , c.currency_code;

 
-- 16. Countries without any Mountains ----------------

SELECT COUNT(*) AS 'country_count'
FROM countries AS c
LEFT JOIN mountains_countries AS mc USING (country_code)
WHERE mc.mountain_id IS NULL;

-- 17. Highest Peak and Longest River by Country -----------

SELECT c.country_name, 
       MAX(p.elevation) AS 'highest_peak_elevation',
       MAX(r.length) AS 'longest_river_length'
FROM countries AS c
LEFT JOIN  mountains_countries AS mc USING (country_code)
LEFT JOIN peaks AS p USING(mountain_id)
LEFT JOIN countries_rivers AS cr USING (country_code)
LEFT JOIN rivers AS r ON r.id = cr.river_id
GROUP BY c.country_code
ORDER BY highest_peak_elevation DESC,
         longest_river_length DESC,
         c.country_name
LIMIT 5;