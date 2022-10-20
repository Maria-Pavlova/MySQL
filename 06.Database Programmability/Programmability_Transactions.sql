-- LAB --------------------------------------
-- 1. Count Employees by Town --------------
DELIMITER ##
CREATE FUNCTION ufn_count_employees_by_town(town_name VARCHAR(20))
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN 
    (SELECT COUNT(*)
	FROM towns AS t
	LEFT JOIN addresses AS a USING(town_id)
	LEFT JOIN employees AS e USING(address_id)
	WHERE t.name = town_name);
END
##
DELIMITER ;

SELECT ufn_count_employees_by_town('Sofia') AS 'count';

-- 2. Employees Promotion ----------------------------------------
delimiter $$
CREATE PROCEDURE usp_raise_salaries(department_name VARCHAR(20))
BEGIN
	UPDATE employees as e 
    JOIN departments AS d USING(department_id)
    SET salary = salary * 1.05
    WHERE d.name = department_name ;
END
    $$
    
   --  3. Employees Promotion By ID
    delimiter $$
CREATE PROCEDURE usp_raise_salary_by_id(id INT)
BEGIN
	IF(SELECT COUNT(*) FROM employees WHERE employee_id = id > 0)
    THEN
	UPDATE employees  
    SET salary = salary * 1.05
    WHERE employee_id = id ;
    END IF;
END
    $$
    
   --  --------------- 2 WAY
   
       delimiter $$
CREATE PROCEDURE usp_raise_salary_by_id(id INT)
BEGIN
	START TRANSACTION;
	IF(SELECT COUNT(*) FROM employees WHERE employee_id = id > 0)
    THEN
	UPDATE employees  
    SET salary = salary * 1.05 WHERE employee_id = id;
    COMMIT;
    ELSE ROLLBACK;
    END IF;
END
    $$
    
--     4. Triggered ----------------------------------------------

CREATE TABLE  `deleted_employees` (
  `employee_id` int(10) PRIMARY KEY AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `middle_name` varchar(50) DEFAULT NULL,
  `job_title` varchar(50) NOT NULL,
  `department_id` int(10) NOT NULL,
  `salary` decimal(19,4) NOT NULL
  );
 
 
CREATE TRIGGER tr_insert_deleted BEFORE DELETE
ON employees
	FOR EACH ROW
    INSERT INTO `deleted_employees`(first_name,last_name,middle_name,job_title,department_id,salary)
    VALUES(OLD.first_name,OLD.last_name,OLD.middle_name,OLD.job_title,OLD.department_id,OLD.salary)
    ;
    
  --  EXERCISE  -------------------------------------------------------------------------------------------------------------------------------
--   1. Employees with Salary Above 35000 ---------------

DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN
	SELECT e.first_name, e.last_name 
    FROM employees AS e
    WHERE e.salary > 35000
    ORDER BY e.first_name, e.last_name, e.employee_id;
END $$
  DELIMITER ;
      
  
--   02. Employees with Salary Above Number ----------------

DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above(given_number DECIMAL(12,4) )
BEGIN
	SELECT e.first_name, e.last_name 
    FROM employees AS e
    WHERE e.salary >= given_number
    ORDER BY e.first_name, e.last_name, e.employee_id;
END $$
DELIMITER ;

-- 3. Town Names Starting With -----------------------------

DELIMITER $$
CREATE PROCEDURE usp_get_towns_starting_with(start_string VARCHAR(20) )
BEGIN
	 SELECT t.name AS town_name
    FROM towns AS t
    WHERE lower(t.name) LIKE lower(concat(start_string, '%'))
    ORDER BY t.name;
END $$
DELIMITER ;

-- 04. Employees from Town --------------------------------------

DELIMITER $$
CREATE PROCEDURE usp_get_employees_from_town (town_name VARCHAR(20))
BEGIN
	 SELECT e.first_name, e.last_name 
    FROM employees AS e
    JOIN addresses AS a USING (address_id) 
    JOIN towns AS t USING (town_id) 
    WHERE t.name LIKE town_name
    ORDER BY e.first_name, e.last_name, e.employee_id;
END $$
DELIMITER ;

-- 05. Salary Level Function ------------------------------------

DELIMITER $$
CREATE FUNCTION ufn_get_salary_level(salary DECIMAL(12,4))
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
	DECLARE salary_Level VARCHAR(10);
       IF salary < 30000 THEN SET salary_Level := 'Low';
       ELSEIF salary BETWEEN 30000 AND 50000 THEN SET salary_Level := 'Average';
       ELSE SET salary_Level := 'High';
       END IF;
       RETURN salary_Level;
END $$
DELIMITER ;




-- 06. Employees by Salary Level -----------------------------------

CREATE FUNCTION ufn_get_salary_level2(salary DECIMAL(12,4))
RETURNS VARCHAR(10)
DETERMINISTIC

	RETURN ( CASE
		WHEN salary < 30000 THEN 'Low'
		WHEN salary <= 50000 THEN 'Average'
        ELSE 'High'
	END);
        

DELIMITER $$
CREATE PROCEDURE usp_get_employees_by_salary_level(salary_Level VARCHAR(10) )
BEGIN
	SELECT e.first_name, e.last_name 
    FROM employees AS e
    WHERE ufn_get_salary_level2(e.salary) = salary_Level
    ORDER BY e.first_name DESC, e.last_name DESC;
END $$
DELIMITER ;

CALL usp_get_employees_by_salary_level('high');

-- 07. Define Function --------------------------------------------

DELIMITER $$
CREATE FUNCTION ufn_is_word_comprised(set_of_letters varchar(50), word varchar(50))
RETURNS BIT
DETERMINISTIC
BEGIN
	RETURN word REGEXP(concat('^[', set_of_letters, ']+$'));
END $$
DELIMITER ;

SELECT ufn_is_word_comprised('oistmiahf', 'halves');

-- 08. Find Full Name -----------------------------------------------
DELIMITER $$
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
	SELECT concat_ws(' ', ah.first_name, ah.last_name) AS full_name
    FROM account_holders AS ah
    ORDER BY full_name, ah.id ;
END $$
DELIMITER ;

-- 9. People with Balance Higher Than -----------------------------

DELIMITER $$
CREATE PROCEDURE usp_get_holders_with_balance_higher_than(money DECIMAL(18,4))
BEGIN
	SELECT  ah.first_name, ah.last_name 
    FROM account_holders AS ah
    RIGHT JOIN accounts AS a ON ah.id = a.account_holder_id
    GROUP BY ah.id
    HAVING SUM(a.balance) > money
    ORDER BY ah.id ;
END $$
DELIMITER ;

-- 10. Future Value Function ----------------------------------------

DELIMITER $$
CREATE FUNCTION ufn_calculate_future_value(initial_sum DECIMAL(16,4), 
						yearly_interest DOUBLE, years INT)
RETURNS DECIMAL(18,4)
DETERMINISTIC
BEGIN
	RETURN initial_sum *  POW (1+ yearly_interest, years);
END $$
DELIMITER ;

-- 11. Calculating Interest ---------------------------------------------
-- P.10 + 11

DELIMITER $$
CREATE PROCEDURE usp_calculate_future_value_for_account(ac_id INT, interests DECIMAL(8,4))
BEGIN
	SELECT a.id AS 'acount_id', 
		   ah.first_name, 
           ah.last_name, 
           a.balance AS 'current_balance', 
           ufn_calculate_future_value(a.balance, interests, 5) AS 'balance_in_5_years'
    FROM accounts AS a
    JOIN account_holders AS ah ON a.account_holder_id = ah.id
    WHERE a.id = ac_id ;
END $$
DELIMITER ;

-- 12. Deposit Money ------------------------------------
DELIMITER $$
CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(18,4))
BEGIN
	IF money_amount > 0 THEN
	START TRANSACTION;
	UPDATE accounts SET balance = balance + money_amount
	WHERE id = account_id ;
    COMMIT;
    END IF;
END $$
DELIMITER ;

-- 13. Withdraw Money ------------------------------------
DELIMITER $$
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(18,4))
BEGIN
START TRANSACTION;
	IF money_amount < 0 
    OR (SELECT balance FROM accounts WHERE id = account_id) < money_amount
    THEN ROLLBACK;
    ELSE
	UPDATE accounts SET balance = balance - money_amount
	WHERE id = account_id ;
    COMMIT;
    END IF;
END $$
DELIMITER ;

-- 14. Money Transfer ------------------------------------

DELIMITER $$
CREATE PROCEDURE usp_transfer_money(from_account_id INT, to_account_id INT, amount DECIMAL(18,4))
BEGIN
START TRANSACTION;
	IF (amount <= 0) 
		OR (SELECT id FROM accounts 
			WHERE id = from_account_id) IS NULL 
		OR (SELECT id FROM accounts 
			WHERE id = to_account_id) IS NULL 
		OR from_account_id = to_account_id
		OR (SELECT balance FROM accounts 
			WHERE id = from_account_id) < amount
    THEN ROLLBACK;
    ELSE
	UPDATE accounts SET balance = balance - amount 
			WHERE id = from_account_id;
    UPDATE accounts SET balance = balance + amount 
			WHERE id = to_account_id;
    COMMIT;
    END IF;
END $$
DELIMITER ;

-- 15. Log Accounts Trigger -------------------------------

CREATE TABLE `logs`(
`log_id` INT PRIMARY KEY AUTO_INCREMENT,
`account_id` INT, 
`old_sum` DECIMAL(18,4), 
`new_sum` DECIMAL(18,4)
);

CREATE TRIGGER tr_account_change AFTER UPDATE
ON accounts
FOR EACH ROW
	INSERT INTO `logs` (`account_id`, `old_sum`, `new_sum`)
    VALUES(OLD.id, OLD.balance, NEW.balance);

-- 16. Emails Trigger ----------------------------------
CREATE TABLE `logs`(
`log_id` INT PRIMARY KEY AUTO_INCREMENT,
`account_id` INT NOT NULL, 
`old_sum` DECIMAL(18,4) NOT NULL, 
`new_sum` DECIMAL(18,4) NOT NULL
);

CREATE TRIGGER tr_account_change AFTER UPDATE
ON accounts
FOR EACH ROW
	INSERT INTO `logs` (`account_id`, `old_sum`, `new_sum`)
    VALUES(OLD.id, OLD.balance, NEW.balance);
    
CREATE TABLE `notification_emails`(
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`recipient` INT NOT NULL, 
`subject` VARCHAR (60) NOT NULL, 
`body` VARCHAR(200) NOT NULL
);

CREATE TRIGGER tr_notification_emails  
AFTER INSERT
ON `logs`
FOR EACH ROW
	INSERT INTO `notification_emails`(`recipient`, `subject`, `body`)
    VALUES (NEW.account_id, 
			concat('Balance change for account: ', NEW.account_id),
            concat('On ', DATE_FORMAT (NOW(),'%b %d %Y at %r'),
              ' your balance was changed from ',
              NEW.old_sum, ' to ', NEW.new_sum, '.'));

